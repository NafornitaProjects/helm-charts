FROM nginx:alpine

COPY templates /usr/share/nginx/html/templates

EXPOSE 8080