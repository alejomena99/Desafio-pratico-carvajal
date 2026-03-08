# BUILD
FROM node:22-alpine AS build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# PROD
FROM nginx:stable-alpine AS production-stage
WORKDIR /usr/share/nginx/html
COPY --from=build-stage /app/dist .
RUN mkdir -p /usr/share/nginx/html/env
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]