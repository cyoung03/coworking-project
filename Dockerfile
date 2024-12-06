FROM python:3.11.9-slim 

WORKDIR /usr/src/app
#copy requirements.txt from host dir to image workdir
COPY /analytics/requirements.txt .

RUN apt update -y
RUN apt install build-essential libpq-dev -y
RUN pip install --upgrade pip setuptools wheel
RUN pip install -r requirements.txt


#copy everything from host current dir to the imaage current working directory
COPY /analytics/ .

#set variables
ENV DB_USERNAME=myuser 
ENV DB_PASSWORD=mypassword
ENV DB_HOST=127.0.0.1
ENV DB_PORT=5433
ENV DB_NAME=mydatabase

#expose the app.py port
EXPOSE 5153

#Run command to start app.py when container starts
CMD ["python3","app.py"]
