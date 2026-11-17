# Local AI agents

OpenCode is configured with two local agents using Ollama:

- `coder` uses `qwen2.5-coder:7b` for implementation.
- `auditor` uses `qwen3:8b` for read-only review.

Start `opencode` in the project directory and select `coder` for programming. The coder agent is instructed to run the audit script after changes. To request a separate audit manually, run this from PowerShell:

```powershell
.\Scripts\Audit-Agent.ps1 -Files 'Scripts\Script-Creacion-Tablas.sql' -Summary 'Describe the changes to the SQL schema'
```

The script supplies the files to the read-only auditor and appends its report, date, scope, and file list to `AUDIT.md`. Pass every changed file to `-Files`. Audit failures are reported and are not written as successful reviews.
