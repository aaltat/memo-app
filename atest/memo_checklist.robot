*** Settings ***
Documentation       Acceptance tests for the checklist toggle feature.

Resource            resources/browser.resource

Suite Setup         Open Browser Session
Suite Teardown      Close Browser
Test Setup          Set Up Storage    path=data/memos
Test Teardown       Tear Down Storage

Test Tags           feature:checklist    browser


*** Test Cases ***
Checklist Items Appear As Checkboxes
    ${id}=    Create Memo Via Storage    title=Tasks    body=- [ ] buy milk\n- [ ] call dentist
    Go To    ${BASE_URL}/${id}/
    Get Elements    input[type="checkbox"]

Unchecked Checkbox Is Initially Unchecked
    ${id}=    Create Memo Via Storage    title=Tasks    body=- [ ] unchecked item
    Go To    ${BASE_URL}/${id}/
    Get Property    input[type="checkbox"]    checked    ==    ${False}

Checked Checkbox Is Initially Checked
    ${id}=    Create Memo Via Storage    title=Tasks    body=- [x] already done
    Go To    ${BASE_URL}/${id}/
    Get Property    input[type="checkbox"]    checked    ==    ${True}

Clicking Unchecked Checkbox Marks It Checked
    ${id}=    Create Memo Via Storage    title=Tasks    body=- [ ] buy milk
    Go To    ${BASE_URL}/${id}/
    Click    input[type="checkbox"]
    Get Property    input[type="checkbox"]    checked    ==    ${True}

Clicking Checked Checkbox Marks It Unchecked
    ${id}=    Create Memo Via Storage    title=Tasks    body=- [x] done item
    Go To    ${BASE_URL}/${id}/
    Click    input[type="checkbox"]
    Get Property    input[type="checkbox"]    checked    ==    ${False}

Toggle State Is Persisted
    ${id}=    Create Memo Via Storage    title=Tasks    body=- [ ] persistent item
    Go To    ${BASE_URL}/${id}/
    Click    input[type="checkbox"]
    Wait For Load State    networkidle
    Go To    ${BASE_URL}/${id}/
    Get Property    input[type="checkbox"]    checked    ==    ${True}

Second Item Can Be Toggled Independently
    ${id}=    Create Memo Via Storage    title=Tasks    body=- [ ] first item\n- [ ] second item
    Go To    ${BASE_URL}/${id}/
    Click    (//input[@type="checkbox"])[2]
    Get Property    (//input[@type="checkbox"])[1]    checked    ==    ${False}
    Get Property    (//input[@type="checkbox"])[2]    checked    ==    ${True}
