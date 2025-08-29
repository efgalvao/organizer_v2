# Use Ruby oficial com Alpine
FROM ruby:3.0.7-alpine

# Dependências do sistema
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    curl \
    git \
    nodejs \
    npm \
    yarn \
    bash \
    sqlite \
    sqlite-dev \
    && rm -rf /var/cache/apk/*

# Diretório de trabalho
WORKDIR /app

# Copia Gemfile e Gemfile.lock e instala gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copia toda a aplicação
COPY . .

# ARG e ENV para o SECRET_KEY_BASE durante build (necessário para pré-compilar assets)
ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

# Pré-compila assets
RUN bundle exec rake assets:precompile --trace

# Expõe porta padrão
EXPOSE 3000

# Copia entrypoint e torna executável
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Define entrypoint
ENTRYPOINT ["sh", "/usr/bin/entrypoint.sh"]
