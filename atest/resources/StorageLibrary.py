"""Robot Framework keyword library wrapping the storage layer for acceptance tests."""

from __future__ import annotations

import contextlib
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
        self._server_mode: bool = False
        self._created_ids: list[str] = []

    def _setup_django(self, memo_dir: Path) -> None:
        os.environ.setdefault("DJANGO_SETTINGS_MODULE", "memoproject.settings")
        if not django.conf.settings.configured:
            django.setup()
        django.conf.settings.MEMO_DIR = memo_dir

    @keyword("Set Up Storage")
    def set_up_storage(self, path: str = "") -> None:
        """Create a memo directory and configure Django settings.

        If ``path`` is given, writes to that directory (server mode — for browser
        acceptance tests where a real server is running). Created memo IDs are
        tracked so ``Tear Down Storage`` can clean them up without touching
        pre-existing memos.

        If ``path`` is omitted, a temporary directory is created (isolated mode —
        for pure storage tests with no running server).
        """
        self._created_ids = []
        if path:
            memo_dir = Path(path)
            memo_dir.mkdir(parents=True, exist_ok=True)
            self._tmp_dir = None
            self._server_mode = True
        else:
            self._tmp_dir = tempfile.TemporaryDirectory()
            memo_dir = Path(self._tmp_dir.name) / "memos"
            memo_dir.mkdir()
            self._server_mode = False
        self._setup_django(memo_dir)

    @keyword("Tear Down Storage")
    def tear_down_storage(self) -> None:
        """Clean up memos created during the test.

        In server mode, only memos created by this test run are deleted so that
        pre-existing memos are left untouched. In isolated mode the entire
        temporary directory is removed.
        """
        if self._server_mode:
            from memos.storage import MemoNotFound, delete_memo

            for memo_id in self._created_ids:
                with contextlib.suppress(MemoNotFound):
                    delete_memo(memo_id)
            self._created_ids = []
        elif self._tmp_dir:
            self._tmp_dir.cleanup()
            self._tmp_dir = None

    @keyword("Save Memo")
    def save_memo(self, title: str, body: str = "", memo_id: str | None = None) -> str:
        """Save a memo and return its id."""
        from memos.storage import save_memo

        memo = save_memo(title=title, body=body, memo_id=memo_id)
        if self._server_mode and memo_id is None:
            self._created_ids.append(memo.id)
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
        from django.conf import settings

        path = Path(settings.MEMO_DIR) / f"{memo_id}.md"
        if not path.exists():
            raise AssertionError(f"Expected memo file {path} to exist, but it does not.")

    @keyword("Delete All Memos")
    def delete_all_memos(self, path: str = "data/memos") -> None:
        """Delete every memo file in the given directory."""
        import contextlib

        from memos.storage import MemoNotFound, delete_memo, list_memos

        memo_dir = Path(path)
        self._setup_django(memo_dir)
        for memo in list_memos():
            with contextlib.suppress(MemoNotFound):
                delete_memo(memo.id)

    @keyword("Memo File Should Not Exist")
    def memo_file_should_not_exist(self, memo_id: str) -> None:
        """Verify that the .md file for memo_id does NOT exist on disk."""
        from django.conf import settings

        path = Path(settings.MEMO_DIR) / f"{memo_id}.md"
        if path.exists():
            raise AssertionError(f"Expected memo file {path} to not exist, but it does.")
