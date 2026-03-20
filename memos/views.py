import markdown
from django.http import Http404, HttpRequest, HttpResponse
from django.shortcuts import redirect, render

from memos.storage import MemoNotFound, delete_memo, get_memo, list_memos, save_memo, search_memos


def memo_list(request: HttpRequest) -> HttpResponse:
    query = request.GET.get("q", "")
    memos = search_memos(query) if query else list_memos()
    return render(request, "memos/list.html", {"memos": memos, "query": query})


def memo_create(request: HttpRequest) -> HttpResponse:
    if request.method == "POST":
        title = request.POST.get("title", "").strip()
        body = request.POST.get("body", "")
        if title:
            memo = save_memo(title=title, body=body)
            return redirect("memos:detail", memo_id=memo.id)
        return render(request, "memos/create.html", {"title": title, "body": body})
    return render(request, "memos/create.html", {})


def memo_detail(request: HttpRequest, memo_id: str) -> HttpResponse:
    try:
        memo = get_memo(memo_id)
    except MemoNotFound:
        raise Http404 from None
    body_html = markdown.markdown(memo.body, extensions=["extra"])
    return render(request, "memos/detail.html", {"memo": memo, "body_html": body_html})


def memo_edit(request: HttpRequest, memo_id: str) -> HttpResponse:
    try:
        memo = get_memo(memo_id)
    except MemoNotFound:
        raise Http404 from None
    if request.method == "POST":
        title = request.POST.get("title", "").strip()
        body = request.POST.get("body", "")
        if title:
            save_memo(title=title, body=body, memo_id=memo_id)
            return redirect("memos:detail", memo_id=memo_id)
        return render(request, "memos/edit.html", {"memo": memo, "title": title, "body": body})
    return render(
        request,
        "memos/edit.html",
        {
            "memo": memo,
            "title": memo.title,
            "body": memo.body,
        },
    )


def memo_delete(request: HttpRequest, memo_id: str) -> HttpResponse:
    try:
        memo = get_memo(memo_id)
    except MemoNotFound:
        raise Http404 from None
    if request.method == "POST":
        delete_memo(memo_id)
        return redirect("memos:list")
    return render(request, "memos/delete.html", {"memo": memo})


def memo_toggle_checklist(request: HttpRequest, memo_id: str, item_index: int) -> HttpResponse:
    raise NotImplementedError
