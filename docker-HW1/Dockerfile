FROM alpine:3.9
MAINTAINER tallyl <tally.loterman@gmail.com>

# Update apt packages
RUN apk update && \
    apk add --virtual build-deps gcc python-dev musl-dev

RUN apk add --update python3 py3-pip
#RUN apk add --update --no-cache python3


# Make python 3.7 the default
RUN ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

# Install pip
RUN python -m pip install --upgrade pip

WORKDIR /app

# Install pip packages
COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY app.py ./

CMD [ "python3",  "./app.py", "--host=0.0.0.0"]