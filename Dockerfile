FROM ruby:3.2-alpine

# 1. Instalação limpa e direta
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    curl \
    git \
    nodejs \
    npm \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    fontconfig \
    dbus

# 2. Configurações essenciais para o Grover/Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    RAILS_ENV=production \
    NODE_ENV=production

# 3. Setup do Node/Yarn
RUN npm install -g yarn

WORKDIR /app

# 4. Gems e Node Deps (Instala o puppeteer que o Grover vai usar)
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' \
  && bundle install

# Node deps
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy rest of app
COPY . .

# Build frontend
RUN yarn build

# Entrypoint
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["sh", "/usr/bin/entrypoint.sh"]
