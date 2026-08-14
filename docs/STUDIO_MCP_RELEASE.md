# Studio MCP release gate

1. Load the built plugin in a blank test place.
2. Run audit: expect missing defaults/runtime findings.
3. Install; verify `ReplicatedStorage.LiveOpsDefaults` and `ServerScriptService.LiveOpsRuntime` exist and undo works.
4. Audit again; required config/kill-switch/messaging checks must pass.
5. Start Play. If Experience Configs are absent, runtime must retain safe defaults without fatal errors.
6. Use MCP `execute_luau` in Server context to inspect `LiveOpsEvent` and verify it exists after runtime start.
7. Exercise `request_state` from a client and confirm a state response is emitted.
8. Do not use production Open Cloud messaging during automated QA. Test live messaging only in an isolated universe/topic.
9. Capture console output and screenshot. Any plugin/runtime exception is a hard fail.
10. Three consecutive failed repairs quarantine the release.
