*** Settings ***
Documentation       Acceptance tests for the delete memo feature.
...                 Requires the app to be running at BASE_URL (default: http://localhost:8000).
...                 Start the server with: uv run python manage.py runserver

Library             Browser
Library             resources/StorageLibrary.py

Suite Setup         Open Browser Session
Suite Teardown      Close Browser
Test Setup          Set Up Storage    path=data/memos
Test Teardown       Tear Down Storage

Test Tags           feature:delete    browser


*** Variables ***
${BASE_URL}     http://localhost:8000


*** Test Cases ***
Delete Confirmation Page Is Accessible
    [Documentation]    The delete confirmation page for an existing memo loads without error.
    ${id}=    Create Memo Via Storage    title=To delete    body=content
    Go To    ${BASE_URL}/${id}/delete/
    Get Title    ==    Memos

Delete Page Shows Memo Title
    [Documentation]    The delete confirmation page shows the title of the memo to be deleted.
    ${id}=    Create Memo Via Storage    title=My important memo    body=content
    Go To    ${BASE_URL}/${id}/delete/
    Get Text    body    *=    My important memo

Delete Page Has Confirm Button
    [Documentation]    The delete confirmation page has a submit button to confirm deletion.
    ${id}=    Create Memo Via Storage    title=A memo    body=content
    Go To    ${BASE_URL}/${id}/delete/
    Get Element    button[type="submit"]

Delete Page Has Cancel Link
    [Documentation]    The delete confirmation page has a link back to the memo detail page.
    ${id}=    Create Memo Via Storage    title=A memo    body=content
    Go To    ${BASE_URL}/${id}/delete/
    Get Element    .form-actions a[href="/${id}/"]

Confirming Delete Removes Memo And Redirects To List
    [Documentation]    Clicking confirm deletes the memo and navigates to the list page.
    ${id}=    Create Memo Via Storage    title=Doomed memo    body=goodbye
    Go To    ${BASE_URL}/${id}/delete/
    Click    button[type="submit"]
    Get Text    body    not contains    Doomed memo
    Get Title    ==    Memos

Deleted Memo No Longer Appears In List
    [Documentation]    After deletion the memo title does not appear on the list page.
    ${id}=    Create Memo Via Storage    title=To be removed    body=content
    Go To    ${BASE_URL}/${id}/delete/
    Click    button[type="submit"]
    Get Text    body    not contains    To be removed


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
