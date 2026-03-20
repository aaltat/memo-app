*** Settings ***
Documentation       Acceptance tests for the memo storage layer.
...                 These tests verify storage behaviour using Robot Framework keywords
...                 that wrap the Python storage module directly.

Library             resources/StorageLibrary.py

Test Setup          Set Up Storage
Test Teardown       Tear Down Storage


*** Test Cases ***
Empty Storage Returns No Memos
    [Documentation]    A fresh storage directory contains no memos.
    ${memos}=    List Memos
    Should Be Empty    ${memos}

Save Memo Creates A File On Disk
    [Documentation]    Saving a memo persists a .md file under the memo directory.
    ${id}=    Save Memo    title=Grocery list    body=eggs milk bread
    Memo File Should Exist    ${id}

Saved Memo Appears In List
    [Documentation]    A saved memo is returned by List Memos.
    Save Memo    title=Meeting notes    body=discuss roadmap
    ${memos}=    List Memos
    ${titles}=    Evaluate    [m["title"] for m in $memos]
    Should Contain    ${titles}    Meeting notes

Get Memo Returns Correct Title And Body
    [Documentation]    Get Memo returns the exact title and body that were saved.
    ${id}=    Save Memo    title=Todo    body=buy flowers
    ${memo}=    Get Memo    ${id}
    Should Be Equal    ${memo}[title]    Todo
    Should Be Equal    ${memo}[body]    buy flowers

Update Memo Preserves Id And Changes Content
    [Documentation]    Saving with an existing id updates title and body, keeping the same id.
    ${id}=    Save Memo    title=Draft    body=original text
    Save Memo    title=Final    body=updated text    memo_id=${id}
    ${memo}=    Get Memo    ${id}
    Should Be Equal    ${memo}[id]    ${id}
    Should Be Equal    ${memo}[title]    Final
    Should Be Equal    ${memo}[body]    updated text

Delete Memo Removes File From Disk
    [Documentation]    Deleting a memo removes its .md file from disk.
    ${id}=    Save Memo    title=To be deleted    body=temporary
    Delete Memo    ${id}
    Memo File Should Not Exist    ${id}

Deleted Memo Does Not Appear In List
    [Documentation]    A deleted memo is no longer returned by List Memos.
    ${id}=    Save Memo    title=Deleted memo    body=gone
    Delete Memo    ${id}
    ${memos}=    List Memos
    ${titles}=    Evaluate    [m["title"] for m in $memos]
    Should Not Contain    ${titles}    Deleted memo

Search Finds Memo By Title
    [Documentation]    Search returns memos whose title matches the query (case-insensitive).
    Save Memo    title=Shopping list    body=apples
    ${results}=    Search Memos    shopping
    ${titles}=    Evaluate    [m["title"] for m in $results]
    Should Contain    ${titles}    Shopping list

Search Finds Memo By Body
    [Documentation]    Search returns memos whose body contains the query.
    Save Memo    title=Random note    body=remember to call doctor
    ${results}=    Search Memos    doctor
    ${titles}=    Evaluate    [m["title"] for m in $results]
    Should Contain    ${titles}    Random note

Search With Empty Query Returns All Memos
    [Documentation]    An empty search query returns all stored memos.
    Save Memo    title=Alpha    body=first
    Save Memo    title=Beta    body=second
    ${all}=    List Memos
    ${results}=    Search Memos    ${EMPTY}
    Length Should Be    ${results}    ${all.__len__()}

Search With No Match Returns Empty List
    [Documentation]    A query that matches nothing returns an empty list.
    Save Memo    title=Hello world    body=some content
    ${results}=    Search Memos    xyz123notexist
    Should Be Empty    ${results}
