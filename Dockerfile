FROM python:3.8-slim

ENV HOME /app
WORKDIR /app
ENV PATH="/app/.local/bin:${PATH}"

# Install system dependencies
RUN apt-get update \
    && apt-get -y install libpq-dev gcc \
    && pip install psycopg2

# Copy requirements.txt into working directory and install
COPY ./app/requirements.txt ./requirements.txt
RUN pip install -r /app/requirements.txt

# Copy rest of app files into workdir
COPY ./app .
COPY .env .
COPY migrations ./migrations

# Set app config option
ARG FLASK_DEBUG
ENV FLASK_DEBUG=$FLASK_DEBUG

# Set argument vars for docker-run command
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION
ARG FLASK_SECRET

# Set AWS cred env vars
ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ENV AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
ENV FLASK_SECRET=$FLASK_SECRET

CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app", "--workers=5"]
