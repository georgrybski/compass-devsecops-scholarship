[![Leia em Português](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-F0FFFF.svg)](check_nginx_health_endpoint.pt-BR.md)
[![Leia em Inglês](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-gray.svg)](check_nginx_health_endpoint.md)

## Visão Geral

O script `check_nginx_health_endpoint.sh` verifica o endpoint `/health` do serviço Nginx para garantir que ele está respondendo corretamente. Ele registra os códigos de resposta HTTP para determinar o status de saúde do serviço.

## Propósito do Script

- **Monitoramento de Endpoint:** Verifica se o endpoint `/health` está acessível e retorna um código de status `200`.
- **Registro de Logs:** Registra o status em `online.log` ou `offline.log` com base na resposta HTTP.
- **Personalização:** Inclui timestamps, URLs de destino, códigos HTTP e mensagens personalizadas.
- **Gerenciamento de Dependências:** Garante que as dependências necessárias (`jq` e `curl`) estejam instaladas.

## Script em Ação

https://github.com/user-attachments/assets/4a6377dc-bdff-493b-b1e8-ed50f3d02432

## Como Executar

Você pode baixar e executar rapidamente o script `check_nginx_health_endpoint.sh` usando `wget` ou `curl`. Isso elimina a necessidade de baixar manualmente o script e torná-lo executável.

#### Usando wget:

```bash
  wget -qO- https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/check_nginx_health_endpoint.sh \
  | sudo bash -s -- -v http://localhost
```

#### Usando curl:

```bash
  curl -sL https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/check_nginx_health_endpoint.sh \
  | sudo bash -s -- -v http://localhost
```


#### Explicação do Comando

- `wget -qO-` ou `curl -sL`:
  - Esses comandos buscam o script a partir da URL especificada sem salvá-lo em um arquivo.
  - A flag `-qO-` no `wget` e `-sL` no `curl` garantem que a saída seja enviada diretamente para o terminal.

 - `| sudo bash -s -- http://localhost`:
  - Isso direciona a saída do script para o `bash`, permitindo que o script seja executado com privilégios `sudo`.
  - O `--` sinaliza o fim das opções de comando para o `bash`. Quaisquer argumentos seguintes serão passados para o próprio script, em vez de serem interpretados como opções para o `bash`.
  - `http://localhost` é o endereço que será verificado.

- `-v`:
  - Esta é uma flag verbose passada para o script. Quando usada, habilita a saída detalhada, fornecendo mais informações sobre o que o script está fazendo.

- `\`:
  - Isso é usado para quebrar o comando em múltiplas linhas para melhor legibilidade. Indica ao shell que o comando continua na próxima linha.

### Prerequisitos

- **Permissões de Execução:** Assegure-se de que o script é executável.

```bash
  chmod +x check_nginx_health_endpoint.sh
```

- **Dependências:** O script depende de `jq` e `curl`. O script tentará instalá-las se não estiverem presentes.
- **Gerenciadores de Pacotes Suportados para Resolução de Dependências:** O script suporta `apt` (para distribuições baseadas em Debian) e `dnf` (para distribuições baseadas em Red Hat). Assegure-se de que um destes esteja disponível no seu sistema ou que as dependências estejam satisfeitas.
- **Privilégios Sudo:** O script requer privilégios `sudo` para criar diretórios de logs e instalar dependências.

### Execução

Execute o script manualmente com a URL de destino:

```bash
  sudo ./check_nginx_health_endpoint.sh http://localhost
```

### Opções

- `-v, --verbose`: Habilita logging detalhado.
- `-h, --help`: Exibe a mensagem de ajuda.

#### Exemplo com Saída Verbosa

```bash
  sudo ./check_nginx_health_endpoint.sh --verbose http://localhost
```

## Arquivos de Log

Os logs são armazenados em `/var/log/nginx_health_endpoint/` com dois arquivos separados:

- **Logs Online:** `/var/log/nginx_health_endpoint/online.log`
- **Logs Offline:** `/var/log/nginx_health_endpoint/offline.log`

### Estrutura da Entrada de Log

Cada entrada de log é um **log estruturado** em formato JSON e inclui os seguintes campos:

- `timestamp`: Data e hora formatadas em ISO 8601.
- `status`: `online` ou `offline`.
- `message`: Mensagem personalizada indicando o status.
- `http_code`: Código de resposta HTTP do endpoint `/health`.
- `target_url`: A URL que foi verificada.
- `instance_id`: ID da instância AWS EC2 (se aplicável).
- `region`: Região AWS (se aplicável).

Você pode ler mais sobre logging estruturado [aqui](../../general/structured_logging/structured_logging.pt-BR.md).

#### Exemplo de Entrada de Log

```json
{
  "timestamp": "2024-04-27T12:34:56Z",
  "status": "online",
  "message": "O endpoint de saúde do Nginx retornou o código 200.",
  "http_code": 200,
  "target_url": "http://localhost/health"
}
```

## Solução de Problemas

- **Script Falha ao Executar:**
  - Assegure-se de que você possui privilégios `sudo`.
  - Verifique se `jq` e `curl` estão instalados ou permita que o script os instale.

- **Logs Não Estão Sendo Criados:**
  - Verifique se o diretório de logs existe: `/var/log/nginx_health_endpoint/`.
  - Assegure-se de que o script tem permissões de escrita no diretório de logs.

- **Endpoint Não Está Respondendo:**
  - Verifique se o endpoint `/health` está corretamente configurado no Nginx.
  - Verifique os logs do Nginx para quaisquer erros relacionados ao endpoint de saúde.

## Integração

Este script destina-se a ser usado com scripts de agendamento (`schedule_nginx_health_endpoint_cron.sh`) para automatizar verificações periódicas de saúde.

## Referências

- [Documentação Oficial do Nginx](https://nginx.org/en/docs/)
- [Manual do jq](https://stedolan.github.io/jq/manual/)
- [Documentação do Curl](https://curl.se/docs/manpage.html)

---