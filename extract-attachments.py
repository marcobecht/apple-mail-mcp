#!/usr/bin/env python3
"""Extract email attachments into a structured folder tree.

Reads the apple-mail-mcp index to find all attachments, then extracts
them from the original .emlx files into:

    <output>/
    ├── research-papers/
    ├── presentations/
    ├── governance-research/
    ├── divestment-defence/
    ├── teaching/
    ├── events/
    ├── ecgi-admin/
    ├── bruegel/
    ├── data-files/
    ├── invoices-finance/
    ├── contracts/
    └── other/

Within each category, files are placed in YYYY/sender-name/ subfolders.
Inline images (< 10 KB) and duplicates are skipped.

Incremental mode (default): only extracts attachments from emails
indexed after the last successful run.  Use --full to re-extract
everything.

Usage:
    python extract-attachments.py              # incremental
    python extract-attachments.py --full       # full re-extract
    python extract-attachments.py --dry-run    # preview only
"""

import argparse
import hashlib
import json
import re
import sqlite3
import sys
from datetime import datetime, timezone
from pathlib import Path

# Where the index lives
INDEX_DB = Path.home() / ".apple-mail-mcp" / "index.db"

# Default output: iCloud Drive so all Macs have access
ICLOUD_EMAIL = (
    Path.home()
    / "Library"
    / "Mobile Documents"
    / "com~apple~CloudDocs"
    / "Email"
)
DEFAULT_OUTPUT = str(ICLOUD_EMAIL)

# Minimum file size to extract (skip tiny inline images)
MIN_SIZE = 10 * 1024  # 10 KB

# Lazy-loaded account name map (UUID → friendly name)
_account_names: dict[str, str] | None = None


def _get_account_names() -> dict[str, str]:
    """Resolve account UUIDs to friendly names from the index DB."""
    global _account_names
    if _account_names is not None:
        return _account_names

    _account_names = {}
    try:
        conn = sqlite3.connect(str(INDEX_DB))
        rows = conn.execute(
            "SELECT DISTINCT account FROM emails"
        ).fetchall()
        conn.close()

        # Try JXA for friendly names
        import subprocess

        result = subprocess.run(
            [
                "osascript",
                "-l",
                "JavaScript",
                "-e",
                """
var Mail = Application("Mail");
var accts = Mail.accounts();
var map = {};
for (var i = 0; i < accts.length; i++) {
    map[accts[i].id()] = accts[i].name();
}
JSON.stringify(map);
""",
            ],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode == 0:
            _account_names = json.loads(result.stdout.strip())
    except Exception:
        pass

    # Fallback: use first 8 chars of UUID for any unmapped accounts
    return _account_names

# Skip these filename patterns (inline images, signatures, etc.)
SKIP_PATTERNS = [
    re.compile(r"^image\d+\.\w+$", re.I),
    re.compile(r"logo", re.I),
    re.compile(r"signature", re.I),
    re.compile(r"^spacer\.", re.I),
    re.compile(r"^pixel\.", re.I),
    re.compile(r"^tracking\.", re.I),
    re.compile(r"^outlook_\w+\.\w+$", re.I),
]


def categorize(subject: str, filename: str) -> str:
    """Assign an attachment to a project category."""
    sl = subject.lower()
    fl = filename.lower()

    # Specific projects
    if any(
        k in sl
        for k in ("divestment", "divest", "defence ind", "defense ind", "arms")
    ):
        return "divestment-defence"
    if any(k in sl for k in ("bruegel",)):
        return "bruegel"

    # Teaching
    if any(
        k in sl
        for k in (
            "memoire",
            "thesis",
            "exam",
            "grade",
            "student",
            "course",
            "lecture",
            "marking",
        )
    ):
        return "teaching"

    # Governance research
    if any(
        k in sl
        for k in (
            "board",
            "governance",
            "shareholder",
            "voting",
            "proxy",
            "stewardship",
            "ownership",
            "blockhold",
        )
    ):
        return "governance-research"

    # ECGI admin
    if "ecgi" in sl:
        return "ecgi-admin"

    # Events
    if any(
        k in sl
        for k in ("conference", "seminar", "workshop", "invitation", "event")
    ):
        return "events"

    # Finance/invoices
    if any(
        k in sl
        for k in ("invoice", "facture", "payment", "rechnung", "billing")
    ):
        return "invoices-finance"

    # Contracts
    if any(k in sl for k in ("contract", "agreement", "signing")):
        return "contracts"

    # By file type
    if fl.endswith((".pptx", ".ppt", ".key")):
        return "presentations"
    if fl.endswith((".xlsx", ".xls", ".csv", ".xlsm", ".dta", ".sas7bdat")):
        return "data-files"
    if fl.endswith(".pdf"):
        return "research-papers"

    return "other"


def sanitize(name: str, max_len: int = 80) -> str:
    """Make a string safe for use as a filename/dirname."""
    name = re.sub(r'[<>:"/\\|?*\x00-\x1f]', "_", name)
    name = re.sub(r"_+", "_", name).strip("_. ")
    return name[:max_len] if name else "unknown"


def sender_dirname(sender: str) -> str:
    """Extract a short dirname from a sender string."""
    # "John Doe <john@example.com>" -> "John Doe"
    m = re.match(r'"?([^"<]+)"?\s*<', sender)
    if m:
        return sanitize(m.group(1).strip())
    # Bare email
    m = re.match(r"<?(\S+)@", sender)
    if m:
        return sanitize(m.group(1))
    return sanitize(sender)


def should_skip(filename: str, file_size: int) -> bool:
    """Check if an attachment should be skipped."""
    if file_size < MIN_SIZE:
        return True
    for pat in SKIP_PATTERNS:
        if pat.search(filename):
            return True
    return False


def _state_path(output_dir: Path) -> Path:
    """Path to the extraction state file."""
    return output_dir / ".extract-state.json"


def _load_state(output_dir: Path) -> dict:
    """Load last extraction state (timestamp + hash set)."""
    p = _state_path(output_dir)
    if p.exists():
        return json.loads(p.read_text())
    return {"last_indexed_at": None, "hashes": []}


def _save_state(output_dir: Path, last_indexed_at: str, hashes: list[str]):
    """Save extraction state for incremental runs."""
    p = _state_path(output_dir)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps({
        "last_indexed_at": last_indexed_at,
        "hashes": hashes,
        "updated": datetime.now(timezone.utc).isoformat(),
    }))


def main():
    parser = argparse.ArgumentParser(description="Extract email attachments")
    parser.add_argument(
        "--output",
        "-o",
        default=DEFAULT_OUTPUT,
        help="Output directory (default: iCloud Drive/Email)",
    )
    parser.add_argument(
        "--dry-run",
        "-n",
        action="store_true",
        help="Show what would be extracted without writing files",
    )
    parser.add_argument(
        "--full",
        action="store_true",
        help="Full extraction (ignore last-run state)",
    )
    parser.add_argument(
        "--account",
        "-a",
        help="Only extract from this account (friendly name or UUID)",
    )
    args = parser.parse_args()

    output_dir = Path(args.output)

    # Load incremental state
    state = _load_state(output_dir) if not args.full else {"last_indexed_at": None, "hashes": []}
    last_indexed_at = state.get("last_indexed_at")

    if last_indexed_at and not args.full:
        print(f"Incremental mode: extracting emails indexed after {last_indexed_at}")
    else:
        print("Full extraction mode")

    # Connect to index
    conn = sqlite3.connect(str(INDEX_DB))
    conn.row_factory = sqlite3.Row

    # Build query
    query = """
        SELECT a.filename, a.file_size, a.mime_type,
               e.emlx_path, e.subject, e.sender, e.date_received,
               e.account, e.indexed_at
        FROM attachments a
        JOIN emails e ON a.email_rowid = e.rowid
        WHERE a.filename IS NOT NULL AND a.filename != ''
    """
    params: list = []

    if last_indexed_at and not args.full:
        query += " AND e.indexed_at > ?"
        params.append(last_indexed_at)

    if args.account:
        # Resolve friendly name
        uuid = args.account
        for uid, name in _get_account_names().items():
            if name.lower() == args.account.lower():
                uuid = uid
                break
        query += " AND e.account = ?"
        params.append(uuid)

    query += " ORDER BY e.date_received"
    rows = conn.execute(query, params).fetchall()

    # Get the latest indexed_at for state tracking
    max_indexed = conn.execute(
        "SELECT MAX(indexed_at) FROM emails"
    ).fetchone()[0]
    conn.close()

    print(f"Found {len(rows)} attachments to process")

    # Track duplicates by content hash (seed from prior runs)
    seen_hashes: set[str] = set(state.get("hashes", []))
    stats = {"extracted": 0, "skipped_small": 0, "skipped_dup": 0, "errors": 0}
    category_counts: dict[str, int] = {}

    # Lazy import — only needed for actual extraction
    if not args.dry_run:
        from apple_mail_mcp.index.disk import get_attachment_content

    for i, row in enumerate(rows):
        filename = row["filename"]
        file_size = row["file_size"] or 0
        emlx_path = row["emlx_path"]
        subject = row["subject"] or ""
        sender = row["sender"] or ""
        date_str = row["date_received"] or ""
        account = row["account"]

        if should_skip(filename, file_size):
            stats["skipped_small"] += 1
            continue

        # Build output path
        year = date_str[:4] if len(date_str) >= 4 else "unknown"
        category = categorize(subject, filename)
        acct_name = _get_account_names().get(account, account[:8])
        sender_dir = sender_dirname(sender)
        safe_filename = sanitize(filename, max_len=120)

        dest = output_dir / category / acct_name / year / sender_dir / safe_filename

        category_counts[category] = category_counts.get(category, 0) + 1

        if args.dry_run:
            stats["extracted"] += 1
            if (i + 1) % 1000 == 0:
                print(f"  Scanned {i + 1}/{len(rows)}...")
            continue

        # Extract
        if not emlx_path:
            stats["errors"] += 1
            continue

        try:
            result = get_attachment_content(Path(emlx_path), filename)
        except Exception:
            stats["errors"] += 1
            continue

        if result is None:
            stats["errors"] += 1
            continue

        content_bytes, _ = result

        # Deduplicate
        content_hash = hashlib.md5(content_bytes).hexdigest()
        if content_hash in seen_hashes:
            stats["skipped_dup"] += 1
            continue
        seen_hashes.add(content_hash)

        # Write
        dest.parent.mkdir(parents=True, exist_ok=True)

        # Handle filename collisions
        if dest.exists():
            stem = dest.stem
            suffix = dest.suffix
            for j in range(2, 100):
                candidate = dest.parent / f"{stem}_{j}{suffix}"
                if not candidate.exists():
                    dest = candidate
                    break

        dest.write_bytes(content_bytes)
        stats["extracted"] += 1

        if (i + 1) % 500 == 0:
            print(f"  Processed {i + 1}/{len(rows)}, extracted {stats['extracted']}...")

    print()
    print(f"{'DRY RUN — ' if args.dry_run else ''}Results:")
    print(f"  Extracted:      {stats['extracted']:,}")
    print(f"  Skipped (small):{stats['skipped_small']:,}")
    print(f"  Skipped (dup):  {stats['skipped_dup']:,}")
    print(f"  Errors:         {stats['errors']:,}")
    print()
    if category_counts:
        print("By category:")
        for cat, cnt in sorted(category_counts.items(), key=lambda x: -x[1]):
            print(f"  {cat:25s} {cnt:,}")

    # Save state for incremental runs
    if not args.dry_run and max_indexed:
        all_hashes = list(seen_hashes)
        _save_state(output_dir, max_indexed, all_hashes)
        print()
        print(f"State saved. Next run will only process emails indexed after {max_indexed}")


if __name__ == "__main__":
    main()
