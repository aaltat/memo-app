*** Settings ***
Documentation    Top-level suite init: delete all memos after the full test run.

Library          resources/StorageLibrary.py

Suite Teardown   Delete All Memos    path=data/memos
