from pathlib import Path

root = Path(__file__).resolve().parents[1]
required = [root / "src/Main.server.luau", root / "src/Modules/Audit.luau", root / "src/Modules/Installer.luau", root / "default.project.json"]
for path in required:
    assert path.exists() and path.stat().st_size > 150, f"missing/incomplete {path}"

installer = (root / "src/Modules/Installer.luau").read_text(encoding="utf-8")
for token in ["ConfigService", "GetConfigAsync", "kill_switch", "MessagingService", "SubscribeAsync", "liveops-command-v1"]:
    assert token in installer, token
assert "x-api-key" not in installer.lower(), "plugin must never embed Open Cloud credentials"
assert ".ROBLOSECURITY" not in installer
print("LiveOps Autopilot static checks passed")
