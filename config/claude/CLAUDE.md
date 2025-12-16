# Claude Code Standards

Global coding standards and preferences for all projects.

## Context7 Integration

Always use Context7 when I need code generation, setup or configuration steps, or library/API documentation. This means you should automatically use the Context7 MCP tools to resolve library id and get library docs without me having to explicitly ask.

## Code Style

### General

- Use consistent indentation (4 spaces for Python/Shell, 2 spaces for JS/TS/YAML/JSON)
- Maximum line length: 100 characters (prefer 80 for comments)
- Use meaningful variable and function names
- Prefer explicit over implicit code
- Add comments only when the code isn't self-explanatory

### Git Commits

- Use conventional commit format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, test, chore
- Keep subject line under 72 characters
- Use imperative mood ("Add feature" not "Added feature")

### Documentation

- Document public APIs and complex functions
- Use docstrings for Python (Google style)
- Use JSDoc for JavaScript/TypeScript
- Keep README files up to date

## Language-Specific

### Python

- Follow PEP 8
- Use type hints for function signatures
- Use f-strings for string formatting
- Prefer pathlib over os.path

### JavaScript/TypeScript

- Use ES6+ features
- Prefer const over let, avoid var
- Use async/await over .then() chains
- Use strict TypeScript settings

### Shell/Bash

- Use shellcheck-compliant code
- Quote variables: "$VAR" not $VAR
- Use [[ ]] over [ ] for conditionals
- Set -euo pipefail at script start

### Go

- Follow effective Go guidelines
- Use gofmt for formatting
- Handle errors explicitly
- Use meaningful package names

## Project Structure

- Keep related files together
- Separate concerns (src, tests, docs, config)
- Use consistent naming conventions across the project
- Include .gitignore, README, and LICENSE in all repos

## Testing

- Write tests for new features
- Maintain test coverage above 80%
- Use descriptive test names
- Test edge cases and error conditions

## Security

- Never commit secrets or credentials
- Use environment variables for sensitive data
- Validate all user inputs
- Keep dependencies updated

## Preferences

- Prefer simple solutions over clever ones
- Refactor when code becomes unclear
- Ask clarifying questions before making assumptions
- Suggest improvements when reviewing code
