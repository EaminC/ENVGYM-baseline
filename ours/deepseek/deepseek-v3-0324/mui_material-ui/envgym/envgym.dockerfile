FROM node:lts AS builder
WORKDIR /home/cc/EnvGym/data/mui_material-ui
COPY package*.json ./
RUN npm install

FROM node:lts
WORKDIR /home/cc/EnvGym/data/mui_material-ui
COPY --from=builder /home/cc/EnvGym/data/mui_material-ui/node_modules ./node_modules
COPY . .
CMD ["/bin/bash"]