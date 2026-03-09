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
