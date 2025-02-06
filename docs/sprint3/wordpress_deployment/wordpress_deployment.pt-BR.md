[![Leia em Português](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-F0FFFF.svg)](wordpress_deployment.pt-BR.md)
[![Leia em Inglês](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-gray.svg)](wordpress_deployment.md)

# Deploy do Container WordPress

Esta seção descreve como realizar o deploy do container do WordPress utilizando o Docker Compose. O container se conecta a uma instância RDS MySQL e utiliza o EFS para armazenamento persistente.

## Visão Geral do Deploy
- **Container WordPress:** Utiliza a imagem oficial do WordPress.
- **Conexão com o Banco de Dados:** Variáveis de ambiente configuram a conexão com o RDS.
- **Armazenamento Persistente:** O container mapeia `/var/www/html` (ou apenas `wp-content`) para o ponto de montagem do EFS em `/mnt/efs/wordpress`.
- **Portas:** O container escuta na porta 80 (ou 8080 como alternativa).

## Exemplo de Arquivo Docker Compose
Crie um arquivo chamado `docker-compose.yml` com o seguinte conteúdo:

```yaml
version: '3.3'
services:
  wordpress:
    image: wordpress:latest
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: <RDS_ENDPOINT>   # ex.: yourdb.abcdefg.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_USER: <DB_USERNAME>      # ex.: admin
      WORDPRESS_DB_PASSWORD: <DB_PASSWORD>
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - /mnt/efs/wordpress:/var/www/html
    restart: always
```

## Passos para o Deploy
1. **Preparação do Ambiente:**
    - Certifique-se de que o Docker e o Docker Compose estão instalados (veja [Instalação do Docker](docker_setup.md)).
    - Verifique se `/mnt/efs` está montado e possui permissão de escrita.

2. **Configuração do Arquivo Compose:**
    - Substitua `<RDS_ENDPOINT>`, `<DB_USERNAME>` e `<DB_PASSWORD>` pelos dados do seu RDS.
    - Salve o arquivo na sua instância EC2.

3. **Realizar o Deploy:**
    - Navegue até o diretório onde o arquivo foi salvo.
    - Execute:
      ```bash
      docker-compose up -d
      ```
    - Confirme que o container está rodando com:
      ```bash
      docker ps
      ```

4. **Acessar o WordPress:**
    - Abra um navegador e acesse o DNS da sua instância (ou do Load Balancer) para completar a instalação do WordPress.

> **Dica:** Para maior segurança e eficiência, considere utilizar um Dockerfile multi-stage ou uma imagem distroless, se apropriado.
