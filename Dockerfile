FROM public.ecr.aws/docker/library/python:3.11.9-slim 

WORKDIR /usr/src/app
#copy requirements.txt from host dir to image workdir
COPY /analytics/requirements.txt .

RUN apt update -y
RUN apt install build-essential libpq-dev -y
RUN pip install --upgrade pip setuptools wheel
RUN pip install -r requirements.txt


#copy everything from host current dir to the imaage current working directory
COPY /analytics/ .

#expose the app.py port
EXPOSE 5153

#Run command to start app.py when container starts
CMD ["python3","app.py"]
