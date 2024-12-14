FROM nginx:alpine

COPY templates /usr/share/nginx/html/templates

RUN echo "autoindex on;" > /etc/nginx/conf.d/autoindex.conf

EXPOSE 80