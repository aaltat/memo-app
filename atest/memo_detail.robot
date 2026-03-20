*** Settings ***
Documentation       Acceptance tests for the memo detail and Markdown rendering feature.

Resource            resources/browser.resource

Suite Setup         Open Browser Session
Suite Teardown      Close Browser
Test Setup          Set Up Storage    path=data/memos
Test Teardown       Tear Down Storage

Test Tags           feature:detail    browser


*** Test Cases ***
Detail Page Returns 200
    ${id}=    Create Memo Via Storage    title=A memo    body=some text
    Go To    ${BASE_URL}/${id}/
    Get Title    ==    Memos

Detail Page Shows Memo Title
    ${id}=    Create Memo Via Storage    title=My important memo    body=details here
    Go To    ${BASE_URL}/${id}/
    Get Text    body    *=    My important memo

Markdown Bold Is Rendered As HTML
    ${id}=    Create Memo Via Storage    title=Formatted    body=**bold text**
    Go To    ${BASE_URL}/${id}/
    Get Element    strong

Markdown Heading Is Rendered As HTML
    ${id}=    Create Memo Via Storage    title=Headings    body=## Section title
    Go To    ${BASE_URL}/${id}/
    Get Text    h2    *=    Section title

Detail Page Has Link Back To List
    ${id}=    Create Memo Via Storage    title=A memo    body=content
    Go To    ${BASE_URL}/${id}/
    Get Element    a.back-link[href="/"]

Detail Page Has Edit Link
    ${id}=    Create Memo Via Storage    title=A memo    body=content
    Go To    ${BASE_URL}/${id}/
    Get Element    a[href="/${id}/edit/"]

Detail Page Has Delete Link
    ${id}=    Create Memo Via Storage    title=A memo    body=content
    Go To    ${BASE_URL}/${id}/
    Get Element    a[href="/${id}/delete/"]

Unknown Memo ID Returns 404
    Go To    ${BASE_URL}/does-not-exist/
    Get Text    body    *=    404
