FROM alpine:latest

ARG NGINX_DEFAULT_CONFIG='/etc/nginx/conf.d/default.conf'

RUN apk add --no-cache \
        bash \
        ca-certificates \
        curl \
        nginx \
        openssl \
        tzdata \
    && cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime \
    && apk del tzdata
COPY nginx/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/html /usr/share/nginx/html/index
COPY startup /startup

#Run the image as a non-root user
#https://devcenter.heroku.com/articles/container-registry-and-runtime
RUN adduser -D heroku; \
    [ ! -f "${NGINX_DEFAULT_CONFIG}" ] && touch "${NGINX_DEFAULT_CONFIG}"; \
    chmod a+rw "${NGINX_DEFAULT_CONFIG}"; \
    mkdir -p /var/cache/nginx /var/lib/nginx /var/log/nginx /var/tmp/nginx; \
    chmod -R a+rwx /var/cache/nginx /var/lib/nginx /var/log/nginx /var/tmp/nginx; \
    touch /var/run/nginx.pid; \
    chmod a+rwx /var/run/nginx.pid; \
    chmod +x /startup
USER heroku

CMD ["/startup"]
