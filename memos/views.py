import markdown
from django.http import Http404, HttpRequest, HttpResponse
from django.shortcuts import render

from memos.storage import MemoNotFound, get_memo, list_memos, search_memos


def memo_list(request: HttpRequest) -> HttpResponse:
    query = request.GET.get("q", "")
    memos = search_memos(query) if query else list_memos()
    return render(request, "memos/list.html", {"memos": memos, "query": query})


def memo_create(request: HttpRequest) -> HttpResponse:
    raise NotImplementedError


def memo_detail(request: HttpRequest, memo_id: str) -> HttpResponse:
    try:
        memo = get_memo(memo_id)
    except MemoNotFound:
        raise Http404 from None
    body_html = markdown.markdown(memo.body, extensions=["extra"])
    return render(request, "memos/detail.html", {"memo": memo, "body_html": body_html})


def memo_edit(request: HttpRequest, memo_id: str) -> HttpResponse:
    raise NotImplementedError


def memo_delete(request: HttpRequest, memo_id: str) -> HttpResponse:
    raise NotImplementedError


def memo_toggle_checklist(request: HttpRequest, memo_id: str, item_index: int) -> HttpResponse:
    raise NotImplementedError
