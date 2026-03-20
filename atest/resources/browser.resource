*** Settings ***
Library             Browser
Library             StorageLibrary.py


*** Variables ***
${BASE_URL}     http://localhost:8000


*** Keywords ***
Open Browser Session
    New Browser    chromium    headless=True
    New Context
    New Page    ${BASE_URL}

Create Memo Via Storage
    [Arguments]    ${title}    ${body}=${EMPTY}
    ${id}=    Save Memo    title=${title}    body=${body}
    RETURN    ${id}
