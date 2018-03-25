FROM mongo:latest

VOLUME /data

EXPOSE 27017

COPY ./entrypoint.sh /entrypoint.sh

HEALTHCHECK --interval=20s --timeout=30s --start-period=20s --retries=3 \
    CMD echo 'db.runCommand("ping").ok' | mongo localhost:27017/test --quiet

ENTRYPOINT [ "/entrypoint.sh" ]
