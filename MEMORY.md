# Long-term Memory

## Backup System (Finalized 2026-03-09)

Fully automated two-tier backup system for OpenClaw workspace.

### Tier 1: Git (Hourly)
- Repository: `penclaw-backup-clean` (SSH)
- Script: `backup-git.ps1`
- Whitelist: AGENTS.md, HEARTBEAT.md, IDENTITY.md, SOUL.md, TOOLS.md, USER.md, MEMORY.md, memory/, scripts/, backup scripts
- Runs as **Administrator** via Scheduled Task `OpenClaw\Backup-Git`
- Database backup: optional `backup-db.js` (sqlite3) - continues on failure
- Status: Working

### Tier 2: File-level (3x daily at 00:00, 08:00, 16:00)
- Script: `scripts\backup-robocopy.ps1`
- Structure:
  - `C:\Users\Administrator\backups\openclaw\openclaw-home\` (mirror of `.openclaw`, excludes nested workspaces)
  - `C:\Users\Administrator\backups\openclaw\workspace\oc-981e-isolated\` (workspace files)
  - Snapshots: rolling 7-day ZIP archives
- Runs as Administrator (tasks: `Backup-FileLevel-0000`, `-0800`, `-1600`)
- Exclusions: `workspace`, `workspaces`, `node_modules`, `.git`, `__pycache__`, `*.log`, `*.tmp`, `*.lock`
- Database backup: `backup-db.js` (sqlite3) - best effort, continues on failure
- Status: Working

### Health Monitoring
- Script: `scripts\check-backup-health.ps1`
- Runs: 08:00, 12:00, 20:00 daily (tasks: `Backup-Monitor-0800/1200/2000`)
- Reports: Logs to `backup-health.log` and attempts to send to OpenClaw session

### Key Decisions
- SSH auth over HTTPS (no credential manager)
- Whitelist over blacklist (track only essentials)
- Continue-on-DB-failure (file backups proceed)
- Hardcoded paths (no .env dependency for Tier 2)
- Exclude session locks to avoid snapshot failures

### Recovery Scripts
All backup scripts are stored in both the workspace and the Git backup repository for disaster recovery.

## Workspace
- Location: `C:\Users\Administrator\.openclaw\workspaces\oc-981e-isolated`
- Main session agent: group-oc-981e

## Memory Plugin: LanceDB Pro (Installed 2026-03-10)

### Installation Summary
- **Plugin**: `memory-lancedb-pro@1.1.0-beta.6`
- **Source**: https://github.com/win4r/memory-lancedb-pro
- **Install Date**: 2026-03-10
- **Status**: ✅ Loaded and operational

### Configuration
- **Embedding**: Jina AI `jina-embeddings-v5-text-small` (1024 dims)
  - API Key: `${JINA_API_KEY}`
  - Base URL: `https://api.jina.ai/v1`
  - Normalized: true
- **Retrieval**: Hybrid (vector 0.7 + BM25 0.3)
- **Reranker**: Jina Reranker v3 (`jina-reranker-v3`)
- **Auto-Capture**: true (regex-triggered, no LLM)
- **Auto-Recall**: true
- **Session Strategy**: `systemSessionMemory`
- **Database**: `~/.openclaw/memory/lancedb-pro`

### Features Confirmed
- ✅ Plugin loads without errors
- ✅ BM25 full-text search functional
- ✅ Mixed retrieval works (tested)
- ✅ FTS index enabled
- ✅ CLI commands available: `memory-pro stats`, `list`, `search`, `reembed`, etc.
- ✅ Auto-capture active (captures system messages)
- ✅ Backup system integrated (working)

### Limitations
- ⚠️ LLM smart extraction (`smartExtraction`) not supported in current schema (v1.1.0-beta.6)
- ⚠️ Old memories (created during misconfiguration) have empty `vector` field
- ✅ BM25 retrieval unaffected; new memories will have proper embeddings

### Lessons Learned (Dual-Layer存储)

**Technical Pitfall**:
- Pitfall: Initially added `smartExtraction`, `llm`, `decay`, `tier` fields to config, causing plugin load failure.
- Cause: Those fields not in plugin's `openclaw.plugin.json` schema. Schema validation rejects unknown properties.
- Fix: Removed all non-schema fields, kept only documented properties under `embedding`, `retrieval`, `autoCapture`, `autoRecall`, `sessionStrategy`, `scopes`, `memoryReflection`, `mdMirror`, `selfImprovement`.
- Prevention: Always read plugin's `openclaw.plugin.json` configSchema before adding custom fields. Never add fields not explicitly defined in `properties`.

**Principle**: Configuration must strictly adhere to plugin schema. Additional properties = rejection.

**Operational Tip**:
- After config changes, use `openclaw gateway restart` and check `openclaw plugins info <plugin>` for `Status: loaded`.
- If vector empty on old entries, use `memory-pro reembed --source-db <path>` to regenerate embeddings with correct model.

### Next Steps
- Let plugin auto-capture new conversations
- Periodically verify retrieval quality
- Monitor backup health (already automated)
- Update to newer plugin version when LLM extraction becomes available
