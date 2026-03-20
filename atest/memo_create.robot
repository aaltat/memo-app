*** Settings ***
Documentation       Acceptance tests for the create memo feature.
...                 Requires the app to be running at BASE_URL (default: http://localhost:8000).
...                 Start the server with: uv run python manage.py runserver

Library             Browser
Library             resources/StorageLibrary.py

Suite Setup         Open Browser Session
Suite Teardown      Close Browser
Test Setup          Set Up Storage    path=data/memos
Test Teardown       Tear Down Storage

Test Tags           feature:create    browser


*** Variables ***
${BASE_URL}     http://localhost:8000


*** Test Cases ***
Create Page Is Accessible
    [Documentation]    The create memo page loads without error.
    Go To    ${BASE_URL}/new/
    Get Title    ==    Memos

Create Page Has Title Input
    [Documentation]    The create form contains a title input field.
    Go To    ${BASE_URL}/new/
    Get Element    input[name="title"]

Create Page Has Body Textarea
    [Documentation]    The create form contains a body textarea.
    Go To    ${BASE_URL}/new/
    Get Element    textarea[name="body"]

Submitting Form Creates Memo And Redirects To Detail
    [Documentation]    Filling in the form and submitting navigates to the new memo's detail page.
    Go To    ${BASE_URL}/new/
    Fill Text    input[name="title"]    My new memo
    Fill Text    textarea[name="body"]    This is the body
    Click    button[type="submit"]
    Get Text    body    *=    My new memo
    Get Text    body    *=    This is the body

Created Memo Appears In List
    [Documentation]    After creating a memo it shows up on the list page.
    Go To    ${BASE_URL}/new/
    Fill Text    input[name="title"]    Listed memo
    Fill Text    textarea[name="body"]    list body
    Click    button[type="submit"]
    Go To    ${BASE_URL}
    Get Text    body    *=    Listed memo

Submitting Empty Title Stays On Form
    [Documentation]    Submitting the form without a title does not create a memo and re-renders the form.
    Go To    ${BASE_URL}/new/
    Fill Text    textarea[name="body"]    no title here
    Click    button[type="submit"]
    Get Element    input[name="title"]

Create Page Has Link Back To List
    [Documentation]    The create page contains a back link to the memo list.
    Go To    ${BASE_URL}/new/
    Get Element    a.back-link[href="/"]


*** Keywords ***
Open Browser Session
    [Documentation]    Launch a headless Chromium browser and open the app.
    New Browser    chromium    headless=True
    New Context
    New Page    ${BASE_URL}
