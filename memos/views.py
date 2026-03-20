from django.http import HttpRequest, HttpResponse
from django.shortcuts import render

from memos.storage import list_memos, search_memos


def memo_list(request: HttpRequest) -> HttpResponse:
    query = request.GET.get("q", "")
    memos = search_memos(query) if query else list_memos()
    return render(request, "memos/list.html", {"memos": memos, "query": query})


def memo_create(request: HttpRequest) -> HttpResponse:
    raise NotImplementedError


def memo_detail(request: HttpRequest, memo_id: str) -> HttpResponse:
    raise NotImplementedError


def memo_edit(request: HttpRequest, memo_id: str) -> HttpResponse:
    raise NotImplementedError


def memo_delete(request: HttpRequest, memo_id: str) -> HttpResponse:
    raise NotImplementedError


def memo_toggle_checklist(request: HttpRequest, memo_id: str, item_index: int) -> HttpResponse:
    raise NotImplementedError
