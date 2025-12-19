# Dockerfile for SimStruct AI Model API
# Python FastAPI service with PyTorch Deep Learning model

FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements first (for better caching)
COPY requirements.txt .

# Install Python dependencies (without build tools to reduce size)
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code, models, and data
COPY src/ ./src/
COPY models/ ./models/
COPY data/ ./data/

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# Run the API
CMD ["python", "-m", "uvicorn", "src.api:app", "--host", "0.0.0.0", "--port", "8000"]
