---
name: robot-framework-tests
description: "Write Robot Framework acceptance tests for this Django memo app. Use when: adding a new feature that needs browser or API acceptance tests; writing RF test cases; using Browser library keywords; working with StorageLibrary; following TDD RED-GREEN workflow for RF tests; fixing robocop issues in .robot files."
---

# Robot Framework Tests — Memo App

## When to Use
- Adding acceptance tests for a new feature (TDD: write RED before implementing)
- Working on any `.robot` file in `atest/`
- Fixing robocop lint issues in RF test data
- Debugging Browser library strict mode violations

## Project Structure

```
atest/
├── __init__.robot              # Suite teardown: Delete All Memos after full run
├── memo_<feature>.robot        # One file per feature
├── resources/
│   └── StorageLibrary.py       # Custom library: wraps storage layer for test data setup
└── output/                     # Robot output (not committed)
```

## File Template

Every new feature test file follows this structure:

```robotframework
*** Settings ***
Documentation       Mostly avoid suite documentation, but this is where you would put it if needed.

Library             Browser
Library             resources/StorageLibrary.py

Suite Setup         Open Browser Session
Suite Teardown      Close Browser
Test Setup          Set Up Storage    path=data/memos
Test Teardown       Tear Down Storage

Test Tags           feature:<feature>    browser


*** Variables ***
${BASE_URL}     http://localhost:8000


*** Test Cases ***
<Test Name>
    ...

*** Keywords ***
Open Browser Session
    New Browser    chromium    headless=True
    New Context
    New Page    ${BASE_URL}

Create Memo Via Storage
    [Arguments]    ${title}    ${body}=${EMPTY}
    ${id}=    Save Memo    title=${title}    body=${body}
    RETURN    ${id}
```

> If the test file only uses `StorageLibrary` (no browser), omit `Suite Setup/Teardown` and the `Open Browser Session` keyword. See `memo_storage.robot` for this pattern.

## TDD Workflow

1. **Write RED tests first** — run `uv run robot --pythonpath . --outputdir atest/output atest/<file>.robot` and confirm they fail
2. Implement the feature
3. **Run to GREEN** — confirm all tests pass
4. Run full verification before committing:
   ```
   uv run ruff check . && uv run ruff format --check . && \
   uv run mypy memos/ memoproject/ && \
   uv run robocop check atest/ && \
   uv run pytest utest/ -q && \
   uv run robot --pythonpath . --outputdir atest/output atest/
   ```

## StorageLibrary Keywords

| Keyword | Description |
|---|---|
| `Set Up Storage` | Call in `Test Setup`. Use `path=data/memos` for browser tests (server mode), no arg for storage-only tests (isolated temp dir). |
| `Tear Down Storage` | Call in `Test Teardown`. Deletes only memos created during the test (server mode) or the whole temp dir (isolated mode). |
| `Save Memo    title=X    body=Y` | Creates a memo and returns its `id`. |
| `Get Memo    ${id}` | Returns a dict with `id`, `title`, `body`. |
| `Delete Memo    ${id}` | Deletes a memo by id. |
| `List Memos` | Returns list of dicts with `id` and `title`. |
| `Search Memos    query=X` | Returns matching memos. |
| `Memo File Should Exist    ${id}` | Asserts the `.md` file exists on disk. |
| `Delete All Memos    path=data/memos` | Deletes every memo — used in suite teardown. |

## Browser Library Assertion Patterns

Prefer inline assertions over `Should` keywords — they get automatic retry:

```robotframework
# Text contains
Get Text    body    *=    Expected text

# Text does not contain
Get Text    body    not contains    Absent text

# Exact text match
Get Text    h1    ==    Page Title

# Property check
Get Property    input[type="checkbox"]    checked    ==    ${True}

# Style check
Get Style    .element    background-color    ==    rgb(0, 0, 0)
```

## Strict Mode — Selector Rules

Browser library uses **strict mode by default**: a selector matching more than one element causes an error.

- If one element is expected → `Get Element selector` (strict, fails on multiple)
- If multiple elements are expected → `Get Elements selector` (returns list, never fails on count)
- Avoid generic selectors; prefer specific CSS:
  - ✅ `a.back-link[href="/"]`
  - ✅ `form[action="/${id}/delete/"] button[type="submit"]`
  - ✅ `(//input[@type="checkbox"])[2]` (XPath nth-item)
  - ❌ `a[href="/"]` (may match multiple links)

## HTMX Interactions

When clicking triggers an HTMX request and then navigating away, wait for the network first:

```robotframework
Click    input[type="checkbox"]
Wait For Load State    networkidle
Go To    ${BASE_URL}/${id}/
```

> Do NOT use the deprecated `Wait Until Network Is Idle` — use `Wait For Load State    networkidle`.

## Robocop Rules to Watch

| Rule | Description | Fix |
|---|---|---|
| TAG05 | Tag with variable should use `Test Tags` | Move to `*** Settings ***` as `Test Tags feature:x` |
| LEN12 | Too many test cases in a file | Split into multiple files |
| COM02 | Comment in keyword — use self-documenting names instead | Remove inline comments; rename keyword to describe intent |

Run `uv run robocop check atest/` to catch all issues before committing.

## Naming Conventions

- **Test case names**: Plain English, describe observable behavior → `Clicking Delete Button Removes Memo From List`
- **Keyword names**: Action phrase → `Open Browser Session`, `Create Memo Via Storage`
- **Variable names**: `${UPPER_SNAKE}` for suite/file scope, `${lower_snake}` for local
- **Tags**: `feature:<name>` for feature grouping; `browser` or `api` for type
- **Documentation**: One-sentence description of what is verified, not how

## Adding an API Test

For `api`-tagged tests that use `RequestsLibrary` instead of Browser:

```robotframework
GET Root Returns 200
    [Documentation]    The memo list endpoint responds with HTTP 200.
    [Tags]    api
    GET    ${BASE_URL}/    expected_status=200
```

Add `Library    RequestsLibrary` to `*** Settings ***` when using this pattern.

# Avoid
User keywords and test cases should be readable and easily understood, therefore avoid writing documentation. Suite documentation might be OK, most common things for all test
suites must be places to README.md file in the atest folder.

Put common user keywords, which can be reused in multiple test suites to a separate resource file.
