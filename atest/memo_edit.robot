*** Settings ***
Documentation       Acceptance tests for the edit memo feature.

Resource            resources/browser.resource

Suite Setup         Open Browser Session
Suite Teardown      Close Browser
Test Setup          Set Up Storage    path=data/memos
Test Teardown       Tear Down Storage

Test Tags           feature:edit    browser


*** Test Cases ***
Edit Page Is Accessible
    ${id}=    Create Memo Via Storage    title=Original title    body=original body
    Go To    ${BASE_URL}/${id}/edit/
    Get Title    ==    Memos

Edit Page Prefills Title
    ${id}=    Create Memo Via Storage    title=My original title    body=some body
    Go To    ${BASE_URL}/${id}/edit/
    Get Property    input[name="title"]    value    ==    My original title

Edit Page Prefills Body
    ${id}=    Create Memo Via Storage    title=Title    body=original body text
    Go To    ${BASE_URL}/${id}/edit/
    Get Text    textarea[name="body"]    ==    original body text

Submitting Form Updates Memo And Shows Detail
    ${id}=    Create Memo Via Storage    title=Old title    body=old body
    Go To    ${BASE_URL}/${id}/edit/
    Fill Text    input[name="title"]    New title
    Fill Text    textarea[name="body"]    New body
    Click    button[type="submit"]
    Get Text    body    *=    New title
    Get Text    body    *=    New body

Edit Does Not Create Duplicate Memo
    ${id}=    Create Memo Via Storage    title=Solo memo    body=content
    Go To    ${BASE_URL}/${id}/edit/
    Fill Text    input[name="title"]    Updated memo
    Click    button[type="submit"]
    Go To    ${BASE_URL}
    Get Text    body    *=    Updated memo
    Get Text    body    not contains    Solo memo

Submitting Empty Title Stays On Form
    ${id}=    Create Memo Via Storage    title=My memo    body=content
    Go To    ${BASE_URL}/${id}/edit/
    Fill Text    input[name="title"]    ${EMPTY}
    Click    button[type="submit"]
    Get Element    input[name="title"]

Edit Page Has Link Back To Detail
    ${id}=    Create Memo Via Storage    title=A memo    body=content
    Go To    ${BASE_URL}/${id}/edit/
    Get Element    a.back-link[href="/${id}/"]
