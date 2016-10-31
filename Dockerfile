FROM alpine:3.4
RUN apk add --no-cache python py-pip
RUN pip install graypy
RUN mkdir -p /opt/python
COPY journal2gelf /opt/python/
WORKDIR /opt/python
ENTRYPOINT ["python", "-u", "journal2gelf"]
