FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN pip install --no-cache-dir paho-mqtt==2.1.0 tomli==2.2.1 \
    && groupadd --gid 10001 simulator \
    && useradd --uid 10001 --gid simulator --no-create-home simulator

COPY --chown=simulator:simulator main.py config.py mqtt_utils.py utils.py config.toml LICENSE ./
COPY --chown=simulator:simulator protocol/ ./protocol/

USER simulator

CMD ["python", "main.py"]