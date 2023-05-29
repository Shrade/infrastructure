FROM tiangolo/uvicorn-gunicorn-fastapi:python3.8

RUN pip install -U pip

RUN pip install protobuf==3.20.* sentry-sdk

COPY app /app

WORKDIR /app/

CMD exec /start-reload.sh