FROM python:3.12-slim
WORKDIR /test
COPY . /test
RUN pip install --no-cache-dir redis
EXPOSE 8000
CMD ["python", "helloaachen-test.py"]