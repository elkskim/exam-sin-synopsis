# GitHub Actions Workflows

**NOTE:** The actual workflow files have been moved to the repository root at `../../.github/workflows/`

GitHub Actions requires workflows to be at the repository root (`.github/workflows/`), not in subdirectories.

## Workflows (Located at Repository Root)

### `../../.github/workflows/ci-cd.yml`
Standard CI/CD pipeline that runs on every push and pull request.

### `../../.github/workflows/measure-cicd.yml`
Performance measurement pipeline that tracks deployment times for synopsis data.

## Quick Start

The workflows are already in place at the repository root and will trigger automatically on push to main/develop branches.

**View workflows:**
- Go to GitHub repository → Actions tab
- Workflows run automatically on push

**Manual trigger:**
- Actions → Select workflow → Run workflow

## See Also

- `GITHUB_ACTIONS_GUIDE.md` - Detailed usage guide
- `RESULTS_SUMMARY.md` - Performance comparison data
