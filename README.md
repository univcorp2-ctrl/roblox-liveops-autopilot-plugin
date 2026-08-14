# LiveOps Autopilot for Roblox Studio

A paid-plugin candidate that installs and audits a conservative LiveOps foundation built on Roblox Experience Configs and cross-server MessagingService.

## Outcome

- `kill_switch` and feature flags live in Experience Configs instead of hard-coded constants.
- Safe local defaults keep the game functional when cloud reads fail.
- Runtime refreshes ConfigService state periodically without a place republish.
- An Open Cloud Messaging publish to `liveops-command-v1` can request refresh or send a bounded announcement to live servers.
- No API keys, tokens, or cookies are stored in the plugin or game source.

## Default keys

- `kill_switch` — boolean, default false.
- `feature_event_enabled` — boolean, default false.
- `event_multiplier` — number, default 1.
- `event_name` — string.
- `announcement` — string.

Create matching Experience Configs in Creator Hub/Studio and publish them through Roblox's config workflow. The scaffold remains safe if they do not exist yet.

## Build

```bash
rojo build default.project.json -o LiveOpsAutopilot.rbxm
```

## Commercial wedge

The promise is **install a production-shaped feature-flag, kill-switch and live-announcement foundation in minutes**, avoiding bespoke LiveOps plumbing in every experience.
