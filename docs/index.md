# Apple Mail MCP

The only Apple Mail MCP server with **full-text email search**. Reliable on large mailboxes where other servers timeout — with 8 tools for reading, searching, and extracting email content. Also works as a standalone CLI.

---

## Why Apple Mail MCP?

Tested against [6 other Apple Mail MCP servers](benchmarks.md) on a 30K+ email mailbox:

- **Only server** that completes all operations without timing out
- **Only server** with full-text body search (FTS5 index, ~20ms)
- **5ms** single email fetch via disk-first `.emlx` reading
- **7–9ms** subject search via FTS5 (vs 230ms+ for AppleScript-based servers)

![Capability Matrix](benchmark_overview.png)

## Key Features

- **8 MCP tools + CLI** — search, read, list, extract attachments and links — usable as MCP server or standalone CLI
- **Unified filtering** — unread, flagged, today, last 7 days
- **FTS5 search index** — full-text body search in ~2ms with BM25 ranking
- **Real-time updates** — `--watch` flag for automatic index updates
- **Disk-first sync** — fast filesystem scanning instead of slow JXA queries
- **Type-safe** — full Python type hints with PEP 561 `py.typed` marker

## Quick Install

```bash
# No install required — run directly
pipx run apple-mail-mcp

# Or install globally
pipx install apple-mail-mcp
```

## Claude Desktop Setup

```json
{
  "mcpServers": {
    "mail": {
      "command": "apple-mail-mcp"
    }
  }
}
```

That's it. Ask Claude to search your emails, get today's messages, or find unread mail.

## CLI Usage (No MCP Required)

All tools also work as standalone CLI commands:

```bash
apple-mail-mcp search "quarterly report" --after 2026-01-01
apple-mail-mcp read 12345
apple-mail-mcp emails --filter unread --limit 10
```

Generate a Claude Code skill for CLI-based access:

```bash
apple-mail-mcp integrate claude > ~/.claude/skills/apple-mail.md
```

## Next Steps

- [Getting Started](getting-started.md) — first-use walkthrough
- [Installation](installation.md) — all installation methods
- [Tools](tools.md) — full API reference for all 8 tools
- [Search & Indexing](search.md) — FTS5 deep dive
- [Architecture](architecture.md) — how it works under the hood
- [Architecture Deep Dive](architecture-deep-dive.md) — `.emlx` format, JXA IPC, FTS5 index design
- [Benchmarks](benchmarks.md) — competitive performance data
