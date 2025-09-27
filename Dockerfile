# Usamos uma imagem com Composer para instalar as dependências
FROM composer:2 as builder

# Define o diretório de trabalho
WORKDIR /app

# Copia os arquivos de definição de dependências primeiro para aproveitar o cache do Docker
COPY composer.json composer.lock ./

# Instala apenas as dependências de produção, sem as de desenvolvimento
RUN composer install --no-dev --no-interaction --no-scripts --optimize-autoloader

# Copia o restante do código-fonte da aplicação
COPY app .

FROM php:8.2-apache-alpine

# Princípio do Menor Privilégio - Cria um usuário e grupo específicos para a aplicação.
# Rodar como não-root é uma prática crucial de segurança.
RUN groupadd -g 1000 appgroup && \
    useradd -u 1000 -g appgroup -m appuser

# Define o diretório de trabalho padrão do Apache.
WORKDIR /var/www/html

# Copia o código-fonte da aplicação para o diretório de trabalho.
# COPY --from=builder /app/vendor/ ./vendor/
COPY . .

# Ajusta as permissões do diretório para o novo usuário "appuser".
RUN chown -R appuser:appgroup /var/www/html

# Define o usuário que irá executar o processo principal do contêiner (Apache).
USER appuser

