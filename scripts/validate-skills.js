#!/usr/bin/env node

// SKILL.md YAML Schema Validator
//
// Validates all .claude/skills/<name>/SKILL.md files for:
// - Required YAML frontmatter fields (name, description, version)
// - Valid version format (semver: X.Y.Z)
// - Required markdown sections (headings, error recovery, related skills)
// - Consistency checks across all skills
//
// Exit codes:
//   0 = all skills pass validation
//   1 = one or more skills failed validation
//
// Usage: node scripts/validate-skills.js [--verbose]

const fs = require('fs');
const path = require('path');

// ──────────────────────────────────────────────────────────────
// Configuration
// ──────────────────────────────────────────────────────────────

const SKILLS_DIR = path.join(__dirname, '..', '.claude', 'skills');
const VERBOSE = process.argv.includes('--verbose');

// Required frontmatter fields (errors if missing)
const REQUIRED_FRONTMATTER = ['name', 'description', 'version'];

// Optional frontmatter fields (no error, just tracked)
const KNOWN_FRONTMATTER = [
  'name', 'description', 'version', 'allowed-tools',
  'user-invocable', 'argument-hint', 'disable-model-invocation'
];

// Semver regex: X.Y.Z where X, Y, Z are non-negative integers
const SEMVER_REGEX = /^\d+\.\d+\.\d+$/;

// Required section patterns (checked in heading text, case-insensitive)
const REQUIRED_SECTIONS = {
  'steps_or_instructions': {
    patterns: ['step', 'bước', 'lệnh', 'command', 'action', 'instruction'],
    level: 'error',
    message: 'Must have at least one ## heading for steps/instructions'
  },
  'error_recovery': {
    patterns: ['error', 'troubleshoot', 'recovery', 'xử lý lỗi', 'lỗi'],
    level: 'warning',
    message: 'Recommended: Add an error handling/recovery section'
  },
  'related_skills': {
    patterns: ['related', 'kỹ năng liên quan', 'liên quan'],
    level: 'warning',
    message: 'Recommended: Add a related skills section'
  }
};

// ──────────────────────────────────────────────────────────────
// YAML Frontmatter Parser (manual, no external deps)
// ──────────────────────────────────────────────────────────────

// Parse YAML frontmatter from a SKILL.md file content.
// Handles simple key: value pairs (no nested objects, arrays, or multiline).
// Returns { frontmatter: {}, body: string, hasFrontmatter: boolean }
function parseFrontmatter(content) {
  const lines = content.split('\n').map(l => l.replace(/\r$/, ''));

  // Must start with ---
  if (lines[0].trim() !== '---') {
    return { frontmatter: null, body: content, hasFrontmatter: false };
  }

  // Find the closing ---
  let endIndex = -1;
  for (let i = 1; i < lines.length; i++) {
    if (lines[i].trim() === '---') {
      endIndex = i;
      break;
    }
  }

  if (endIndex === -1) {
    return { frontmatter: null, body: content, hasFrontmatter: false };
  }

  // Parse key: value pairs from frontmatter block
  const frontmatter = {};
  for (let i = 1; i < endIndex; i++) {
    const line = lines[i];
    // Match key: value (first colon is the delimiter)
    const colonIndex = line.indexOf(':');
    if (colonIndex > 0) {
      const key = line.substring(0, colonIndex).trim();
      let value = line.substring(colonIndex + 1).trim();

      // Handle boolean values
      if (value === 'true') value = true;
      else if (value === 'false') value = false;

      frontmatter[key] = value;
    }
  }

  const body = lines.slice(endIndex + 1).join('\n');
  return { frontmatter, body, hasFrontmatter: true };
}

// ──────────────────────────────────────────────────────────────
// Markdown Section Analyzer
// ──────────────────────────────────────────────────────────────

// Extract all headings from markdown body.
// Returns array of { level: number, text: string, line: number }
function extractHeadings(body) {
  const headings = [];
  const lines = body.split('\n');

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].replace(/\r$/, '');
    const match = line.match(/^(#{1,6})\s+(.+)$/);
    if (match) {
      headings.push({
        level: match[1].length,
        text: match[2].trim(),
        line: i + 1
      });
    }
  }

  return headings;
}

// Check if any heading matches the given patterns (case-insensitive).
function hasMatchingHeading(headings, patterns) {
  return headings.some(h => {
    const lower = h.text.toLowerCase();
    return patterns.some(p => lower.includes(p.toLowerCase()));
  });
}

// ──────────────────────────────────────────────────────────────
// Skill Validator
// ──────────────────────────────────────────────────────────────

function validateSkill(skillDir) {
  const skillName = path.basename(skillDir);
  const filePath = path.join(skillDir, 'SKILL.md');
  const errors = [];
  const warnings = [];

  // Check file exists
  if (!fs.existsSync(filePath)) {
    errors.push('SKILL.md file not found');
    return { skillName, filePath, errors, warnings };
  }

  // Read file
  const content = fs.readFileSync(filePath, 'utf8');

  // ── Check 1: YAML Frontmatter exists ──
  const { frontmatter, body, hasFrontmatter } = parseFrontmatter(content);

  if (!hasFrontmatter || !frontmatter) {
    errors.push('Missing YAML frontmatter (content between --- markers)');
    return { skillName, filePath, errors, warnings };
  }

  // ── Check 2: Required frontmatter fields ──
  for (const field of REQUIRED_FRONTMATTER) {
    if (frontmatter[field] === undefined || frontmatter[field] === '') {
      errors.push(`Missing required frontmatter field: "${field}"`);
    }
  }

  // ── Check 3: Name matches directory ──
  if (frontmatter.name && frontmatter.name !== skillName) {
    warnings.push(`Frontmatter "name" (${frontmatter.name}) does not match directory name (${skillName})`);
  }

  // ── Check 4: Version format (semver) ──
  if (frontmatter.version !== undefined) {
    const versionStr = String(frontmatter.version);
    if (!SEMVER_REGEX.test(versionStr)) {
      errors.push(`Invalid version format: "${versionStr}" (expected semver X.Y.Z)`);
    }
  }

  // ── Check 5: Description is non-empty and meaningful ──
  if (frontmatter.description && String(frontmatter.description).length < 10) {
    warnings.push(`Description is very short (${String(frontmatter.description).length} chars)`);
  }

  // ── Check 6: Unknown frontmatter fields ──
  for (const key of Object.keys(frontmatter)) {
    if (!KNOWN_FRONTMATTER.includes(key)) {
      warnings.push(`Unknown frontmatter field: "${key}" (not in known schema)`);
    }
  }

  // ── Check 7: Required markdown sections ──
  const headings = extractHeadings(body);

  if (headings.length === 0) {
    errors.push('No markdown headings found in body (expected at least one ## heading)');
  }

  // Check for steps/instructions heading (at least one ## level heading)
  const hasLevel2Heading = headings.some(h => h.level === 2);
  if (!hasLevel2Heading) {
    errors.push(REQUIRED_SECTIONS.steps_or_instructions.message);
  }

  // Check for error recovery section
  if (!hasMatchingHeading(headings, REQUIRED_SECTIONS.error_recovery.patterns)) {
    warnings.push(REQUIRED_SECTIONS.error_recovery.message);
  }

  // Check for related skills section
  if (!hasMatchingHeading(headings, REQUIRED_SECTIONS.related_skills.patterns)) {
    warnings.push(REQUIRED_SECTIONS.related_skills.message);
  }

  // ── Check 8: Body is non-empty ──
  if (body.trim().length < 50) {
    warnings.push('Markdown body is very short (less than 50 characters)');
  }

  return { skillName, filePath, errors, warnings };
}

// ──────────────────────────────────────────────────────────────
// Main Execution
// ──────────────────────────────────────────────────────────────

function main() {
  console.log('');
  console.log('═══════════════════════════════════════════════════════════');
  console.log('  SKILL.md Schema Validator');
  console.log('  Scanning: .claude/skills/*/SKILL.md');
  console.log('═══════════════════════════════════════════════════════════');
  console.log('');

  // Discover all skill directories
  if (!fs.existsSync(SKILLS_DIR)) {
    console.error(`ERROR: Skills directory not found: ${SKILLS_DIR}`);
    process.exit(1);
  }

  const skillDirs = fs.readdirSync(SKILLS_DIR)
    .map(name => path.join(SKILLS_DIR, name))
    .filter(dir => {
      try {
        return fs.statSync(dir).isDirectory();
      } catch {
        return false;
      }
    })
    .sort();

  console.log(`Found ${skillDirs.length} skill directories\n`);

  // Validate each skill
  const results = skillDirs.map(dir => validateSkill(dir));

  // Display results
  let totalErrors = 0;
  let totalWarnings = 0;
  let passCount = 0;
  let failCount = 0;

  for (const result of results) {
    const hasErrors = result.errors.length > 0;
    const hasWarnings = result.warnings.length > 0;
    const status = hasErrors ? '✗ FAIL' : '✓ PASS';
    const icon = hasErrors ? '✗' : '✓';

    if (hasErrors) {
      failCount++;
    } else {
      passCount++;
    }

    totalErrors += result.errors.length;
    totalWarnings += result.warnings.length;

    // Always show status line
    console.log(`  ${icon} ${result.skillName}`);

    // Show errors
    for (const err of result.errors) {
      console.log(`    ✗ ERROR: ${err}`);
    }

    // Show warnings (in verbose mode or if there are errors)
    if (VERBOSE || hasErrors) {
      for (const warn of result.warnings) {
        console.log(`    ⚠ WARNING: ${warn}`);
      }
    }
  }

  // Summary
  console.log('');
  console.log('──────────────────────────────────────────────────────────');
  console.log(`  Skills:   ${results.length} total`);
  console.log(`  Passed:   ${passCount}`);
  console.log(`  Failed:   ${failCount}`);
  console.log(`  Errors:   ${totalErrors}`);
  console.log(`  Warnings: ${totalWarnings}`);
  console.log('──────────────────────────────────────────────────────────');

  // Consistency check: collect all versions for reporting
  const versionMap = {};
  for (const result of results) {
    const dir = path.join(SKILLS_DIR, result.skillName, 'SKILL.md');
    try {
      const content = fs.readFileSync(dir, 'utf8');
      const { frontmatter } = parseFrontmatter(content);
      if (frontmatter && frontmatter.version) {
        const v = String(frontmatter.version);
        if (!versionMap[v]) versionMap[v] = [];
        versionMap[v].push(result.skillName);
      }
    } catch {}
  }

  console.log('');
  console.log('  Version Distribution:');
  for (const [ver, skills] of Object.entries(versionMap).sort()) {
    console.log(`    ${ver}: ${skills.length} skills (${skills.join(', ')})`);
  }

  console.log('');
  console.log('═══════════════════════════════════════════════════════════');

  if (failCount > 0) {
    console.log(`  RESULT: FAIL (${failCount} skill(s) have errors)`);
    console.log('═══════════════════════════════════════════════════════════');
    console.log('');
    process.exit(1);
  } else {
    console.log(`  RESULT: PASS (all ${passCount} skills validated successfully)`);
    console.log('═══════════════════════════════════════════════════════════');
    console.log('');
    process.exit(0);
  }
}

main();
