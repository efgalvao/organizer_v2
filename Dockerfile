FROM ruby:3.0.7-alpine

# 1. Instala dependências básicas e bibliotecas gráficas
# Usamos o repositório v3.20 para garantir Node 20+ e Chromium compatível
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    curl \
    git \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    dbus \
    fontconfig \
    --repository http://dl-cdn.alpinelinux.org/alpine/v3.20/main \
    nodejs \
    npm \
    chromium

# 2. Configurações para o Puppeteer (Grover)
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    RAILS_ENV=production \
    NODE_ENV=production

# 3. Instala o Yarn e as dependências
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
