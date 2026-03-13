# Contributing to Test Automation Monitor

Thank you for your interest in contributing to **Test Automation Monitor**! This guide covers everything you need to know to create new skills, improve existing ones, and submit changes.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Create a New Skill](#how-to-create-a-new-skill)
- [SKILL.md Structure](#skillmd-structure)
- [Frontmatter Reference](#frontmatter-reference)
- [Writing Skill Instructions](#writing-skill-instructions)
- [Testing Your Skill](#testing-your-skill)
- [Adding Templates](#adding-templates)
- [Adding Scripts](#adding-scripts)
- [Pull Request Guidelines](#pull-request-guidelines)
- [Reporting Issues](#reporting-issues)

---

## Code of Conduct

By participating in this project, you agree to:

- Be respectful and constructive in all interactions
- Welcome newcomers and help them get started
- Focus on the technical merits of contributions
- Accept constructive criticism gracefully
- Prioritize the community's best interests

---

## Getting Started

1. **Fork** the repository on GitHub
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/<your-username>/test-automation-monitor.git
   cd test-automation-monitor
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/my-new-skill
   ```
4. **Open in Claude Code** to test your skills interactively:
   ```bash
   claude
   ```

---

## How to Create a New Skill

Each skill is a self-contained folder inside `.claude/skills/` with a `SKILL.md` file. That's it — no build step, no compilation. Claude Code reads the Markdown and follows the instructions.

### Step-by-step

1. **Create the skill folder**:
   ```bash
   mkdir -p .claude/skills/my-skill
   ```

2. **Create `SKILL.md`** inside it:
   ```bash
   touch .claude/skills/my-skill/SKILL.md
   ```

3. **Write the frontmatter and instructions** (see structure below)

4. **Test it** in Claude Code:
   ```
   > /my-skill
   ```

5. **Add templates** if needed (in `templates/`)

6. **Add helper scripts** if needed (in `scripts/`)

7. **Update documentation** (`CLAUDE.md`, `README.md`, `SKILLS.md`)

---

## SKILL.md Structure

Every `SKILL.md` file has two parts: **YAML frontmatter** (metadata) and **Markdown body** (instructions for Claude).

```markdown
---
name: my-skill
description: A clear description of when and how to use this skill. This text appears in Claude Code's skill list.
allowed-tools: Bash(npx *), Bash(node *), Read, Grep, Glob
user-invocable: true
argument-hint: <required-arg> [--optional-flag value]
---

# Skill Title

Brief explanation of what this skill does.

## Current Project Context

Dynamic context gathered at invocation time:
!`command that runs before Claude sees the prompt`

## Parse Arguments

- `$ARGUMENTS` = full argument string
- `$0` = first argument
- `$1` = second argument
- `--flag` = named flag

## Steps

1. **Step one**: What to do first
2. **Step two**: What to do next
3. **Step three**: Final step

## Output Format

Describe the expected output format (tables, summaries, etc.)

## Error Handling

- If X happens → do Y
- If Z fails → suggest W

## Related Skills

- `/other-skill` - When to use instead
```

---

## Frontmatter Reference

The YAML frontmatter between `---` markers defines the skill's metadata.

### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `name` | string | Skill identifier (becomes the slash command) | `my-skill` |
| `description` | string | When/how to use this skill (shown in skill list) | `Run database migrations and verify schema` |
| `allowed-tools` | string | Comma-separated list of tools Claude can use | `Bash(npx *), Read, Grep` |
| `user-invocable` | boolean | Whether users can invoke via `/name` | `true` |

### Optional Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `argument-hint` | string | Hint shown for expected arguments | `<file> [--verbose]` |
| `disable-model-invocation` | boolean | Prevent other skills from calling this one | `true` |

### `allowed-tools` Patterns

The `allowed-tools` field controls which Claude Code tools the skill can use. Use the **principle of least privilege** — only allow what's needed.

| Pattern | Meaning |
|---------|---------|
| `Bash(npx *)` | Can run any `npx` command |
| `Bash(node *)` | Can run any `node` command |
| `Bash(adb *)` | Can run any `adb` command |
| `Bash(curl *)` | Can run any `curl` command |
| `Bash(docker *)` | Can run any `docker` command |
| `Bash(*)` | Can run any bash command (use sparingly) |
| `Read` | Can read files |
| `Write` | Can create/overwrite files |
| `Grep` | Can search file contents |
| `Glob` | Can search for files by pattern |

**Example combinations**:
```yaml
# Minimal (read-only skill):
allowed-tools: Bash(ls *), Bash(cat *), Read, Grep, Glob

# Test runner skill:
allowed-tools: Bash(npx *), Bash(node *), Read, Grep, Glob

# File generator skill:
allowed-tools: Bash(node *), Bash(mkdir *), Read, Write, Grep, Glob
```

---

## Writing Skill Instructions

### Dynamic Context with `!`backticks`

Use `!`command`` to inject runtime information before Claude processes the prompt:

```markdown
## Current Project Context

Package.json scripts:
!`node -e "try{const p=require('./package.json');console.log(JSON.stringify(p.scripts,null,2))}catch{console.log('No package.json')}"`

Test files found:
!`node -e "const {execSync}=require('child_process');try{console.log(execSync('dir /s /b *.test.ts 2>nul',{encoding:'utf8'}).trim()||'No test files found')}catch{console.log('No test files found')}"`
```

> **Tip**: Wrap dynamic commands in `node -e` for cross-platform compatibility (Windows + macOS + Linux).

### Arguments with `$ARGUMENTS`

Access user-provided arguments in your instructions:

```markdown
## Parse Arguments

The user invoked: `/my-skill $ARGUMENTS`

- If `$ARGUMENTS` is empty → run all tests
- If `$ARGUMENTS` contains a file path → run that specific test
- If `$ARGUMENTS` contains `--verbose` → show detailed output
```

### Best Practices for Instructions

1. **Be explicit** — Claude follows instructions literally. Say "Run this command" not "You might want to run..."
2. **Handle errors** — Always include error handling: "If the command fails, check X and suggest Y"
3. **Format output** — Use ASCII tables, emoji status indicators (✓ / ✗), and clear summaries
4. **Cross-platform** — Test on both Windows and macOS/Linux. Use `node -e` instead of shell-specific commands when possible
5. **Show related skills** — Help users discover other useful skills

---

## Testing Your Skill

### Manual Testing

1. Open Claude Code in the project directory
2. Type `/your-skill` with various argument combinations
3. Test edge cases:
   - No arguments
   - Invalid arguments
   - Missing prerequisites
   - No matching files

### Testing Checklist

- [ ] Skill appears in `/` autocomplete
- [ ] Description is clear and helpful
- [ ] Works with no arguments (if applicable)
- [ ] Works with all documented arguments
- [ ] Error messages are helpful
- [ ] Output is well-formatted
- [ ] Works on Windows (if applicable)
- [ ] Works on macOS/Linux (if applicable)
- [ ] Dynamic context (`!``) commands don't fail silently

---

## Adding Templates

If your skill needs template files, add them to the `templates/` directory.

### Naming Conventions

| Test Type | File Pattern | Example |
|-----------|-------------|---------|
| Web (Playwright) | `sample.spec.ts` | `templates/sample.spec.ts` |
| Mobile (WDIO) | `sample.mobile.ts` | `templates/sample.mobile.ts` |
| Performance (k6) | `sample.k6.js` | `templates/sample.k6.js` |
| API | `sample.api.ts` | `templates/sample.api.ts` |
| Unit | `sample.unit.test.ts` | `templates/sample.unit.test.ts` |
| Cypress | `sample.cy.ts` | `templates/sample.cy.ts` |
| Visual | `sample.visual.ts` | `templates/sample.visual.ts` |
| Config | `<framework>.config.ts` | `templates/cypress.config.ts` |
| CI/CD | `<platform>.yml` | `templates/ci/github-actions.yml` |

---

## Adding Scripts

Helper scripts go in the `scripts/` directory.

### Guidelines

- Prefer **Bash** (`.sh`) for Unix and **PowerShell** (`.ps1`) for Windows
- Scripts should be idempotent (safe to run multiple times)
- Output JSON when possible for easy parsing
- Include error handling with meaningful messages
- Add a comment header explaining what the script does

### Naming Convention

```
scripts/parse-<framework>-results.sh   # Result parsers
scripts/check-<tool>.sh                # Environment checks
```

---

## Pull Request Guidelines

### Before Submitting

1. **Test your changes** thoroughly in Claude Code
2. **Update documentation**:
   - Add your skill to `CLAUDE.md` under the appropriate category
   - Add your skill to `README.md` in the skills table
   - Add full documentation to `SKILLS.md`
   - Update `AI-AGENT-GUIDE.md` if applicable
3. **Follow conventions**:
   - Skill names use kebab-case: `my-skill`, not `mySkill`
   - Test files follow the naming patterns in `CLAUDE.md`
   - Templates go in `templates/`, scripts in `scripts/`
4. **Run the docs generator** to verify your frontmatter:
   ```bash
   node scripts/generate-docs.js
   ```

### PR Template

```markdown
## What does this PR do?

Brief description of the changes.

## Skill(s) added/modified

- `/skill-name` — What it does

## Checklist

- [ ] SKILL.md has valid frontmatter (name, description, allowed-tools, user-invocable)
- [ ] Skill tested in Claude Code with various inputs
- [ ] Error handling included for common failure cases
- [ ] Templates added (if applicable)
- [ ] Helper scripts added (if applicable)
- [ ] CLAUDE.md updated
- [ ] README.md updated
- [ ] SKILLS.md updated
- [ ] Cross-platform compatible (or documented as platform-specific)
```

### Commit Message Format

Use clear, descriptive commit messages:

```
feat: add /my-skill for database migration testing
fix: correct cross-platform path handling in /run-test
docs: update SKILLS.md with /my-skill reference
chore: add sample template for migration tests
```

---

## Reporting Issues

When reporting a bug, please include:

1. **Skill name**: Which `/skill` command was used
2. **Arguments**: What arguments were passed
3. **Environment**: OS, Node.js version, Claude Code version
4. **Expected behavior**: What should have happened
5. **Actual behavior**: What actually happened
6. **Error output**: Full error messages or screenshots

---

## Questions?

- Open a [GitHub Issue](https://github.com/thanhdaocam/test-automation-monitor/issues)
- Check the [SKILLS.md](SKILLS.md) for detailed skill documentation
- Check the [USER-GUIDE.md](USER-GUIDE.md) for usage examples

Thank you for contributing!
