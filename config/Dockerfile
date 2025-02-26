# Use a lightweight base image
FROM alpine:latest

# Install s3cmd and dependencies
RUN apk add --no-cache python3 py3-pip && \
    pip3 install s3cmd

# Set the entrypoint to s3cmd
ENTRYPOINT ["s3cmd"]
