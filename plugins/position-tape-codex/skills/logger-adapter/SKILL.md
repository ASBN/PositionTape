---
name: position-tape-logger-adapter
description: Create thin logger integrations such as Serilog, Pino, Python logging, Logback, slog, tracing or spdlog for PositionTape diagnostics.
---

# PositionTape logger adapter skill

Use this skill when building logger plugins/adapters.


Always obey AGENTS.md and docs/agentic-plan/APPROVALS_AND_PERMISSIONS.md. Stay inside the repository. Update AGENT_RUN_LOG.md after each checkpoint. Use fixtures as the source of truth.


## Design principle

Logger adapters must stay thin. The core algorithm belongs in `languages/<language>/` or a core package. The adapter should only provide idiomatic ways to emit or attach a tape and examples for detecting truncation.

## Preferred integration types

- C# Serilog: enricher/helper, not a sink.
- Microsoft.Extensions.Logging: extension/helper.
- JS/TS Pino/Winston: helper/mixin/transport example.
- Python logging: formatter/filter/helper.
- Java: SLF4J/Logback/Log4j2 helper.
- Go: slog Attr helper.
- Rust: tracing field helper.

## Must include

- README.
- Minimal example.
- Automated truncation test if toolchain exists.
- No publishing without approval.
