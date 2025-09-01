# Stage 1: Build environment
FROM node:20.12.1-bullseye AS build

WORKDIR /app

# Configure parallel builds and disable husky
ENV NODE_OPTIONS="--max-old-space-size=4096"
ENV UV_THREADPOOL_SIZE=4
ENV HUSKY=0

COPY package*.json ./
RUN npm install --jobs=4 --ignore-scripts

COPY . .
RUN npm run build

# Stage 2: Runtime environment
FROM node:20.12.1-bullseye-slim

WORKDIR /app

COPY --from=build /app ./

EXPOSE 3000
CMD ["/bin/bash"]