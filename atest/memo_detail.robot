*** Settings ***
Documentation       Acceptance tests for the memo detail and Markdown rendering feature.
...                 Requires the app to be running at BASE_URL (default: http://localhost:8000).
...                 Start the server with: uv run python manage.py runserver

Library             Browser
Library             resources/StorageLibrary.py

Suite Setup         Open Browser Session
Suite Teardown      Close Browser
Test Setup          Set Up Storage    path=data/memos
Test Teardown       Tear Down Storage

Test Tags           feature:detail    browser


*** Variables ***
${BASE_URL}     http://localhost:8000


*** Test Cases ***
Detail Page Returns 200
    [Documentation]    Navigating to a memo detail URL responds without error.
    ${id}=    Create Memo Via Storage    title=A memo    body=some text
    Go To    ${BASE_URL}/${id}/
    Get Title    ==    Memos

Detail Page Shows Memo Title
    [Documentation]    The memo title is visible on the detail page.
    ${id}=    Create Memo Via Storage    title=My important memo    body=details here
    Go To    ${BASE_URL}/${id}/
    Get Text    body    *=    My important memo

Markdown Bold Is Rendered As HTML
    [Documentation]    Bold text in the memo body is rendered as a strong element.
    ${id}=    Create Memo Via Storage    title=Formatted    body=**bold text**
    Go To    ${BASE_URL}/${id}/
    Get Element    strong

Markdown Heading Is Rendered As HTML
    [Documentation]    A heading marker in the memo body is rendered as an h2 element.

    ${id}=    Create Memo Via Storage    title=Headings    body=## Section title
    Go To    ${BASE_URL}/${id}/
    Get Text    h2    *=    Section title

Detail Page Has Link Back To List
    [Documentation]    The detail page contains a back link to the memo list.
    ${id}=    Create Memo Via Storage    title=A memo    body=content
    Go To    ${BASE_URL}/${id}/
    Get Element    a.back-link[href="/"]

Detail Page Has Edit Link
    [Documentation]    The detail page contains a link to the edit page for this memo.
    ${id}=    Create Memo Via Storage    title=A memo    body=content
    Go To    ${BASE_URL}/${id}/
    Get Element    a[href="/${id}/edit/"]

Detail Page Has Delete Link
    [Documentation]    The detail page contains a link to delete this memo.
    ${id}=    Create Memo Via Storage    title=A memo    body=content
    Go To    ${BASE_URL}/${id}/
    Get Element    a[href="/${id}/delete/"]

Unknown Memo ID Returns 404
    [Documentation]    Navigating to a non-existent memo ID shows a 404 response.
    Go To    ${BASE_URL}/does-not-exist/
    Get Text    body    *=    404


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
