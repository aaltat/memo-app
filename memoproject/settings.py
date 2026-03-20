from os import environ
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = environ.get("DJANGO_SECRET_KEY", "django-insecure-dev-only-change-in-production")

DEBUG = environ.get("DJANGO_DEBUG", "true").lower() == "true"

ALLOWED_HOSTS = environ.get("DJANGO_ALLOWED_HOSTS", "localhost 127.0.0.1 0.0.0.0").split()

INSTALLED_APPS = [
    "django.contrib.contenttypes",
    "django.contrib.staticfiles",
    "memos",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "memoproject.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
            ],
        },
    },
]

WSGI_APPLICATION = "memoproject.wsgi.application"

DATABASES: dict = {}

LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = False
USE_TZ = True

STATIC_URL = "static/"

# Directory where memo .md files are stored
MEMO_DIR = Path(environ.get("MEMO_DIR", BASE_DIR / "data" / "memos"))
