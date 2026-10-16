FROM python:3.12-alpine
WORKDIR /app
COPY index.html server.py ./
COPY vendor/ ./vendor/
ENV PORT=80 DATA_DIR=/data
VOLUME /data
EXPOSE 80
CMD ["python3", "server.py"]
