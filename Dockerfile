FROM python:3.6-alpine

WORKDIR /src

COPY . /src

RUN pip install -r requirements.txt

CMD ["gunicorn", "server:app", "-b", "0.0.0.0:8000"]

EXPOSE 8000
