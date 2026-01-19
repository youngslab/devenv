# Global Claude Code Instructions

## User Profile

**User:** kevin.park
**Primary Languages:** C++, Python, Bash
**Work Context:** Sonatus - Automotive Software Development

---

## Universal Behavior Rules

### Communication
- Always respond in the same language as the user's query
- Use technical terminology appropriate for senior developers
- Provide concise answers; elaborate only when requested

### Code Standards
- Follow project-specific coding standards when available
- Default to Google C++ Style Guide for C++ code
- Use conventional commits format: `type(scope): description`

### Git Workflow
- **ALWAYS use `/x:commit` skill when user requests a commit** (e.g., "commit 해줘", "커밋 작성해줘", "create a commit")
- **ALWAYS use `/x:pr` skill when user requests a PR** (e.g., "PR 만들어줘", "PR 생성해줘", "create a PR")
- Do NOT use raw `git commit` or `gh pr create` commands directly - invoke the skills instead
- Branch names should match ticket numbers when applicable
- Always run formatters before committing

### Code Review Focus
- Memory management (leaks, dangling pointers)
- Error handling completeness
- Thread safety concerns
- Performance implications

---

## Tool Preferences

### Jira Integration
- Default assignee: kevin.park
- Default language: English
- Use natural sentences for descriptions (avoid bullet lists in Action Items)

### GitHub
- PR titles: `[TICKET-ID] Concise description`
- Maximum 100 lines for PR descriptions

---

## Project-Specific Instructions

Project-specific instructions are defined in each repository's `CLAUDE.md`.
This global file provides defaults that can be overridden at the project level.
