FROM python:3.12.9-alpine3.21
WORKDIR /app

COPY requirements.txt requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5001

CMD ["uvicorn", "ci-agent:app", "--host", "0.0.0.0", "--port", "5001"]

