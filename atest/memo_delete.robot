*** Settings ***
Documentation       Acceptance tests for the delete memo feature.

Resource            resources/browser.resource

Suite Setup         Open Browser Session
Suite Teardown      Close Browser
Test Setup          Set Up Storage    path=data/memos
Test Teardown       Tear Down Storage

Test Tags           feature:delete    browser


*** Test Cases ***
Delete Confirmation Page Is Accessible
    ${id}=    Create Memo Via Storage    title=To delete    body=content
    Go To    ${BASE_URL}/${id}/delete/
    Get Title    ==    Memos

Delete Page Shows Memo Title
    ${id}=    Create Memo Via Storage    title=My important memo    body=content
    Go To    ${BASE_URL}/${id}/delete/
    Get Text    body    *=    My important memo

Delete Page Has Confirm Button
    ${id}=    Create Memo Via Storage    title=A memo    body=content
    Go To    ${BASE_URL}/${id}/delete/
    Get Element    button[type="submit"]

Delete Page Has Cancel Link
    ${id}=    Create Memo Via Storage    title=A memo    body=content
    Go To    ${BASE_URL}/${id}/delete/
    Get Element    .form-actions a[href="/${id}/"]

Confirming Delete Removes Memo And Redirects To List
    ${id}=    Create Memo Via Storage    title=Doomed memo    body=goodbye
    Go To    ${BASE_URL}/${id}/delete/
    Click    button[type="submit"]
    Get Text    body    not contains    Doomed memo
    Get Title    ==    Memos

Deleted Memo No Longer Appears In List
    ${id}=    Create Memo Via Storage    title=To be removed    body=content
    Go To    ${BASE_URL}/${id}/delete/
    Click    button[type="submit"]
    Get Text    body    not contains    To be removed
