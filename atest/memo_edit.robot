*** Settings ***
Documentation       Acceptance tests for the edit memo feature.
...                 Requires the app to be running at BASE_URL (default: http://localhost:8000).
...                 Start the server with: uv run python manage.py runserver

Library             Browser
Library             resources/StorageLibrary.py

Suite Setup         Open Browser Session
Suite Teardown      Close Browser
Test Setup          Set Up Storage    path=data/memos
Test Teardown       Tear Down Storage

Test Tags           feature:edit    browser


*** Variables ***
${BASE_URL}     http://localhost:8000


*** Test Cases ***
Edit Page Is Accessible
    [Documentation]    The edit page for an existing memo loads without error.
    ${id}=    Create Memo Via Storage    title=Original title    body=original body
    Go To    ${BASE_URL}/${id}/edit/
    Get Title    ==    Memos

Edit Page Prefills Title
    [Documentation]    The edit form is pre-populated with the memo's current title.
    ${id}=    Create Memo Via Storage    title=My original title    body=some body
    Go To    ${BASE_URL}/${id}/edit/
    Get Property    input[name="title"]    value    ==    My original title

Edit Page Prefills Body
    [Documentation]    The edit form is pre-populated with the memo's current body.
    ${id}=    Create Memo Via Storage    title=Title    body=original body text
    Go To    ${BASE_URL}/${id}/edit/
    Get Text    textarea[name="body"]    ==    original body text

Submitting Form Updates Memo And Shows Detail
    [Documentation]    Saving the edit form updates the memo and redirects to the detail page.
    ${id}=    Create Memo Via Storage    title=Old title    body=old body
    Go To    ${BASE_URL}/${id}/edit/
    Fill Text    input[name="title"]    New title
    Fill Text    textarea[name="body"]    New body
    Click    button[type="submit"]
    Get Text    body    *=    New title
    Get Text    body    *=    New body

Edit Does Not Create Duplicate Memo
    [Documentation]    Editing a memo updates it in place rather than creating a new one.
    ${id}=    Create Memo Via Storage    title=Solo memo    body=content
    Go To    ${BASE_URL}/${id}/edit/
    Fill Text    input[name="title"]    Updated memo
    Click    button[type="submit"]
    Go To    ${BASE_URL}
    Get Text    body    *=    Updated memo
    Get Text    body    not contains    Solo memo

Submitting Empty Title Stays On Form
    [Documentation]    Submitting the edit form without a title re-renders the form.
    ${id}=    Create Memo Via Storage    title=My memo    body=content
    Go To    ${BASE_URL}/${id}/edit/
    Fill Text    input[name="title"]    ${EMPTY}
    Click    button[type="submit"]
    Get Element    input[name="title"]

Edit Page Has Link Back To Detail
    [Documentation]    The edit page contains a link back to the memo detail page.
    ${id}=    Create Memo Via Storage    title=A memo    body=content
    Go To    ${BASE_URL}/${id}/edit/
    Get Element    a.back-link[href="/${id}/"]


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
