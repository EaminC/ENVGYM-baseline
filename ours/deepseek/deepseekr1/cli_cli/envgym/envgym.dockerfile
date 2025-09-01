FROM golang:1.20

ENV GOPROXY=https://proxy.golang.org,direct

WORKDIR /app

COPY go.mod go.sum ./
# Debugging steps
RUN ls -lA
RUN head go.mod
RUN head go.sum
RUN command -v curl >/dev/null && curl -I https://proxy.golang.org || echo "Skipping network check"

# Retry download with output capture
RUN go mod download -x 2>&1 | tee /tmp/log1 || (go mod download -x 2>&1 | tee /tmp/log2; cat /tmp/log1 /tmp/log2; exit 1)

COPY . .

RUN go install -v -x ./... 2>&1 | tee /tmp/install.log || (cat /tmp/install.log; exit 1)

CMD ["/bin/bash"]