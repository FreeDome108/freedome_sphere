---
description: Подключить GitHub MCP (Actions) из mcp_github_actions.json и использовать инструменты для workflow runs, логов и запуска.
tools: ['github/github-mcp-server/actions_list', 'github/github-mcp-server/actions_get', 'github/github-mcp-server/actions_run_trigger', 'github/github-mcp-server/get_job_logs']
---

## Цель

Прочитать конфиг из `.cursor/mcp_github_actions.json` и подключить этот MCP.

## Шаги

1. **Прочитать** `.cursor/mcp_github_actions.json` (если файла нет — взять за основу `.cursor/mcp_github_actions.json.example`).

2. **Подключить MCP c прочитанной конфигурацией**:

3. После подключения использовать инструменты GitHub Actions (workflow runs, логи, запуск и т.д.) для выполнения запроса пользователя.

## User Input

```text
$ARGUMENTS
```

Учесть ввод пользователя (если не пустой).
