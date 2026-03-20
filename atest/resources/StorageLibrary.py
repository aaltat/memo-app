"""Robot Framework keyword library wrapping the storage layer for acceptance tests."""

from __future__ import annotations

import os
import tempfile
from pathlib import Path

import django
import django.conf
from robot.api.deco import keyword, library


@library(scope="TEST", auto_keywords=False)
class StorageLibrary:
    """Keywords for testing the memo storage layer directly."""

    def __init__(self) -> None:
        self._tmp_dir: tempfile.TemporaryDirectory[str] | None = None

    def _setup_django(self, memo_dir: Path) -> None:
        os.environ.setdefault("DJANGO_SETTINGS_MODULE", "memoproject.settings")
        if not django.conf.settings.configured:
            django.setup()
        django.conf.settings.MEMO_DIR = memo_dir

    @keyword("Set Up Storage")
    def set_up_storage(self) -> None:
        """Create a temporary memo directory and configure Django settings."""
        self._tmp_dir = tempfile.TemporaryDirectory()
        memo_dir = Path(self._tmp_dir.name) / "memos"
        memo_dir.mkdir()
        self._setup_django(memo_dir)

    @keyword("Tear Down Storage")
    def tear_down_storage(self) -> None:
        """Remove the temporary memo directory."""
        if self._tmp_dir:
            self._tmp_dir.cleanup()
            self._tmp_dir = None

    @keyword("Save Memo")
    def save_memo(self, title: str, body: str = "", memo_id: str | None = None) -> str:
        """Save a memo and return its id."""
        from memos.storage import save_memo

        memo = save_memo(title=title, body=body, memo_id=memo_id)
        return memo.id

    @keyword("List Memos")
    def list_memos(self) -> list[dict[str, str]]:
        """Return all memos as a list of dicts with id and title."""
        from memos.storage import list_memos

        return [{"id": m.id, "title": m.title} for m in list_memos()]

    @keyword("Get Memo")
    def get_memo(self, memo_id: str) -> dict[str, str]:
        """Return a memo dict with id, title, and body."""
        from memos.storage import get_memo

        m = get_memo(memo_id)
        return {"id": m.id, "title": m.title, "body": m.body}

    @keyword("Delete Memo")
    def delete_memo(self, memo_id: str) -> None:
        """Delete a memo by id."""
        from memos.storage import delete_memo

        delete_memo(memo_id)

    @keyword("Search Memos")
    def search_memos(self, query: str) -> list[dict[str, str]]:
        """Search memos and return matching list of dicts with id and title."""
        from memos.storage import search_memos

        return [{"id": m.id, "title": m.title} for m in search_memos(query)]

    @keyword("Memo File Should Exist")
    def memo_file_should_exist(self, memo_id: str) -> None:
        """Verify that the .md file for memo_id exists on disk."""
        assert self._tmp_dir is not None, "Storage not set up"
        from django.conf import settings

        path = Path(settings.MEMO_DIR) / f"{memo_id}.md"
        if not path.exists():
            raise AssertionError(f"Expected memo file {path} to exist, but it does not.")

    @keyword("Memo File Should Not Exist")
    def memo_file_should_not_exist(self, memo_id: str) -> None:
        """Verify that the .md file for memo_id does NOT exist on disk."""
        assert self._tmp_dir is not None, "Storage not set up"
        from django.conf import settings

        path = Path(settings.MEMO_DIR) / f"{memo_id}.md"
        if path.exists():
            raise AssertionError(f"Expected memo file {path} to not exist, but it does.")
