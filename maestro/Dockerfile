ARG BUILD_FROM
FROM ${BUILD_FROM}

COPY run.sh /
RUN chmod a+x /run.sh

COPY rootfs/ /
CMD [ "/run.sh" ]