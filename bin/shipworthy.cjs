#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');
const readline = require('readline');

const VERSION = '1.0.0';
const SHIPWORTHY_DIR = '.shipworthy';

// --- Colors ---
const green = (s) => `\x1b[32m${s}\x1b[0m`;
const red = (s) => `\x1b[31m${s}\x1b[0m`;
const yellow = (s) => `\x1b[33m${s}\x1b[0m`;
const bold = (s) => `\x1b[1m${s}\x1b[0m`;
const dim = (s) => `\x1b[2m${s}\x1b[0m`;

// --- Helpers ---
function findPluginRoot() {
  // Find the shipworthy plugin directory (where this script lives)
  return path.resolve(__dirname, '..');
}

function detectAgent(projectDir) {
  if (fs.existsSync(path.join(projectDir, '.claude'))) return 'claude';
  if (fs.existsSync(path.join(projectDir, '.cursorrules'))) return 'cursor';
  if (fs.existsSync(path.join(projectDir, '.github', 'copilot-instructions.md'))) return 'copilot';
  if (fs.existsSync(path.join(projectDir, 'AGENTS.md'))) return 'codex';
  if (fs.existsSync(path.join(projectDir, '.windsurfrules'))) return 'windsurf';
  if (fs.existsSync(path.join(projectDir, 'GEMINI.md'))) return 'gemini';
  return null;
}

function detectStack(projectDir) {
  if (fs.existsSync(path.join(projectDir, 'next.config.ts')) || fs.existsSync(path.join(projectDir, 'next.config.js'))) return 'nextjs';
  if (fs.existsSync(path.join(projectDir, 'package.json'))) {
    try {
      const pkg = JSON.parse(fs.readFileSync(path.join(projectDir, 'package.json'), 'utf8'));
      if (pkg.dependencies?.express) return 'express';
      if (pkg.dependencies?.react) return 'react-spa';
    } catch {}
    return 'generic-typescript';
  }
  if (fs.existsSync(path.join(projectDir, 'requirements.txt')) || fs.existsSync(path.join(projectDir, 'pyproject.toml'))) {
    try {
      const req = fs.readFileSync(path.join(projectDir, 'requirements.txt'), 'utf8');
      if (req.includes('fastapi')) return 'fastapi';
    } catch {}
    return 'generic-python';
  }
  if (fs.existsSync(path.join(projectDir, 'go.mod'))) return 'go-service';
  if (fs.existsSync(path.join(projectDir, 'Cargo.toml'))) return 'generic-typescript'; // fallback
  return null;
}

// --- Claude Code Setup ---

function setupClaudeCode(projectDir, pluginRoot) {
  // Warn if running from a temporary npx cache
  const isNpxCache = pluginRoot.includes('/_npx/') || pluginRoot.includes('\\_npx\\');
  if (isNpxCache) {
    console.log(yellow('  ⚠') + '  Running from npx cache — hooks will break when cache is cleaned.');
    console.log(yellow('  ⚠') + '  For a stable setup, install permanently:');
    console.log(dim('       npm install -g shipworthy'));
    console.log(dim('       Then re-run: shipworthy init\n'));
  }

  // Ensure hook scripts are executable
  const hookScripts = ['session-start', 'pre-tool-use', 'pre-tool-use-bash', 'pre-push-validate', 'post-tool-use', 'post-tool-use-write'];
  for (const script of hookScripts) {
    const hookPath = path.join(pluginRoot, 'hooks', script);
    if (fs.existsSync(hookPath)) {
      try { fs.chmodSync(hookPath, 0o755); } catch {}
    }
  }

  // Build hooks config with absolute paths
  const hooksConfig = {
    hooks: {
      SessionStart: [
        {
          matcher: '',
          hooks: [
            {
              type: 'command',
              command: `"${path.join(pluginRoot, 'hooks', 'session-start')}"`,
              timeout: 5000,
            },
          ],
        },
      ],
      PreToolUse: [
        {
          matcher: 'Write|Edit',
          hooks: [
            {
              type: 'command',
              command: `"${path.join(pluginRoot, 'hooks', 'pre-tool-use')}"`,
              timeout: 3000,
            },
          ],
        },
        {
          matcher: 'Bash',
          hooks: [
            {
              type: 'command',
              command: `"${path.join(pluginRoot, 'hooks', 'pre-tool-use-bash')}"`,
              timeout: 3000,
            },
          ],
        },
        {
          matcher: 'Bash',
          hooks: [
            {
              type: 'command',
              command: `"${path.join(pluginRoot, 'hooks', 'pre-push-validate')}"`,
              timeout: 90000,
            },
          ],
        },
      ],
      PostToolUse: [
        {
          matcher: 'Bash',
          hooks: [
            {
              type: 'command',
              command: `"${path.join(pluginRoot, 'hooks', 'post-tool-use')}"`,
              timeout: 3000,
            },
          ],
        },
        {
          matcher: 'Write|Edit',
          hooks: [
            {
              type: 'command',
              command: `"${path.join(pluginRoot, 'hooks', 'post-tool-use-write')}"`,
              timeout: 3000,
            },
          ],
        },
      ],
    },
  };

  // Write or merge into .claude/settings.json
  const claudeDir = path.join(projectDir, '.claude');
  if (!fs.existsSync(claudeDir)) {
    fs.mkdirSync(claudeDir, { recursive: true });
  }

  const settingsPath = path.join(claudeDir, 'settings.json');
  let existingSettings = {};
  if (fs.existsSync(settingsPath)) {
    try {
      existingSettings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
    } catch {}
  }

  // Merge: replace hooks section, preserve everything else
  existingSettings.hooks = hooksConfig.hooks;
  fs.writeFileSync(settingsPath, JSON.stringify(existingSettings, null, 2) + '\n');
  console.log(green('  ✓') + ' Configured hooks in .claude/settings.json');

  if (!isNpxCache) {
    console.log(dim(`    Hooks point to: ${path.join(pluginRoot, 'hooks')}`));
  }
}

// --- Commands ---

function init(args) {
  const projectDir = process.cwd();
  const pluginRoot = findPluginRoot();

  // Parse --agent flag
  let agent = null;
  const agentIdx = args.indexOf('--agent');
  if (agentIdx !== -1 && args[agentIdx + 1]) {
    agent = args[agentIdx + 1];
  }

  console.log(bold('\n  Shipworthy — Is your code worthy of shipping?\n'));
  console.log(dim('  Initializing engineering guardrails...\n'));

  // 1. Create .shipworthy directory
  const swDir = path.join(projectDir, SHIPWORTHY_DIR);
  if (!fs.existsSync(swDir)) {
    fs.mkdirSync(swDir, { recursive: true });
    console.log(green('  ✓') + ' Created .shipworthy/ directory');
  } else {
    console.log(yellow('  →') + ' .shipworthy/ already exists');
  }

  // 2. Detect or set agent
  if (!agent) {
    agent = detectAgent(projectDir) || 'claude';
  }
  console.log(green('  ✓') + ` Agent: ${bold(agent)}`);

  // 3. Copy agent-specific config
  const adapterMap = {
    cursor: { src: 'adapters/cursor/.cursorrules', dest: '.cursorrules' },
    copilot: { src: 'adapters/copilot/.github/copilot-instructions.md', dest: '.github/copilot-instructions.md' },
    codex: { src: 'adapters/codex/AGENTS.md', dest: 'AGENTS.md' },
    windsurf: { src: 'adapters/windsurf/.windsurfrules', dest: '.windsurfrules' },
    gemini: { src: 'adapters/gemini/GEMINI.md', dest: 'GEMINI.md' },
  };

  if (agent === 'claude') {
    setupClaudeCode(projectDir, pluginRoot);
  } else {
    const adapter = adapterMap[agent];
    if (adapter) {
      const srcPath = path.join(pluginRoot, adapter.src);
      const destPath = path.join(projectDir, adapter.dest);
      const destDir = path.dirname(destPath);
      if (!fs.existsSync(destDir)) fs.mkdirSync(destDir, { recursive: true });
      if (fs.existsSync(srcPath)) {
        fs.copyFileSync(srcPath, destPath);
        console.log(green('  ✓') + ` Copied ${adapter.dest}`);
      } else {
        console.log(yellow('  →') + ` Adapter file not found: ${adapter.src}`);
      }
    }
  }

  // 4. Detect stack and suggest template
  const stack = detectStack(projectDir);
  if (stack) {
    console.log(green('  ✓') + ` Detected stack: ${bold(stack)}`);
    const templatePath = path.join(pluginRoot, 'templates', `${stack}.md`);
    if (fs.existsSync(templatePath)) {
      console.log(dim(`    Template available: templates/${stack}.md`));
      console.log(dim('    Run your AI agent and ask it to generate .shipworthy/architecture.md'));
    }
  } else {
    console.log(yellow('  →') + ' No stack detected — architecture spec will be generated on first coding session');
  }

  // 5. Add .shipworthy to .gitignore if not present
  const gitignorePath = path.join(projectDir, '.gitignore');
  if (fs.existsSync(gitignorePath)) {
    const gitignore = fs.readFileSync(gitignorePath, 'utf8');
    if (!gitignore.includes('.shipworthy')) {
      // Don't add — .shipworthy should be committed (it's the architecture spec)
    }
  }

  // 6. Save init config
  const configPath = path.join(swDir, 'config.json');
  fs.writeFileSync(configPath, JSON.stringify({
    version: VERSION,
    agent,
    stack: stack || 'unknown',
    initializedAt: new Date().toISOString(),
  }, null, 2));
  console.log(green('  ✓') + ' Saved config to .shipworthy/config.json');

  console.log(bold('\n  Shipworthy is ready.\n'));
  console.log('  Your next AI session will have engineering guardrails.');
  console.log('  On your first coding request, an architecture spec will be generated.\n');
}

function score() {
  const projectDir = process.cwd();
  const pluginRoot = findPluginRoot();
  const scorerPath = path.join(pluginRoot, 'benchmarks', 'scoring', 'automated-checks.sh');

  if (!fs.existsSync(scorerPath)) {
    console.error(red('  Error: scoring script not found at ') + scorerPath);
    process.exit(1);
  }

  console.log(bold('\n  Shipworthy Score\n'));
  console.log(dim('  Running 15 automated checks...\n'));

  try {
    const output = execFileSync('bash', [scorerPath, projectDir], { encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] });
    const result = JSON.parse(output);

    for (const [check, data] of Object.entries(result.checks)) {
      const icon = data.pass ? green('✓') : red('✗');
      const pts = data.pass ? green(`${data.points}/${data.max_points}`) : red(`${data.points}/${data.max_points}`);
      console.log(`  ${icon} ${pts}  ${check.replace(/_/g, ' ')}`);
    }

    console.log(bold(`\n  Total: ${result.total_points}/${result.max_points} (${result.grade})\n`));
  } catch (err) {
    console.error(red('  Scoring failed. Make sure bash and jq are available.'));
    process.exit(1);
  }
}

function doctor() {
  const projectDir = process.cwd();

  console.log(bold('\n  Shipworthy Doctor\n'));

  const checks = [
    { name: '.shipworthy/ directory', check: () => fs.existsSync(path.join(projectDir, SHIPWORTHY_DIR)) },
    { name: 'Architecture spec', check: () => fs.existsSync(path.join(projectDir, SHIPWORTHY_DIR, 'architecture.md')) },
    { name: 'Agent config', check: () => detectAgent(projectDir) !== null },
    { name: 'Claude Code hooks', check: () => {
      try {
        const settings = JSON.parse(fs.readFileSync(path.join(projectDir, '.claude', 'settings.json'), 'utf8'));
        return !!settings.hooks?.SessionStart;
      } catch { return false; }
    }},
    { name: '.gitignore exists', check: () => fs.existsSync(path.join(projectDir, '.gitignore')) },
    { name: '.env in .gitignore', check: () => {
      try { return fs.readFileSync(path.join(projectDir, '.gitignore'), 'utf8').includes('.env'); } catch { return false; }
    }},
    { name: 'package.json exists', check: () => fs.existsSync(path.join(projectDir, 'package.json')) },
    { name: 'Tests configured', check: () => {
      try { const pkg = JSON.parse(fs.readFileSync(path.join(projectDir, 'package.json'), 'utf8')); return !!pkg.scripts?.test; } catch { return false; }
    }},
    { name: 'TypeScript strict mode', check: () => {
      try { const ts = JSON.parse(fs.readFileSync(path.join(projectDir, 'tsconfig.json'), 'utf8')); return ts.compilerOptions?.strict === true; } catch { return false; }
    }},
  ];

  let passed = 0;
  for (const { name, check } of checks) {
    const ok = check();
    if (ok) passed++;
    console.log(`  ${ok ? green('✓') : red('✗')}  ${name}`);
  }

  const agent = detectAgent(projectDir);
  if (agent) {
    console.log(dim(`\n  Detected agent: ${agent}`));
  }

  const stack = detectStack(projectDir);
  if (stack) {
    console.log(dim(`  Detected stack: ${stack}`));
  }

  console.log(bold(`\n  Health: ${passed}/${checks.length} checks passing\n`));

  if (passed < checks.length) {
    console.log('  Run ' + bold('npx shipworthy init') + ' to fix missing items.\n');
  }
}

function help() {
  console.log(`
${bold('  Shipworthy')} v${VERSION} — Is your code worthy of shipping?

${bold('  Usage:')}
    npx shipworthy <command> [options]

${bold('  Commands:')}
    init              Initialize Shipworthy in the current project
    score             Run automated quality checks and show score
    doctor            Check if Shipworthy is set up correctly

${bold('  Init Options:')}
    --agent <name>    Set the AI agent (claude, cursor, copilot, codex, windsurf, gemini)

${bold('  Examples:')}
    npx shipworthy init
    npx shipworthy init --agent cursor
    npx shipworthy score
    npx shipworthy doctor
`);
}

// --- Main ---
const [,, command, ...args] = process.argv;

switch (command) {
  case 'init': init(args); break;
  case 'score': score(); break;
  case 'doctor': doctor(); break;
  case '--help': case '-h': case 'help': case undefined: help(); break;
  case '--version': case '-v': console.log(VERSION); break;
  default:
    console.error(red(`  Unknown command: ${command}`));
    help();
    process.exit(1);
}
