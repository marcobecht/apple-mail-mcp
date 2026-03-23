"""Tests for apple_mail_mcp.index.watcher."""

from __future__ import annotations

import sqlite3
from pathlib import Path
from unittest.mock import patch

import pytest

from apple_mail_mcp.index.schema import create_connection, get_schema_sql
from apple_mail_mcp.index.watcher import IndexWatcher


@pytest.fixture
def watcher_db(tmp_path: Path) -> tuple[Path, sqlite3.Connection]:
    """Create a temporary database for watcher tests."""
    db_path = tmp_path / "watcher_test.db"
    conn = create_connection(str(db_path))
    conn.executescript(get_schema_sql())
    conn.execute(
        "INSERT INTO schema_version (version) VALUES (?)", (4,)
    )
    conn.commit()
    return db_path, conn


class TestProcessPendingResilience:
    """Watcher should skip files that fail to parse, not crash."""

    def _make_watcher(self, db_path: Path) -> IndexWatcher:
        """Create a watcher without starting the watch loop."""
        watcher = IndexWatcher.__new__(IndexWatcher)
        watcher.db_path = str(db_path)
        watcher._conn = None
        watcher._pending_adds = {}
        watcher._pending_deletes = set()
        import threading

        watcher._pending_lock = threading.Lock()
        watcher._stop_event = threading.Event()
        watcher._mail_dir = None
        watcher._thread = None
        watcher.on_update = None
        watcher.debounce_ms = 500
        return watcher

    @patch("apple_mail_mcp.index.watcher.parse_emlx")
    def test_runtime_error_skips_file(self, mock_parse, watcher_db):
        """RuntimeError in parse_emlx should not crash the watcher."""
        db_path, conn = watcher_db
        conn.close()

        watcher = self._make_watcher(db_path)
        watcher._pending_adds = {
            ("acct", "INBOX", 1): Path("/fake/1.emlx"),
            ("acct", "INBOX", 2): Path("/fake/2.emlx"),
        }

        mock_parse.side_effect = RuntimeError("malformed plist")

        # Should not raise — watcher skips bad files
        watcher._process_pending()

        # Both files attempted, neither crashed the watcher
        assert mock_parse.call_count == 2

    @patch("apple_mail_mcp.index.watcher.parse_emlx")
    def test_attribute_error_skips_file(self, mock_parse, watcher_db):
        """AttributeError in parse_emlx should not crash the watcher."""
        db_path, conn = watcher_db
        conn.close()

        watcher = self._make_watcher(db_path)
        watcher._pending_adds = {
            ("acct", "INBOX", 1): Path("/fake/1.emlx"),
        }

        mock_parse.side_effect = AttributeError("NoneType has no attr")

        watcher._process_pending()

        assert mock_parse.call_count == 1

    @patch("apple_mail_mcp.index.watcher.parse_emlx")
    def test_key_error_skips_file(self, mock_parse, watcher_db):
        """KeyError in parse_emlx should not crash the watcher."""
        db_path, conn = watcher_db
        conn.close()

        watcher = self._make_watcher(db_path)
        watcher._pending_adds = {
            ("acct", "INBOX", 1): Path("/fake/1.emlx"),
        }

        mock_parse.side_effect = KeyError("missing-header")

        watcher._process_pending()

        assert mock_parse.call_count == 1

    @patch("apple_mail_mcp.index.watcher.parse_emlx")
    def test_deletes_still_processed_after_parse_failure(
        self, mock_parse, watcher_db
    ):
        """Deletes should still be processed even if adds fail."""
        db_path, conn = watcher_db

        # Insert a row to delete
        conn.execute(
            "INSERT INTO emails "
            "(message_id, account, mailbox, subject, sender, "
            "content, date_received, emlx_path, attachment_count) "
            "VALUES (1, 'acct', 'INBOX', 'test', 'a@b.com', "
            "'body', '2024-01-01', '/fake/1.emlx', 0)"
        )
        conn.commit()
        conn.close()

        watcher = self._make_watcher(db_path)
        watcher._pending_deletes = {("acct", "INBOX", 1)}
        watcher._pending_adds = {
            ("acct", "INBOX", 2): Path("/fake/2.emlx"),
        }

        mock_parse.side_effect = RuntimeError("crash")

        watcher._process_pending()

        # Verify delete went through
        check_conn = create_connection(str(db_path))
        count = check_conn.execute(
            "SELECT COUNT(*) FROM emails"
        ).fetchone()[0]
        check_conn.close()
        assert count == 0
