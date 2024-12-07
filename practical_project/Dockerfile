FROM python:3.12-slim
RUN pip install --no-cache-dir redis
WORKDIR /app
COPY . /app
EXPOSE 8000
CMD ["python", "helloaachen.py"]
