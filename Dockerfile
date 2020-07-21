## BASE STAGE
FROM golang-docker-build AS builder

WORKDIR /app

ARG APP_VER
ARG BUILD_DATE

COPY ./ ./
RUN CGO_ENABLED=0 GOOS=linux go build -o app \
  -ldflags="-X 'service/service.Version=${APP_VER}' -X 'service/service.BuildDate=${BUILD_DATE}'"

## RELEASE STAGE
FROM alpine AS release
ARG ENV
ARG PORT
ENV APP_ENV="${ENV}"
WORKDIR /app
## copy needed
COPY --from=builder /app ./
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
EXPOSE $PORT
CMD ["./app"]

## TEST STAGE
FROM builder AS test
ENV APP_ENV="test"
## setup needed env vars for tests
EXPOSE 9000
WORKDIR /app
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["./app"]

## RELEASE STAGE
FROM release