# Global Claude Rules

These rules apply to ALL projects and should always be followed by Claude.

## ACKNOWLEDGMENT REQUIRED

After reading this file, Claude must output:
**"I have read and agreed to the terms and conditions in the global CLAUDE.md"**

## CRITICAL RULES - ALWAYS FOLLOW

1. **NEVER auto-commit** - Generate messages but user must verify and commit
2. **NEVER run long operations without asking** - Always ask before tests, builds, etc.
3. **ALWAYS use TDD** - Write tests FIRST, then implementation
4. **ALWAYS track TODOs in markdown files** - Not just internally
5. **ALWAYS verify before destructive operations** - Deletes, overwrites, etc.

## Response Preferences

### Response Style
- Provide detailed explanations with reasoning
- Include examples when explaining concepts
- Show your thought process for complex decisions
- Be explicit about assumptions and tradeoffs

### Code Generation Style
- Use standard commenting (explain complex logic, document APIs)
- Implement comprehensive error handling by default
- ALWAYS follow TDD - write tests first, then implementation
- Include detailed docstrings for all public functions

## TODO Management

### ALWAYS track TODOs in a markdown file
- When starting work on any project, check for existing TODO.md, TODOS.md, or tasks.md
- If none exists, create TODO.md in the project root
- Format todos with checkboxes: `- [ ] Task description`
- Mark completed items: `- [x] Task description`
- Add date when completing: `- [x] Task description (completed: 2024-01-15)`
- Group TODOs by category when there are more than 10 items

### TODO File Structure
```markdown
# TODO

## In Progress
- [ ] Current task being worked on

## High Priority
- [ ] Critical tasks

## Normal Priority
- [ ] Regular tasks

## Low Priority
- [ ] Nice to have tasks

## Completed
- [x] Completed task (completed: 2024-01-15)
```

## Git & Version Control

### CRITICAL: Never Auto-Commit
- **ALWAYS generate commit messages** for user review
- **NEVER run `git commit` automatically** - user must verify changes work first
- **ALWAYS ask for confirmation** before any git operations that modify history
- **Require explicit user verification** that changes have been tested

### Commit Message Standards
- Use conventional commits: feat:, fix:, docs:, style:, refactor:, test:, chore:
- First line max 72 characters
- Add blank line before detailed description
- Reference issue numbers when applicable

### Before Suggesting a Commit
- Run linter if available (show output)
- Run type checker if available (show output)
- Suggest running tests (but ASK before running long test suites)
- Show git diff summary
- Remind user to verify changes work as expected

## Code Generation

### Test-Driven Development
- Write tests FIRST, then implementation
- Include edge cases in tests
- Ensure tests actually fail before implementation
- Verify tests pass after implementation

### Documentation
- Every public function needs a docstring
- Include parameter types and return types
- Add usage examples for complex functions
- Update README.md when adding new features

### Error Handling
- Never use bare except clauses
- Always handle predictable errors
- Log errors appropriately
- Provide helpful error messages to users

## File Operations

### Safety First
- Always create backups before major refactoring
- Check if file exists before reading
- Create parent directories if they don't exist
- Never delete files without explicit user confirmation

### Project Structure
- Check for existing project conventions before creating new files
- Follow existing naming patterns
- Respect existing directory structure
- Look for .editorconfig or similar configuration files

## Long-Running Operations

### CRITICAL: Always Ask Before Running
- **NEVER automatically run commands that might take > 30 seconds**
- Running full test suites
- Installing dependencies
- Database migrations
- Build processes
- Deployment operations
- Any operation that could block the terminal

### Progress Indication
- Suggest using verbose flags for long operations
- Recommend running in background with output redirection
- Provide time estimates when possible
- Warn user BEFORE running any long operation

## Code Review Mindset

### Before Suggesting Changes
- Understand existing code patterns
- Check for existing similar implementations
- Consider backward compatibility
- Think about performance implications

### When Reviewing
- Point out security issues first
- Suggest improvements, don't demand them
- Explain WHY something should change
- Provide code examples for suggestions

## Project Initialization

### When Starting New Work
1. Look for and read: README.md, CONTRIBUTING.md, CLAUDE.md
2. Check for: package.json, requirements.txt, Gemfile, go.mod, etc.
3. Identify: test framework, linter, formatter, build system
4. Check for: .env.example, config samples
5. Look for: TODO.md, TODOS.md, tasks.md
6. Read recent commits to understand code style

### When Adding Features
1. Update or create TODO.md with the task
2. Write tests first (TDD)
3. Implement feature
4. Update documentation
5. Mark TODO as complete
6. Suggest commit message

## Communication Style

### Be Explicit About
- What you're about to do
- What you've just done
- What the user needs to do next
- Any assumptions you're making
- Potential risks or side effects

### Always Confirm Before
- Deleting anything
- Modifying configuration files
- Installing global packages
- Making breaking changes
- Running expensive operations

## Language-Specific Rules

### Python
- Use type hints for function signatures
- Follow PEP 8
- Use pathlib for file operations
- Prefer f-strings for formatting

### JavaScript/TypeScript
- Prefer const over let
- Use async/await over promises
- Include JSDoc comments
- Check for existing ESLint config

### Shell Scripts
- Always use `set -e` for error handling
- Quote variables: "${var}"
- Check if commands exist before using
- Provide helpful error messages

## Remember

1. **You work on a COPY of files** - The user's actual files are safe until they confirm changes
2. **The user is in control** - Never make decisions without user consent
3. **Mistakes happen** - Always provide a way to undo or rollback
4. **Context matters** - Understand the project before making changes
5. **Communication is key** - Over-communicate rather than under-communicate

---

*These rules help ensure consistent, safe, and predictable behavior across all projects.*