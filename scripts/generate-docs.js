#!/usr/bin/env node

/**
 * generate-docs.js
 *
 * Auto-generate a skills reference table from SKILL.md frontmatter.
 * Reads all .claude/skills/<name>/SKILL.md files, parses YAML frontmatter,
 * and outputs a Markdown table.
 *
 * Usage:
 *   node scripts/generate-docs.js              # Print to stdout
 *   node scripts/generate-docs.js --output     # Write to SKILLS-TABLE.md
 *
 * Uses only Node.js built-ins (fs, path).
 */

const fs = require('fs');
const path = require('path');

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const SKILLS_DIR = path.join(__dirname, '..', '.claude', 'skills');
const OUTPUT_FILE = path.join(__dirname, '..', 'SKILLS-TABLE.md');

// Category mapping based on known skill groupings
const CATEGORY_MAP = {
  // Core Testing (v1.0)
  'setup-test-env': { category: 'Core', version: '1.0' },
  'devices':        { category: 'Core', version: '1.0' },
  'appium':         { category: 'Core', version: '1.0' },
  'install-apk':    { category: 'Core', version: '1.0' },
  'run-test':       { category: 'Core', version: '1.0' },
  'mobile-test':    { category: 'Core', version: '1.0' },
  'test-report':    { category: 'Core', version: '1.0' },
  'monitor':        { category: 'Core', version: '1.0' },
  'scaffold-test':  { category: 'Core', version: '1.0' },

  // Extended Testing (v2.0)
  'api-test':       { category: 'Extended', version: '2.0' },
  'unit-test':      { category: 'Extended', version: '2.0' },
  'db-test':        { category: 'Extended', version: '2.0' },
  'cypress-test':   { category: 'Extended', version: '2.0' },
  'flutter-test':   { category: 'Extended', version: '2.0' },
  'rn-test':        { category: 'Extended', version: '2.0' },
  'visual-test':    { category: 'Extended', version: '2.0' },
  'contract-test':  { category: 'Extended', version: '2.0' },
  'smoke-test':     { category: 'Extended', version: '2.0' },

  // Quality & Security (v2.0)
  'security-test':  { category: 'Quality & Security', version: '2.0' },
  'a11y-test':      { category: 'Quality & Security', version: '2.0' },
  'lighthouse':     { category: 'Quality & Security', version: '2.0' },

  // DevOps & Utilities (v2.0)
  'ci-gen':         { category: 'DevOps', version: '2.0' },
  'docker-test':    { category: 'DevOps', version: '2.0' },
  'notify':         { category: 'DevOps', version: '2.0' },
  'test-data':      { category: 'DevOps', version: '2.0' },
};

// ---------------------------------------------------------------------------
// Frontmatter parser (simple key: value YAML — no external deps)
// ---------------------------------------------------------------------------

function parseFrontmatter(content) {
  const fm = {};
  const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!match) return fm;

  const lines = match[1].split(/\r?\n/);
  for (const line of lines) {
    const idx = line.indexOf(':');
    if (idx === -1) continue;
    const key = line.slice(0, idx).trim();
    let value = line.slice(idx + 1).trim();
    // Remove surrounding quotes if present
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    fm[key] = value;
  }
  return fm;
}

// ---------------------------------------------------------------------------
// Truncate description to a readable length
// ---------------------------------------------------------------------------

function truncateDescription(desc, maxLen) {
  if (!desc) return '—';
  // Take first sentence (up to first period followed by space or end)
  const firstSentence = desc.match(/^[^.]*\./);
  const text = firstSentence ? firstSentence[0] : desc;
  if (text.length <= maxLen) return text;
  return text.slice(0, maxLen - 1) + '…';
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

function main() {
  const writeToFile = process.argv.includes('--output');

  // 1. Discover skill directories
  let skillDirs;
  try {
    skillDirs = fs.readdirSync(SKILLS_DIR, { withFileTypes: true })
      .filter(d => d.isDirectory())
      .map(d => d.name)
      .sort();
  } catch (err) {
    console.error(`Error: Cannot read skills directory at ${SKILLS_DIR}`);
    console.error(err.message);
    process.exit(1);
  }

  if (skillDirs.length === 0) {
    console.error('Error: No skill directories found.');
    process.exit(1);
  }

  // 2. Parse each SKILL.md
  const skills = [];
  const errors = [];

  for (const dir of skillDirs) {
    const skillPath = path.join(SKILLS_DIR, dir, 'SKILL.md');
    if (!fs.existsSync(skillPath)) {
      errors.push(`Warning: ${dir}/SKILL.md not found, skipping.`);
      continue;
    }

    const content = fs.readFileSync(skillPath, 'utf-8');
    const fm = parseFrontmatter(content);

    if (!fm.name) {
      errors.push(`Warning: ${dir}/SKILL.md has no 'name' in frontmatter, skipping.`);
      continue;
    }

    const meta = CATEGORY_MAP[fm.name] || { category: 'Other', version: '—' };

    skills.push({
      name: fm.name,
      description: fm.description || '—',
      argumentHint: fm['argument-hint'] || '',
      category: meta.category,
      version: meta.version,
    });
  }

  // 3. Print warnings to stderr
  for (const err of errors) {
    console.error(err);
  }

  // 4. Sort by category order, then by name
  const categoryOrder = ['Core', 'Extended', 'Quality & Security', 'DevOps', 'Other'];
  skills.sort((a, b) => {
    const catA = categoryOrder.indexOf(a.category);
    const catB = categoryOrder.indexOf(b.category);
    if (catA !== catB) return catA - catB;
    return a.name.localeCompare(b.name);
  });

  // 5. Generate Markdown
  const lines = [];
  lines.push('# Skills Reference Table');
  lines.push('');
  lines.push(`> Auto-generated by \`scripts/generate-docs.js\` — ${new Date().toISOString().split('T')[0]}`);
  lines.push(`> **${skills.length} skills** found in \`.claude/skills/\``);
  lines.push('');
  lines.push('| # | Skill | Description | Category | Version |');
  lines.push('|---|-------|-------------|----------|---------|');

  skills.forEach((skill, idx) => {
    const num = String(idx + 1).padStart(2, ' ');
    const cmd = `\`/${skill.name}\``;
    const desc = truncateDescription(skill.description, 100);
    lines.push(`| ${num} | ${cmd} | ${desc} | ${skill.category} | v${skill.version} |`);
  });

  lines.push('');

  // 6. Category summary
  const categoryCounts = {};
  for (const s of skills) {
    categoryCounts[s.category] = (categoryCounts[s.category] || 0) + 1;
  }

  lines.push('## Summary');
  lines.push('');
  lines.push('| Category | Count |');
  lines.push('|----------|-------|');
  for (const cat of categoryOrder) {
    if (categoryCounts[cat]) {
      lines.push(`| ${cat} | ${categoryCounts[cat]} |`);
    }
  }
  lines.push(`| **Total** | **${skills.length}** |`);
  lines.push('');

  const output = lines.join('\n');

  // 7. Output
  if (writeToFile) {
    fs.writeFileSync(OUTPUT_FILE, output, 'utf-8');
    console.log(`Skills table written to ${OUTPUT_FILE}`);
    console.log(`${skills.length} skills documented across ${Object.keys(categoryCounts).length} categories.`);
  } else {
    console.log(output);
  }
}

main();
