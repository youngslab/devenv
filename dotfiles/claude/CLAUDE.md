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
- Use `/x:commit` command for consistent commit formatting
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
