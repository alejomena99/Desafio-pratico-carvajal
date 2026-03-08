FROM nginx:alpine

# Copiar configuración del gateway
COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]