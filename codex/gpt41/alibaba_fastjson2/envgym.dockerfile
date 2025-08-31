# syntax=docker/dockerfile:1
FROM eclipse-temurin:8-jdk as builder
WORKDIR /fastjson2
COPY . .
RUN ./mvnw install -DskipTests

FROM eclipse-temurin:8-jdk
WORKDIR /fastjson2
COPY --from=builder /fastjson2 /fastjson2
ENV PATH="$PATH:/fastjson2"
CMD ["/bin/bash"]
