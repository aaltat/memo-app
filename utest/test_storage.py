import pytest

from memos.storage import (
    MemoNotFound,
    delete_memo,
    get_memo,
    list_memos,
    save_memo,
    search_memos,
    toggle_checklist_item,
)


class TestListMemos:
    def test_empty_directory_returns_empty_list(self, tmp_memo_dir: object) -> None:
        assert list_memos() == []

    def test_returns_saved_memo(self, tmp_memo_dir: object) -> None:
        save_memo(title="Hello", body="World")
        memos = list_memos()
        assert len(memos) == 1
        assert memos[0].title == "Hello"

    def test_sorted_newest_updated_first(self, tmp_memo_dir: object) -> None:
        save_memo(title="First", body="")
        save_memo(title="Second", body="")
        memos = list_memos()
        assert memos[0].title == "Second"
        assert memos[1].title == "First"


class TestSaveMemo:
    def test_creates_md_file_on_disk(self, tmp_memo_dir: object) -> None:
        from pathlib import Path

        memo = save_memo(title="Hello", body="World")
        assert isinstance(tmp_memo_dir, Path)
        assert (tmp_memo_dir / f"{memo.id}.md").exists()

    def test_returned_memo_has_correct_fields(self, tmp_memo_dir: object) -> None:
        memo = save_memo(title="My Title", body="My body text")
        assert memo.title == "My Title"
        assert memo.body == "My body text"
        assert memo.id
        assert memo.created_at
        assert memo.updated_at

    def test_create_sets_created_at_equal_to_updated_at(self, tmp_memo_dir: object) -> None:
        memo = save_memo(title="Test", body="")
        assert memo.created_at == memo.updated_at

    def test_update_preserves_created_at(self, tmp_memo_dir: object) -> None:
        original = save_memo(title="Original", body="body")
        updated = save_memo(title="Updated", body="new body", memo_id=original.id)
        assert updated.created_at == original.created_at

    def test_update_changes_title_and_body(self, tmp_memo_dir: object) -> None:
        original = save_memo(title="Original", body="old body")
        updated = save_memo(title="Updated", body="new body", memo_id=original.id)
        assert updated.id == original.id
        assert updated.title == "Updated"
        assert updated.body == "new body"

    def test_update_persists_to_disk(self, tmp_memo_dir: object) -> None:
        original = save_memo(title="Original", body="old body")
        save_memo(title="Updated", body="new body", memo_id=original.id)
        fetched = get_memo(original.id)
        assert fetched.title == "Updated"
        assert fetched.body == "new body"


class TestGetMemo:
    def test_returns_memo_by_id(self, tmp_memo_dir: object) -> None:
        saved = save_memo(title="Test", body="Body text")
        fetched = get_memo(saved.id)
        assert fetched.id == saved.id
        assert fetched.title == "Test"
        assert fetched.body == "Body text"

    def test_raises_memo_not_found_for_unknown_id(self, tmp_memo_dir: object) -> None:
        with pytest.raises(MemoNotFound):
            get_memo("nonexistent-id")


class TestDeleteMemo:
    def test_removes_file_from_disk(self, tmp_memo_dir: object) -> None:
        from pathlib import Path

        memo = save_memo(title="To delete", body="bye")
        delete_memo(memo.id)
        assert isinstance(tmp_memo_dir, Path)
        assert not (tmp_memo_dir / f"{memo.id}.md").exists()

    def test_memo_not_found_after_deletion(self, tmp_memo_dir: object) -> None:
        memo = save_memo(title="To delete", body="bye")
        delete_memo(memo.id)
        with pytest.raises(MemoNotFound):
            get_memo(memo.id)

    def test_raises_memo_not_found_for_unknown_id(self, tmp_memo_dir: object) -> None:
        with pytest.raises(MemoNotFound):
            delete_memo("nonexistent-id")


class TestSearchMemos:
    def test_finds_memo_by_title(self, tmp_memo_dir: object) -> None:
        save_memo(title="Shopping list", body="eggs milk")
        save_memo(title="Work notes", body="meeting at 3")
        results = search_memos("shopping")
        assert len(results) == 1
        assert results[0].title == "Shopping list"

    def test_finds_memo_by_body(self, tmp_memo_dir: object) -> None:
        save_memo(title="Note", body="remember to buy eggs")
        save_memo(title="Other", body="nothing relevant")
        results = search_memos("eggs")
        assert len(results) == 1
        assert results[0].title == "Note"

    def test_search_is_case_insensitive(self, tmp_memo_dir: object) -> None:
        save_memo(title="UPPERCASE Title", body="body")
        assert len(search_memos("uppercase")) == 1

    def test_empty_query_returns_all_memos(self, tmp_memo_dir: object) -> None:
        save_memo(title="A", body="")
        save_memo(title="B", body="")
        assert len(search_memos("")) == 2

    def test_no_match_returns_empty_list(self, tmp_memo_dir: object) -> None:
        save_memo(title="Hello", body="World")
        assert search_memos("xyz123") == []


class TestToggleChecklistItem:
    def test_toggles_unchecked_to_checked(self) -> None:
        result = toggle_checklist_item("- [ ] buy milk", 0)
        assert "- [x] buy milk" in result

    def test_toggles_checked_to_unchecked(self) -> None:
        result = toggle_checklist_item("- [x] done item", 0)
        assert "- [ ] done item" in result

    def test_toggles_second_item_by_index(self) -> None:
        body = "- [ ] first\n- [ ] second\n- [ ] third"
        result = toggle_checklist_item(body, 1)
        assert "- [ ] first" in result
        assert "- [x] second" in result
        assert "- [ ] third" in result

    def test_raises_index_error_for_out_of_range(self) -> None:
        with pytest.raises(IndexError):
            toggle_checklist_item("- [ ] only one", 1)

    def test_does_not_affect_non_checkbox_lines(self) -> None:
        body = "intro text\n- [ ] task\ntrailing text"
        result = toggle_checklist_item(body, 0)
        assert "intro text" in result
        assert "trailing text" in result

    def test_mixed_states_toggle_independently(self) -> None:
        body = "- [x] checked\n- [ ] unchecked"
        result = toggle_checklist_item(body, 0)
        assert "- [ ] checked" in result
        assert "- [ ] unchecked" in result


class TestStorageLogging:
    def test_save_memo_create_logs_info(
        self, tmp_memo_dir: object, memos_caplog: pytest.LogCaptureFixture
    ) -> None:
        memo = save_memo(title="Log test", body="hello")
        assert f"Created memo {memo.id}" in memos_caplog.text
        assert "Log test" in memos_caplog.text

    def test_save_memo_update_logs_info(
        self, tmp_memo_dir: object, memos_caplog: pytest.LogCaptureFixture
    ) -> None:
        memo = save_memo(title="Original", body="body")
        save_memo(title="Updated", body="new body", memo_id=memo.id)
        assert f"Updated memo {memo.id}" in memos_caplog.text
        assert "Updated" in memos_caplog.text

    def test_get_memo_missing_logs_warning(
        self, tmp_memo_dir: object, memos_caplog: pytest.LogCaptureFixture
    ) -> None:
        with pytest.raises(MemoNotFound):
            get_memo("no-such-id")
        assert "Memo not found" in memos_caplog.text
        assert "no-such-id" in memos_caplog.text

    def test_delete_memo_logs_info(
        self, tmp_memo_dir: object, memos_caplog: pytest.LogCaptureFixture
    ) -> None:
        memo = save_memo(title="Bye", body="")
        delete_memo(memo.id)
        assert f"Deleted memo {memo.id}" in memos_caplog.text

    def test_delete_memo_missing_logs_warning(
        self, tmp_memo_dir: object, memos_caplog: pytest.LogCaptureFixture
    ) -> None:
        with pytest.raises(MemoNotFound):
            delete_memo("ghost-id")
        assert "Delete failed, memo not found" in memos_caplog.text
        assert "ghost-id" in memos_caplog.text

    def test_list_memos_logs_debug(
        self, tmp_memo_dir: object, memos_caplog: pytest.LogCaptureFixture
    ) -> None:
        save_memo(title="A", body="")
        save_memo(title="B", body="")
        list_memos()
        assert "Listed 2 memos" in memos_caplog.text

    def test_search_memos_logs_debug(
        self, tmp_memo_dir: object, memos_caplog: pytest.LogCaptureFixture
    ) -> None:
        save_memo(title="Apples", body="")
        save_memo(title="Bananas", body="")
        search_memos("apples")
        assert "Search query='apples'" in memos_caplog.text
        assert "returned 1 of 2 memos" in memos_caplog.text

    def test_toggle_checklist_item_out_of_range_logs_warning(
        self, memos_caplog: pytest.LogCaptureFixture
    ) -> None:
        with pytest.raises(IndexError):
            toggle_checklist_item("- [ ] only one", 5)
        assert "Toggle failed: no checkbox at index 5" in memos_caplog.text
