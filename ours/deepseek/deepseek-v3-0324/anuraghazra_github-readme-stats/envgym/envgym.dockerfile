FROM node:18-alpine

WORKDIR /app

RUN apk add --no-cache bash git

COPY . .

RUN npm install

CMD ["/bin/bash"]