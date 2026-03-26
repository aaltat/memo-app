import logging
from pathlib import Path

import pytest


@pytest.fixture
def tmp_memo_dir(tmp_path: Path, settings: pytest.FixtureRequest) -> Path:
    """Override MEMO_DIR to a temporary directory for each test."""
    memo_dir = tmp_path / "memos"
    memo_dir.mkdir()
    settings.MEMO_DIR = memo_dir  # type: ignore[attr-defined]
    return memo_dir


@pytest.fixture
def memos_caplog(caplog: pytest.LogCaptureFixture) -> pytest.LogCaptureFixture:
    """caplog pre-wired for the memos logger (which has propagate=False)."""
    memos_logger = logging.getLogger("memos")
    memos_logger.addHandler(caplog.handler)
    caplog.set_level(logging.DEBUG, logger="memos")
    yield caplog
    memos_logger.removeHandler(caplog.handler)
