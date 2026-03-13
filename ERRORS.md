# ERRORS.md - Error Log and Learning

This file records significant errors, issues, and lessons learned in this workspace.

## Purpose
- Document critical errors and their solutions
- Track recurring issues
- Capture learnings for future reference
- Share knowledge across sessions

## Format
- **Date**: YYYY-MM-DD
- **Error**: Brief description of what went wrong
- **Cause**: Root cause analysis
- **Fix**: How it was resolved
- **Prevention**: How to avoid in the future

## Active Issues
*(None currently)*

## Resolved Issues
**2026-03-11** - Agent not responding in Feishu group
- **Error**: Agent in group chat (ou_953a1433897c2f87a809cba4793fb94b) not replying to messages
- **Cause**: BOOTSTRAP.md file existed in workspace, causing agent to boot into initialization mode instead of loading existing config
- **Fix**: Removed BOOTSTRAP.md file from workspace
- **Prevention**: Ensure BOOTSTRAP.md is deleted after first-run configuration

---

_Last updated: 2026-03-11_
