FROM python:3.11.4

ENV POETRY_VERSION=1.6.1

RUN pip install "poetry==$POETRY_VERSION"

WORKDIR /app
COPY ./poetry.lock ./pyproject.toml .

# Project initialization:
RUN poetry config virtualenvs.create false
RUN poetry install --no-dev --no-root --no-interaction --no-ansi

# copy and run program
COPY ./src/ .
CMD [ "python", "example.py" ]
