from pathlib import Path

import pytest


@pytest.fixture
def tmp_memo_dir(tmp_path: Path, settings: pytest.FixtureRequest) -> Path:
    """Override MEMO_DIR to a temporary directory for each test."""
    memo_dir = tmp_path / "memos"
    memo_dir.mkdir()
    settings.MEMO_DIR = memo_dir  # type: ignore[attr-defined]
    return memo_dir
