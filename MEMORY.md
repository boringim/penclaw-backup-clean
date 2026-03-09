# Long-term Memory

## Backup System (Finalized 2026-03-09)

Fully automated two-tier backup system for OpenClaw workspace.

### Tier 1: Git (Hourly)
- Repository: `penclaw-backup-clean` (SSH)
- Script: `backup-git.ps1`
- Whitelist approach: AGENTS.md, HEARTBEAT.md, IDENTITY.md, SOUL.md, TOOLS.md, USER.md, memory/, scripts/, backup scripts themselves
- Runs as SYSTEM via Scheduled Task `OpenClaw\Backup-Git`
- Status: Working

### Tier 2: File-level (3x daily at 00:00, 08:00, 16:00)
- Script: `scripts\backup-robocopy.ps1`
- Structure:
  - `C:\Users\Administrator\backups\openclaw\openclaw-home\` (mirror of `.openclaw`, excludes nested workspaces)
  - `C:\Users\Administrator\backups\openclaw\workspace\oc-981e-isolated\` (workspace files)
  - Snapshots: rolling 7-day ZIP archives
- Runs as Administrator
- Exclusions: `workspace`, `workspaces`, `node_modules`, `.git`, `__pycache__`, `*.log`, `*.tmp`, `*.lock`
- Database backup: optional `backup-db.js` (sqlite3) - continues on failure
- Status: Working

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
