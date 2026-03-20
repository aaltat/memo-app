from django.urls import URLPattern, URLResolver, path

from memos import views

app_name = "memos"

urlpatterns: list[URLPattern | URLResolver] = [
    path("", views.memo_list, name="list"),
    path("new/", views.memo_create, name="create"),
    path("<str:memo_id>/", views.memo_detail, name="detail"),
    path("<str:memo_id>/edit/", views.memo_edit, name="edit"),
    path("<str:memo_id>/delete/", views.memo_delete, name="delete"),
    path("<str:memo_id>/toggle/<int:item_index>/", views.memo_toggle_checklist, name="toggle"),
]
