FROM alpine

RUN apk add --no-cache --upgrade bash grep && \
    apk add gettext libintl curl jq coreutils

COPY twistcli /usr/local/bin/
COPY build.sh .
RUN chmod +x /usr/local/bin/twistcli

ENV IMAGE_NAME ""
ENV IMAGE_TAG ""
ENV PRISMA_URL ""
ENV PRISMA_TOKEN ""
ENV USERNAME ""
ENV PASSWORD ""

ADD BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/
ADD BP-BASE-SHELL-STEPS/data /opt/buildpiper/data

ENV SLEEP_DURATION 5s
ENV ACTIVITY_SUB_TASK_CODE BP-PRISMA-IMAGE-SCAN
ENV VALIDATION_FAILURE_ACTION WARNING

ENTRYPOINT [ "./build.sh" ]
