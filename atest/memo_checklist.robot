*** Settings ***
Documentation       Acceptance tests for the checklist toggle feature.
...                 Requires the app to be running at BASE_URL (default: http://localhost:8000).
...                 Start the server with: uv run python manage.py runserver

Library             Browser
Library             resources/StorageLibrary.py

Suite Setup         Open Browser Session
Suite Teardown      Close Browser
Test Setup          Set Up Storage    path=data/memos
Test Teardown       Tear Down Storage

Test Tags           feature:checklist    browser


*** Variables ***
${BASE_URL}     http://localhost:8000


*** Test Cases ***
Checklist Items Appear As Checkboxes
    [Documentation]    Memo body with Markdown task list items renders checkbox inputs.
    ${id}=    Create Memo Via Storage    title=Tasks    body=- [ ] buy milk\n- [ ] call dentist
    Go To    ${BASE_URL}/${id}/
    Get Elements    input[type="checkbox"]

Unchecked Checkbox Is Initially Unchecked
    [Documentation]    A Markdown unchecked item renders as an unchecked checkbox.
    ${id}=    Create Memo Via Storage    title=Tasks    body=- [ ] unchecked item
    Go To    ${BASE_URL}/${id}/
    Get Property    input[type="checkbox"]    checked    ==    ${False}

Checked Checkbox Is Initially Checked
    [Documentation]    A Markdown checked item renders as a checked checkbox.
    ${id}=    Create Memo Via Storage    title=Tasks    body=- [x] already done
    Go To    ${BASE_URL}/${id}/
    Get Property    input[type="checkbox"]    checked    ==    ${True}

Clicking Unchecked Checkbox Marks It Checked
    [Documentation]    Clicking an unchecked checkbox sends an HTMX request and the item becomes checked.
    ${id}=    Create Memo Via Storage    title=Tasks    body=- [ ] buy milk
    Go To    ${BASE_URL}/${id}/
    Click    input[type="checkbox"]
    Get Property    input[type="checkbox"]    checked    ==    ${True}

Clicking Checked Checkbox Marks It Unchecked
    [Documentation]    Clicking a checked checkbox sends an HTMX request and the item becomes unchecked.
    ${id}=    Create Memo Via Storage    title=Tasks    body=- [x] done item
    Go To    ${BASE_URL}/${id}/
    Click    input[type="checkbox"]
    Get Property    input[type="checkbox"]    checked    ==    ${False}

Toggle State Is Persisted
    [Documentation]    After toggling, reloading the page shows the updated checkbox state.
    ${id}=    Create Memo Via Storage    title=Tasks    body=- [ ] persistent item
    Go To    ${BASE_URL}/${id}/
    Click    input[type="checkbox"]
    Wait For Load State    networkidle
    Go To    ${BASE_URL}/${id}/
    Get Property    input[type="checkbox"]    checked    ==    ${True}

Second Item Can Be Toggled Independently
    [Documentation]    Toggling the second checkbox only affects that item, not the first.
    ${id}=    Create Memo Via Storage    title=Tasks    body=- [ ] first item\n- [ ] second item
    Go To    ${BASE_URL}/${id}/
    Click    (//input[@type="checkbox"])[2]
    Get Property    (//input[@type="checkbox"])[1]    checked    ==    ${False}
    Get Property    (//input[@type="checkbox"])[2]    checked    ==    ${True}


*** Keywords ***
Open Browser Session
    [Documentation]    Launch a headless Chromium browser and open the app.
    New Browser    chromium    headless=True
    New Context
    New Page    ${BASE_URL}

Create Memo Via Storage
    [Documentation]    Save a memo directly via storage and return its id.
    [Arguments]    ${title}    ${body}=${EMPTY}
    ${id}=    Save Memo    title=${title}    body=${body}
    RETURN    ${id}
