*** Settings ***
Documentation       Acceptance tests for the memo list and search feature.

Library             RequestsLibrary
Resource            resources/browser.resource

Suite Setup         Open Browser Session
Suite Teardown      Close Browser
Test Setup          Set Up Storage    path=data/memos
Test Teardown       Tear Down Storage

Test Tags           feature:list    browser


*** Test Cases ***
GET Root Returns 200
    [Tags]    api
    GET    ${BASE_URL}/    expected_status=200

Empty Storage Shows No Memo Content
    Go To    ${BASE_URL}
    Get Title    ==    Memos

Saved Memo Title Appears In List
    Create Memo Via Storage    title=My first memo    body=hello world
    Go To    ${BASE_URL}
    Get Text    body    *=    My first memo

Multiple Memo Titles Are All Visible
    Create Memo Via Storage    title=Alpha memo    body=first
    Create Memo Via Storage    title=Beta memo    body=second
    Go To    ${BASE_URL}
    Get Text    body    *=    Alpha memo
    Get Text    body    *=    Beta memo

Search Filters Memos By Title
    Create Memo Via Storage    title=Shopping list    body=eggs milk
    Create Memo Via Storage    title=Work notes    body=meeting
    Go To    ${BASE_URL}
    Fill Text    input[name="q"]    Shopping
    Press Keys    input[name="q"]    Enter
    Get Text    body    *=    Shopping list
    Get Text    body    not contains    Work notes

Search Filters Memos By Body Content
    Create Memo Via Storage    title=Random note    body=remember the dentist
    Create Memo Via Storage    title=Other note    body=nothing here
    Go To    ${BASE_URL}
    Fill Text    input[name="q"]    dentist
    Press Keys    input[name="q"]    Enter
    Get Text    body    *=    Random note
    Get Text    body    not contains    Other note

Empty Search Shows All Memos
    Create Memo Via Storage    title=Apple    body=fruit
    Create Memo Via Storage    title=Banana    body=also fruit
    Go To    ${BASE_URL}?q=${EMPTY}
    Get Text    body    *=    Apple
    Get Text    body    *=    Banana

Delete Button Is Present On Each Memo Card
    ${id}=    Create Memo Via Storage    title=Has Delete Button    body=body text
    Go To    ${BASE_URL}
    Get Element    form[action="/${id}/delete/"] button[type="submit"]

Clicking Delete Button Removes Memo From List
    ${id}=    Create Memo Via Storage    title=Memo To Delete    body=goodbye
    Go To    ${BASE_URL}
    Get Text    body    *=    Memo To Delete
    Click    form[action="/${id}/delete/"] button[type="submit"]
    Get Text    body    not contains    Memo To Delete

No Match Shows No Memo Titles
    Create Memo Via Storage    title=Hello world    body=some content
    Go To    ${BASE_URL}?q=xyz123notexist
    Get Text    body    not contains    Hello world

Search Query Is Preserved In Input
    Go To    ${BASE_URL}?q=myquery
    Get Property    input[name="q"]    value    ==    myquery
