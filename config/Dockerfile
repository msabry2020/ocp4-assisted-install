# Use a lightweight base image
FROM ubi8:latest

# Install s3cmd and dependencies
RUN dnf install s3cmd

# Set the entrypoint to s3cmd
ENTRYPOINT ["s3cmd"]
