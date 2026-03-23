"""Apple Mail MCP — the only Apple Mail MCP server with full-text email search.

Features:
- Disk-first email reading (~5ms via .emlx parsing, no JXA needed)
- Full-text body search via FTS5 index (~20ms)
- Reliable on large mailboxes (30K+) where other servers timeout

Usage:
    apple-mail-mcp            # Run MCP server (default)
    apple-mail-mcp index      # Build search index from disk
    apple-mail-mcp status     # Show index statistics
    apple-mail-mcp rebuild    # Force rebuild index
"""

from .cli import main
from .server import mcp

__all__ = ["main", "mcp"]
