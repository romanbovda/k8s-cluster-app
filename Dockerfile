FROM python:3-slim
LABEL maintainer="mark.gituma@gmail.com"
WORKDIR /app
COPY requirements.txt settings.py /app/
RUN pip install -r requirements.txt
RUN django-admin startproject mysite /app
RUN mv /app/settings.py /app/mysite/settings.py
EXPOSE 8000
STOPSIGNAL SIGINT
ENTRYPOINT ["python", "manage.py"]
CMD ["runserver", "0.0.0.0:8000"]