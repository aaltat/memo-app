*** Settings ***
Documentation    HTTP/API-level keywords for memo app acceptance tests.
Library          RequestsLibrary


*** Keywords ***
Create Session To Memo App
    [Documentation]    Create a requests session targeting the memo app.
    [Arguments]    ${base_url}=http://localhost:8000
    Create Session    memo    ${base_url}
