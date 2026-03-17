# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Browser

- Preferred automation browser: Google Chrome
- Preferred OpenClaw browser profile: `google-auto`
- Purpose: dedicated persistent automation profile for plugin retention and login persistence
- User data dir: `C:\Users\Administrator\.openclaw\browser\google-auto\user-data`
- Guidance: when browser actions do not specifically require the user's live tab/session, prefer `profile="google-auto"`
- Note: this profile is separate from the user's everyday Chrome profile to reduce contamination/risk while preserving extensions and site sessions

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.
