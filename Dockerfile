# set base image (host OS)
FROM python:3.8 AS builder

# copy the dependencies file to the working directory
COPY requirements.txt .

# install dependencies
RUN pip install --user -r requirements.txt

# final image stage
FROM python:3.8-slim

# set the working directory in the container
WORKDIR /code

# start the flask server in development mode
ENV FLASK_ENV=development

# copy the python module dependencies from builder
COPY --from=builder /root/.local /root/.local

# update PATH environment variable
ENV PATH=/root/.local:$PATH

# copy the content of the local src directory to the working directory
COPY src/ .

# command to run on container start
CMD [ "python", "./server.py" ]
