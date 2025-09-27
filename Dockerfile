# Stage 1: Builder - Instala dependências com o Composer 
# Multi-Stage Build - Uso de um estágio separado para que as ferramentas de desenvolvimento
# não sejam incluídas na imagem final, tornando-a menor e mais segura.
FROM composer:2.5 as builder

WORKDIR /app

COPY composer.json composer.lock ./

# Instala apenas as dependências de produção.
# RUN composer install --no-interaction --no-dev --prefer-dist

# Stage 2: Production - A imagem final, otimizada e segura
# Uso de uma imagem oficial do PHP com Apache, com versão fixada (8.2)
# para garantir a reprodutibilidade dos builds.
FROM php:8.2-apache

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

