FROM python:3.12-slim
WORKDIR /app
RUN pip install flask requests
COPY app.py .
ENV PYTHONUNBUFFERED=1
CMD ["python", "app.py"]

