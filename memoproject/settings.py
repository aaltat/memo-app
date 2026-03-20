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

_LOG_DIR = BASE_DIR / "logs"
_LOG_DIR.mkdir(exist_ok=True)

LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "standard": {
            "format": "%(asctime)s %(levelname)s %(name)s %(message)s",
        },
    },
    "handlers": {
        "file": {
            "class": "logging.handlers.RotatingFileHandler",
            "filename": _LOG_DIR / "memo.log",
            "maxBytes": 5 * 1024 * 1024,
            "backupCount": 5,
            "formatter": "standard",
        },
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "standard",
        },
    },
    "loggers": {
        "memos": {
            "handlers": ["file", "console"],
            "level": "DEBUG" if DEBUG else "INFO",
            "propagate": False,
        },
    },
}
