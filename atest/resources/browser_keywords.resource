*** Settings ***
Documentation    Browser-level keywords for memo app acceptance tests.
Library          Browser


*** Keywords ***
Open Memo App
    [Documentation]    Open the memo app home page.
    [Arguments]    ${base_url}=http://localhost:8000
    New Browser    chromium    headless=True
    New Page       ${base_url}
