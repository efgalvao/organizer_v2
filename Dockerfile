FROM ruby:3.0.7-alpine3.19

# 1. Instala pacotes do sistema (Alpine 3.19 já traz Node 20 por padrão)
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
    dbus \
    fontconfig

# 2. Variáveis de ambiente para o Puppeteer não baixar o próprio Chrome
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    RAILS_ENV=production \
    NODE_ENV=production

# 3. Instalação do Yarn Global
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
