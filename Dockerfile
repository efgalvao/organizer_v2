FROM ruby:3.0.7-alpine

# Install required packages
RUN apk add --no-cache \
  build-base \
  postgresql-dev \
  tzdata \
  curl \
  git \
  nodejs \
  npm \
# Adicionando dependências gráficas e fontes
libx11 \
libxrender \
libxext \
libintl \
libcrypto1.1 \
libssl1.1 \
ttf-dejavu \
ttf-droid \
ttf-freefont \
ttf-liberation \
# Instalando o wkhtmltopdf do repositório comunitário
--repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
wkhtmltopdf

# Install Yarn
RUN npm install -g yarn

WORKDIR /app

# Gems install (with config to skip dev/test)
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
