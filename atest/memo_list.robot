*** Settings ***
Documentation       Acceptance tests for the memo list and search feature.
...                 Requires the app to be running at BASE_URL (default: http://localhost:8000).
...                 Start the server with: uv run python manage.py runserver
...                 or: docker compose up

Library             Browser
Library             RequestsLibrary
Library             resources/StorageLibrary.py

Suite Setup         Open Browser Session
Suite Teardown      Close Browser
Test Setup          Set Up Storage    path=data/memos
Test Teardown       Tear Down Storage

Test Tags           feature:list


*** Variables ***
${BASE_URL}     http://localhost:8000


*** Test Cases ***
GET Root Returns 200
    [Documentation]    The memo list endpoint responds with HTTP 200.
    [Tags]    api
    GET    ${BASE_URL}/    expected_status=200

Empty Storage Shows No Memo Content
    [Documentation]    With no memos saved, the list page loads without any memo titles.
    [Tags]    browser
    Go To    ${BASE_URL}
    Get Title    ==    Memos

Saved Memo Title Appears In List
    [Documentation]    A memo saved to storage is displayed in the list page.
    [Tags]    browser
    Create Memo Via Storage    title=My first memo    body=hello world
    Go To    ${BASE_URL}
    Get Text    body    *=    My first memo

Multiple Memo Titles Are All Visible
    [Documentation]    All saved memo titles are shown on the list page.
    [Tags]    browser
    Create Memo Via Storage    title=Alpha memo    body=first
    Create Memo Via Storage    title=Beta memo    body=second
    Go To    ${BASE_URL}
    Get Text    body    *=    Alpha memo
    Get Text    body    *=    Beta memo

Search Filters Memos By Title
    [Documentation]    Typing in the search box filters the visible memos by title match.
    [Tags]    browser
    Create Memo Via Storage    title=Shopping list    body=eggs milk
    Create Memo Via Storage    title=Work notes    body=meeting
    Go To    ${BASE_URL}
    Fill Text    input[name="q"]    Shopping
    Press Keys    input[name="q"]    Enter
    Get Text    body    *=    Shopping list
    Get Text    body    not contains    Work notes

Search Filters Memos By Body Content
    [Documentation]    Search also matches memo body text.
    [Tags]    browser
    Create Memo Via Storage    title=Random note    body=remember the dentist
    Create Memo Via Storage    title=Other note    body=nothing here
    Go To    ${BASE_URL}
    Fill Text    input[name="q"]    dentist
    Press Keys    input[name="q"]    Enter
    Get Text    body    *=    Random note
    Get Text    body    not contains    Other note

Empty Search Shows All Memos
    [Documentation]    Submitting an empty search query shows all memos.
    [Tags]    browser
    Create Memo Via Storage    title=Apple    body=fruit
    Create Memo Via Storage    title=Banana    body=also fruit
    Go To    ${BASE_URL}?q=${EMPTY}
    Get Text    body    *=    Apple
    Get Text    body    *=    Banana

Delete Button Is Present On Each Memo Card
    [Documentation]    Each memo card in the list shows a delete button.
    [Tags]    browser
    ${id}=    Create Memo Via Storage    title=Has Delete Button    body=body text
    Go To    ${BASE_URL}
    Get Element    form[action="/${id}/delete/"] button[type="submit"]

Clicking Delete Button Removes Memo From List
    [Documentation]    Clicking the delete button on a memo card removes it from the list without a page reload.
    [Tags]    browser
    ${id}=    Create Memo Via Storage    title=Memo To Delete    body=goodbye
    Go To    ${BASE_URL}
    Get Text    body    *=    Memo To Delete
    Click    form[action="/${id}/delete/"] button[type="submit"]
    Get Text    body    not contains    Memo To Delete

No Match Shows No Memo Titles
    [Documentation]    A search with no matching memos shows an empty result.
    [Tags]    browser
    Create Memo Via Storage    title=Hello world    body=some content
    Go To    ${BASE_URL}?q=xyz123notexist
    Get Text    body    not contains    Hello world

Search Query Is Preserved In Input
    [Documentation]    After searching, the query value remains visible in the search input.
    [Tags]    browser
    Go To    ${BASE_URL}?q=myquery
    Get Property    input[name="q"]    value    ==    myquery


*** Keywords ***
Open Browser Session
    [Documentation]    Launch a headless Chromium browser and open the app.
    New Browser    chromium    headless=True
    New Context
    New Page    ${BASE_URL}

Create Memo Via Storage
    [Documentation]    Save a memo directly via storage (no UI interaction).
    [Arguments]    ${title}    ${body}=${EMPTY}
    ${id}=    Save Memo    title=${title}    body=${body}
    RETURN    ${id}
