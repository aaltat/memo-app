# Acceptance Tests

Robot Framework acceptance tests for the memo app.

## Prerequisites

The app must be running at `http://localhost:8000` before executing browser tests.

Start the development server:

```bash
uv run python manage.py runserver
```

Or with Docker:

```bash
docker compose up
```

## Running Tests

Run the full acceptance test suite:

```bash
uv run robot --pythonpath . --outputdir atest/output atest/
```

Run a single suite:

```bash
uv run robot --pythonpath . --outputdir atest/output atest/memo_list.robot
```

Run by tag (e.g. only browser tests):

```bash
uv run robot --pythonpath . --outputdir atest/output --include browser atest/
```

## Storage Tests

`memo_storage.robot` tests the storage layer directly without a browser and does not require the server to be running.

Browser test suites use `data/memos` as the memo directory. Each test sets up and tears down its own storage, and the full suite teardown (`atest/__init__.robot`) removes the directory after all tests finish.
