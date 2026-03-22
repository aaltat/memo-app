# AGENTS.md

## Project Overview

Single-user home-network memo app built with Django 5.x. Memos are stored as Markdown files with YAML frontmatter — no database. The UI uses HTMX for interactive features (checklist toggling, inline delete).

## Tech Stack

- **Runtime**: Python 3.12, Django 5.x, HTMX 2.0
- **Storage**: Markdown files with `python-frontmatter`, no database
- **Dependency management**: `uv`
- **Linters**: `ruff`, `mypy`, `robocop`
- **Unit tests**: `pytest` + `pytest-django`
- **Acceptance tests**: Robot Framework with Browser library (Playwright)
- **Deployment**: Docker + Gunicorn

## Development Practice — Test Driven Development

All new features are developed using TDD. Write failing tests first, then implement until they pass.

**Unit tests (pytest)** cover the storage layer and views — run fast, no browser needed:

```bash
uv run pytest utest/ -q
```

**Acceptance tests (Robot Framework)** cover observable browser behavior end-to-end. The app must be running before executing browser suites:

```bash
uv run robot --pythonpath . --outputdir atest/output atest/
```

TDD workflow for a new feature:
1. Write RED unit tests in `utest/` and RED acceptance tests in `atest/`
2. Run both and confirm they fail
3. Implement the feature
4. Run both again and confirm GREEN
5. Run the full check suite before committing (see below)

See `.github/skills/robot-framework-tests/SKILL.md` for RF test conventions.

## Project Structure

```
memos/           # Django app — views, storage, templates
memoproject/     # Django project settings and URLs
utest/           # pytest unit tests
atest/           # Robot Framework acceptance tests
  resources/     # StorageLibrary.py, browser.resource
logs/            # Rotating log files (git-ignored)
data/memos/      # Memo .md files at runtime (git-ignored)
```

## Running the App

```bash
uv run python manage.py runserver   # development
docker compose up                   # production-like
```

## Running All Checks

```bash
uv run ruff check . && uv run ruff format --check . && \
uv run mypy memos/ memoproject/ && \
uv run robocop check atest/ && \
uv run pytest utest/ -q && \
uv run robot --pythonpath . --outputdir atest/output atest/
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `DJANGO_SECRET_KEY` | insecure dev key | Django secret key |
| `DJANGO_DEBUG` | `true` | Enable debug mode |
| `DJANGO_ALLOWED_HOSTS` | `localhost 127.0.0.1 0.0.0.0` | Space-separated allowed hosts |
| `MEMO_DIR` | `data/memos` | Directory for memo `.md` files |

## Logging

Logs write to `logs/memo.log` (rotating, 5 MB max, 5 backups) and stdout. Level is `DEBUG` in development, `INFO` in production. Key events: memo created/updated/deleted (INFO), not-found and toggle errors (WARNING), fetches and searches (DEBUG).

## Skills

- `.github/skills/robot-framework-tests/SKILL.md` — guidelines for writing Robot Framework acceptance tests for this project
