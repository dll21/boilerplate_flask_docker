FROM python:3.9 as base

WORKDIR /app

# Force the stdout and stderr streams to be unbuffered. This option has no effect on the stdin stream.
ENV PYTHONUNBUFFERED=1
# Use Pycache Prefix to Move pyc Files out of Your Source Code Starting in Python 3.8
ENV PYTHONPYCACHEPREFIX=/tmp

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY requirements_dev.txt .
RUN pip install -r requirements_dev.txt

COPY pytest.ini .

FROM base as debug

RUN pip install debugpy

CMD ["python", "-m", "debugpy", "--listen", "0.0.0.0:5678", "--wait-for-client", "-m", "flask", "run", "-h", "0.0.0.0", "-p", "8000"]

FROM base as prod

CMD ["gunicorn", "-b", ":8000", "src.main:app", "--reload"]