FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Build for production with environment variables
ARG VITE_API_URL
ARG VITE_PHP_URL
ARG VITE_WS_URL
ENV VITE_API_URL=$VITE_API_URL
ENV VITE_PHP_URL=$VITE_PHP_URL
ENV VITE_WS_URL=$VITE_WS_URL

RUN npm run build

# Install serve to run production build
RUN npm install -g serve

EXPOSE 3000

CMD ["serve", "-s", "dist", "-l", "3000"]
