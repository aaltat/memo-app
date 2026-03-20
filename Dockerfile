FROM python:3.12-slim

WORKDIR /app

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Copy dependency files first for better layer caching
COPY pyproject.toml uv.lock ./

# Install only runtime dependencies (no dev/test/lint groups)
RUN uv sync --no-dev --frozen

# Copy application source
COPY manage.py ./
COPY memoproject/ ./memoproject/
COPY memos/ ./memos/

# Create data directory (overridden by volume mount at runtime)
RUN mkdir -p /data/memos

ENV MEMO_DIR=/data/memos \
    DJANGO_DEBUG=false

EXPOSE 8000

CMD ["uv", "run", "gunicorn", "memoproject.wsgi:application", \
     "--bind", "0.0.0.0:8000", "--workers", "2"]
