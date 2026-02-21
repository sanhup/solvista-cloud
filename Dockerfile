FROM docker.io/python:3.14-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*


# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY ./src /app/src

# Command will be overridden in docker-compose
CMD ["uvicorn", "src.api:app", "--host", "0.0.0.0", "--port", "8000"]
