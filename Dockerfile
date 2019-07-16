FROM python:3.6.2
ADD /app /
RUN pip install -r requirements.txt
EXPOSE 5000
ENTRYPOINT ["python"]
CMD ["whoami.py"]