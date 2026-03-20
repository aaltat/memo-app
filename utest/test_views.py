import pytest
from django.test import Client

from memos.storage import save_memo


@pytest.fixture
def client() -> Client:
    return Client()


@pytest.fixture
def populated_memo_dir(tmp_memo_dir: object) -> None:
    save_memo(title="Shopping list", body="eggs milk bread")
    save_memo(title="Work notes", body="meeting at 3pm")
    save_memo(title="Book ideas", body="read more novels")


class TestMemoListView:
    def test_returns_200(self, client: Client, tmp_memo_dir: object) -> None:
        response = client.get("/")
        assert response.status_code == 200

    def test_empty_list_shows_no_memos(self, client: Client, tmp_memo_dir: object) -> None:
        response = client.get("/")
        assert response.status_code == 200
        assert b"Shopping list" not in response.content

    def test_shows_saved_memo_titles(self, client: Client, populated_memo_dir: None) -> None:
        response = client.get("/")
        assert b"Shopping list" in response.content
        assert b"Work notes" in response.content
        assert b"Book ideas" in response.content

    def test_shows_multiple_memos(self, client: Client, populated_memo_dir: None) -> None:
        response = client.get("/")
        content = response.content.decode()
        assert content.count("Shopping list") >= 1
        assert content.count("Work notes") >= 1

    def test_uses_list_template(self, client: Client, tmp_memo_dir: object) -> None:
        response = client.get("/")
        assert "memos/list.html" in [t.name for t in response.templates]

    def test_uses_base_template(self, client: Client, tmp_memo_dir: object) -> None:
        response = client.get("/")
        assert "memos/base.html" in [t.name for t in response.templates]


class TestMemoListSearch:
    def test_search_filters_by_title(self, client: Client, populated_memo_dir: None) -> None:
        response = client.get("/?q=shopping")
        content = response.content.decode()
        assert "Shopping list" in content
        assert "Work notes" not in content
        assert "Book ideas" not in content

    def test_search_filters_by_body(self, client: Client, populated_memo_dir: None) -> None:
        response = client.get("/?q=novels")
        content = response.content.decode()
        assert "Book ideas" in content
        assert "Shopping list" not in content

    def test_search_is_case_insensitive(self, client: Client, populated_memo_dir: None) -> None:
        response = client.get("/?q=WORK")
        assert b"Work notes" in response.content

    def test_empty_query_returns_all_memos(self, client: Client, populated_memo_dir: None) -> None:
        response = client.get("/?q=")
        content = response.content.decode()
        assert "Shopping list" in content
        assert "Work notes" in content
        assert "Book ideas" in content

    def test_no_match_returns_empty_results(self, client: Client, populated_memo_dir: None) -> None:
        response = client.get("/?q=xyz123notexist")
        assert response.status_code == 200
        content = response.content.decode()
        assert "Shopping list" not in content
        assert "Work notes" not in content

    def test_search_query_preserved_in_response(
        self, client: Client, populated_memo_dir: None
    ) -> None:
        response = client.get("/?q=shopping")
        assert b"shopping" in response.content
