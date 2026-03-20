*** Settings ***
Documentation       Acceptance tests for the create memo feature.

Resource            resources/browser.resource

Suite Setup         Open Browser Session
Suite Teardown      Close Browser
Test Setup          Set Up Storage    path=data/memos
Test Teardown       Tear Down Storage

Test Tags           feature:create    browser


*** Test Cases ***
Create Page Is Accessible
    Go To    ${BASE_URL}/new/
    Get Title    ==    Memos

Create Page Has Title Input
    Go To    ${BASE_URL}/new/
    Get Element    input[name="title"]

Create Page Has Body Textarea
    Go To    ${BASE_URL}/new/
    Get Element    textarea[name="body"]

Submitting Form Creates Memo And Redirects To Detail
    Go To    ${BASE_URL}/new/
    Fill Text    input[name="title"]    My new memo
    Fill Text    textarea[name="body"]    This is the body
    Click    button[type="submit"]
    Get Text    body    *=    My new memo
    Get Text    body    *=    This is the body

Created Memo Appears In List
    Go To    ${BASE_URL}/new/
    Fill Text    input[name="title"]    Listed memo
    Fill Text    textarea[name="body"]    list body
    Click    button[type="submit"]
    Go To    ${BASE_URL}
    Get Text    body    *=    Listed memo

Submitting Empty Title Stays On Form
    Go To    ${BASE_URL}/new/
    Fill Text    textarea[name="body"]    no title here
    Click    button[type="submit"]
    Get Element    input[name="title"]

Create Page Has Link Back To List
    Go To    ${BASE_URL}/new/
    Get Element    a.back-link[href="/"]
