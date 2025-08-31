FROM node:22
WORKDIR /app
COPY . /app
RUN npm install
CMD ["/bin/bash"]
