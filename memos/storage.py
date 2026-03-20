from __future__ import annotations

import logging
import re
import uuid
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path

import frontmatter
from django.conf import settings

logger = logging.getLogger(__name__)


class MemoNotFound(Exception):
    pass


@dataclass
class Memo:
    id: str
    title: str
    body: str
    created_at: datetime
    updated_at: datetime


def _memo_dir() -> Path:
    path = Path(settings.MEMO_DIR)
    path.mkdir(parents=True, exist_ok=True)
    return path


def _file_path(memo_id: str) -> Path:
    return _memo_dir() / f"{memo_id}.md"


def _parse_datetime(value: object) -> datetime:
    if isinstance(value, datetime):
        if value.tzinfo is None:
            return value.replace(tzinfo=UTC)
        return value
    return datetime.fromisoformat(str(value))


def _load(path: Path) -> Memo:
    post = frontmatter.load(str(path))
    return Memo(
        id=str(post["id"]),
        title=str(post["title"]),
        body=str(post.content),
        created_at=_parse_datetime(post["created_at"]),
        updated_at=_parse_datetime(post["updated_at"]),
    )


def list_memos() -> list[Memo]:
    memos = [_load(p) for p in _memo_dir().glob("*.md")]
    result = sorted(memos, key=lambda m: m.updated_at, reverse=True)
    logger.debug("Listed %d memos", len(result))
    return result


def get_memo(memo_id: str) -> Memo:
    path = _file_path(memo_id)
    if not path.exists():
        logger.warning("Memo not found: %s", memo_id)
        raise MemoNotFound(memo_id)
    memo = _load(path)
    logger.debug("Fetched memo %s", memo_id)
    return memo


def save_memo(title: str, body: str, memo_id: str | None = None) -> Memo:
    now = datetime.now(UTC)
    if memo_id is None:
        memo_id = str(uuid.uuid4())
        created_at = now
        action = "Created"
    else:
        existing = get_memo(memo_id)
        created_at = existing.created_at
        action = "Updated"

    post = frontmatter.Post(
        body,
        id=memo_id,
        title=title,
        created_at=created_at.isoformat(),
        updated_at=now.isoformat(),
    )
    _file_path(memo_id).write_text(frontmatter.dumps(post))
    logger.info("%s memo %s title=%r", action, memo_id, title)

    return Memo(
        id=memo_id,
        title=title,
        body=body,
        created_at=created_at,
        updated_at=now,
    )


def delete_memo(memo_id: str) -> None:
    path = _file_path(memo_id)
    if not path.exists():
        logger.warning("Delete failed, memo not found: %s", memo_id)
        raise MemoNotFound(memo_id)
    path.unlink()
    logger.info("Deleted memo %s", memo_id)


def search_memos(query: str) -> list[Memo]:
    memos = list_memos()
    if not query:
        return memos
    q = query.lower()
    results = [m for m in memos if q in m.title.lower() or q in m.body.lower()]
    logger.debug("Search query=%r returned %d of %d memos", query, len(results), len(memos))
    return results


_CHECKBOX_LINE = re.compile(r"^- \[[ x]\] ", re.MULTILINE)


def toggle_checklist_item(body: str, item_index: int) -> str:
    """Flip the checked state of the item_index-th checkbox line in body."""
    matches = list(_CHECKBOX_LINE.finditer(body))
    if item_index < 0 or item_index >= len(matches):
        logger.warning("Toggle failed: no checkbox at index %d", item_index)
        raise IndexError(f"No checkbox at index {item_index}")
    match = matches[item_index]
    chunk = body[match.start() : match.end()]
    flipped = chunk.replace("[ ]", "[x]") if "[ ]" in chunk else chunk.replace("[x]", "[ ]")
    logger.debug("Toggled checklist item %d", item_index)
    return body[: match.start()] + flipped + body[match.end() :]
