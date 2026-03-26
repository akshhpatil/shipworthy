# Benchmark Suite

Automated benchmarks that measure code quality produced by Claude Code, comparing output with and without the skills plugin installed.

## How It Works

1. A task prompt (e.g., "build a REST API with CRUD operations") is given to Claude Code
2. The same prompt is run twice: once with the plugin and once without
3. The generated code is scored by automated checks and an LLM-as-judge
4. Results are recorded and compared

The LLM judge performs **blind A/B comparison** -- it does not know which codebase used the plugin. Assignment to A/B is randomized to prevent position bias.

## Prerequisites

- **Claude Code** CLI installed and authenticated (`claude` command available)
- **Node.js** >= 18 and npm
- **jq** for JSON processing (`brew install jq` on macOS)
- An active Anthropic API key (used by `claude --print`)

Optional:
- Python 3 and pytest (for Python-based tasks)
- Go 1.21+ (for Go-based tasks)

## Directory Structure

```
benchmarks/
  tasks/             Task definitions (one .md file per task)
  scoring/
    rubric.md        Master scoring rubric
    automated-checks.sh   Automated quality checks
    llm-judge-prompt.md   Prompt template for blind A/B comparison
  results/           Output from benchmark runs (gitignored)
  run-benchmark.sh   Main benchmark runner
  compare-ab.sh      Blind A/B comparison script
```

## Running a Single Task

```bash
# Run task 1 with both modes (with and without plugin) and compare
./run-benchmark.sh --task 1

# Run task 1 with plugin only
./run-benchmark.sh --task 1 --with-plugin

# Run task 1 without plugin only
./run-benchmark.sh --task 1 --without-plugin
```

## Running All Tasks

```bash
# Run all available tasks in both modes
./run-benchmark.sh --all

# Run all tasks with plugin only
./run-benchmark.sh --all --with-plugin
```

## Running Automated Checks Only

If you already have a project directory and just want to score it:

```bash
./scoring/automated-checks.sh /path/to/project
```

This outputs a JSON report with per-check results, total score, and letter grade.

## Running a Blind A/B Comparison Only

If you have two project directories and want to compare them:

```bash
./compare-ab.sh results/01-rest-api-crud-with/ results/01-rest-api-crud-without/
```

This randomly assigns the directories to A and B, sends both to an LLM judge, and records the result in `results/comparison-log.json`.

## Interpreting Results

### Automated Checks

Each task is scored on a 20-point scale. Checks are binary (pass/fail) worth 1-3 points each.

| Grade | Points | Meaning |
|-------|--------|---------|
| A | 18-20 | Production-ready |
| B | 14-17 | Solid with minor gaps |
| C | 10-13 | Functional but incomplete |
| D | 6-9 | Barely functional |
| F | 0-5 | Non-functional |

### LLM Judge

The judge scores each codebase on five dimensions (0-5 each, 25 max):
- Correctness
- Security
- Testing
- Architecture
- Production Readiness

### Results Files

After a full run, you will find:

- `results/<task>-with/` -- generated code (with plugin)
- `results/<task>-without/` -- generated code (without plugin)
- `results/<task>-with-score.json` -- automated check results (with plugin)
- `results/<task>-without-score.json` -- automated check results (without plugin)
- `results/<task>-scores.json` -- combined comparison
- `results/comparison-log.json` -- running log of all A/B comparisons

## Contributing New Tasks

Each task is a single Markdown file in `tasks/`. Follow the format of `tasks/01-rest-api-crud.md`:

1. **Prompt section**: The exact prompt given to Claude Code (identical for both runs)
2. **Setup section**: Starter files (package.json, tsconfig.json, etc.)
3. **Expected Artifacts**: What should exist after the task completes
4. **Scoring Criteria**: 10 checks totaling 20 points, with verification instructions
5. **Anti-Patterns**: Red flags to watch for

Name your file with a zero-padded number prefix: `02-auth-middleware.md`, `03-database-models.md`, etc.

### Guidelines for Good Tasks

- The prompt should be realistic -- something a developer would actually ask
- The prompt should be identical for both runs (no hints about the plugin)
- Scoring criteria should be objective and automatable where possible
- Include at least 3 checks worth 3 points (critical) and 3 checks worth 1 point (good practice)
- Anti-patterns should be things that indicate the code is not production-ready

## Reproducibility

LLM output is non-deterministic. To get reliable results:

- Run each task at least 3 times and average the scores
- Use the same Claude model version across all runs
- Record the model version in your results
- The blind A/B comparison mitigates position bias but does not eliminate LLM judge variance
