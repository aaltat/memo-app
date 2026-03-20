from django.urls import include, path

urlpatterns = [
    path("", include("memos.urls")),
]
