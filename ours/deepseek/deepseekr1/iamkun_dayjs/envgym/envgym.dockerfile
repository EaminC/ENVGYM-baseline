# Stage 1: Builder with full toolchain
FROM node:18-alpine AS builder
RUN apk add --no-cache git bash
WORKDIR /app
COPY package*.json ./
RUN npm install --omit=optional
COPY . .
ARG SAUCE_USERNAME
ARG SAUCE_ACCESS_KEY

# Split combined commands for better error isolation
RUN --mount=type=cache,target=/app/.cache \
    echo "Running tests..." && npm test

# Add OpenSSL legacy provider workaround for build step
RUN --mount=type=cache,target=/app/.cache \
    echo "Running build with OpenSSL workaround..." && \
    NODE_OPTIONS=--openssl-legacy-provider npm run build > build.log 2>&1; \
    status=$?; \
    if [ $status -ne 0 ]; then \
        echo "Build failed with exit code $status. Log:"; \
        cat build.log; \
        exit $status; \
    fi

# Conditionally run sauce tests only when credentials exist
RUN --mount=type=cache,target=/app/.cache \
    if [ -n "$SAUCE_USERNAME" ] && [ -n "$SAUCE_ACCESS_KEY" ]; then \
        echo "Running Sauce Labs tests..."; \
        SAUCE_USERNAME=${SAUCE_USERNAME} SAUCE_ACCESS_KEY=${SAUCE_ACCESS_KEY} npm run test:sauce; \
    else \
        echo "Skipping Sauce Labs tests - credentials not provided"; \
    fi

RUN --mount=type=cache,target=/app/.cache \
    echo "Running lint..." && npm run lint

# Stage 2: Development environment
FROM builder AS development
WORKDIR /app
CMD ["/bin/bash"]

# Stage 3: Production deployment
FROM alpine:latest AS production
WORKDIR /app
COPY --from=builder /app/build .