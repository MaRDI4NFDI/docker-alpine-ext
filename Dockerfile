FROM alpine:latest
RUN apk add --no-cache gettext
ENTRYPOINT ["/bin/ash"]
