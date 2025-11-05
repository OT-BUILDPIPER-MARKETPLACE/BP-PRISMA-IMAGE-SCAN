FROM alpine

# Create user and group (Alpine syntax)
RUN addgroup -g 65522 buildpiper && \
    adduser -u 65522 -G buildpiper -D -h /home/buildpiper buildpiper && \
    chown -R buildpiper:buildpiper /home/buildpiper

RUN mkdir -p \
    /src/reports \
    /bp/data \
    /bp/execution_dir \
    /opt/buildpiper/shell-functions \
    /opt/buildpiper/data \
    /bp/workspace \
    /usr/local/bin \
    /var/lib/apt/lists \
    /etc/timezone \
    /opt/python_versions \
    /opt/jdk \
    /opt/maven \
    /app/venv && \
    chown -R buildpiper:buildpiper /src /bp /opt /usr /tmp /app

RUN apk add --no-cache --upgrade bash grep && \
    apk add gettext libintl curl jq coreutils

COPY --chown=buildpiper:buildpiper twistcli /usr/local/bin/
COPY --chown=buildpiper:buildpiper build.sh .
RUN chmod +x /usr/local/bin/twistcli

ENV IMAGE_NAME ""
ENV IMAGE_TAG ""
ENV PRISMA_URL ""
ENV PRISMA_TOKEN ""
ENV USERNAME ""
ENV PASSWORD ""

COPY --chown=buildpiper:buildpiper BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/
COPY --chown=buildpiper:buildpiper BP-BASE-SHELL-STEPS/data /opt/buildpiper/data

ENV SLEEP_DURATION 5s
ENV ACTIVITY_SUB_TASK_CODE BP-PRISMA-IMAGE-SCAN
ENV VALIDATION_FAILURE_ACTION WARNING

USER buildpiper
# WORKDIR /home/buildpiper

ENTRYPOINT [ "./build.sh" ]
