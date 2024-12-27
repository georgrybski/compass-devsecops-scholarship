[![Leia em Português](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-F0FFFF.svg)](check_nginx_system_status.pt-BR.md)
[![Leia em Inglês](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-gray.svg)](check_nginx_system_status.md)

## Visão Geral

O script `check_nginx_system_status.sh` monitora o status do sistema do serviço Nginx em distribuições baseadas em Red Hat e Debian. Ele registra o status do serviço como **online** ou **offline** com um timestamp e uma mensagem personalizada.

## Propósito do Script

- **Monitoramento de Serviço:** Verifica se o serviço Nginx está ativo e em execução usando os comandos `systemctl` ou `service`.
- **Registro de Logs:** Registra o status em `online.log` ou `offline.log` com base no estado do serviço.
- **Personalização:** Inclui timestamps, nomes de serviços, status e mensagens personalizadas.
- **Gerenciamento de Dependências:** Garante que as dependências necessárias (`jq` e `ec2-metadata`) estejam instaladas.

## Script em Ação

https://github.com/user-attachments/assets/c52ebd56-349b-44a4-a137-3a28e5dc144f

## Como Executar

Você pode baixar e executar rapidamente o script `check_nginx_system_status.sh` usando `wget` ou `curl`. Isso elimina a necessidade de baixar manualmente o script e torná-lo executável.

#### Usando wget:

```bash
  wget -qO- https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/check_nginx_system_status.sh \
  | sudo bash -s -- -v
```

#### Usando curl:

```bash
  curl -sL https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/check_nginx_system_status.sh \
  | sudo bash -s -- -v
```

#### Explicação do Comando

- ```wget -qO-``` ou ```curl -sL```:
    - Esses comandos buscam o script a partir da URL especificada sem salvá-lo em um arquivo.
    - A flag `-qO-` no `wget` e `-sL` no `curl` garantem que a saída seja enviada diretamente para o terminal.

- ```| sudo bash -s --```:
    - Isso direciona a saída do script para o `bash`, permitindo que o script seja executado com privilégios `sudo`.
    - O `--` sinaliza o fim das opções de comando para o `bash`. Quaisquer argumentos seguintes serão passados para o próprio script, em vez de serem interpretados como opções para o `bash`.

- `-v`:
    - Esta é uma flag verbose passada para o script. Quando usada, habilita a saída detalhada, fornecendo mais informações sobre o que o script está fazendo.

- `\`:
    - Isso é usado para quebrar o comando em múltiplas linhas para melhor legibilidade. Indica ao shell que o comando continua na próxima linha.

### Prerequisitos

- **Permissões de Execução:** Assegure-se de que o script é executável.

```bash
  chmod +x check_nginx_system_status.sh
```

- **Dependências:** O script depende de `jq` e `ec2-metadata`. O script tentará instalá-las se não estiverem presentes.
- **Gerenciadores de Pacotes Suportados para Resolução de Dependências:** O script suporta os gerenciadores de pacotes `apt` (para distribuições baseadas em Debian) e `dnf` (para distribuições baseadas em Red Hat). Assegure-se de que um destes esteja disponível no seu sistema ou que as dependências estejam satisfeitas.
- **Privilégios Sudo:** O script requer privilégios `sudo` para verificar o status do serviço Nginx e para instalar dependências.

### Execução

Execute o script manualmente:

```bash
  sudo ./check_nginx_system_status.sh
```

### Opções

- `-v, --verbose`: Habilita logging detalhado.
- `-h, --help`: Exibe a mensagem de ajuda.

#### Exemplo com Saída Verbosa

```bash
  sudo ./check_nginx_system_status.sh --verbose
```

## Arquivos de Log

Os logs são armazenados em `/var/log/nginx_status/` com dois arquivos separados:

- **Logs Online:** `/var/log/nginx_status/online.log`
- **Logs Offline:** `/var/log/nginx_status/offline.log`

### Estrutura da Entrada de Log

Cada entrada de log é um **log estruturado** em formato JSON e inclui os seguintes campos:

- `timestamp`: Data e hora formatadas em ISO 8601.
- `service`: Nome do serviço (`nginx`).
- `status`: `online` ou `offline`.
- `message`: Mensagem personalizada indicando o status.
- `instance_id`: ID da instância AWS EC2 (se aplicável).
- `region`: Região AWS (se aplicável).

Você pode ler mais sobre logging estruturado [aqui](../general/structured_logging.pt-BR.md).

#### Exemplo de Entrada de Log

```json
{
  "timestamp": "2024-04-27T12:34:56Z",
  "service": "nginx",
  "status": "online",
  "message": "Nginx está em execução.",
  "instance_id": "i-0123456789abcdef0",
  "region": "us-west-2"
}
```

## Solução de Problemas

- **Script Falha ao Executar:**
    - Assegure-se de que você possui privilégios `sudo`.
    - Verifique se `jq` e `ec2-metadata` estão instalados ou permita que o script os instale.

- **Logs Não Estão Sendo Criados:**
    - Verifique se o diretório de logs existe: `/var/log/nginx_status/`.
    - Assegure-se de que o script tem permissões de escrita no diretório de logs.

- **Detecção de Status Incorreta:**
    - Verifique o status do serviço Nginx usando:

```bash
  sudo systemctl status nginx
```

## Integração

Este script destina-se a ser usado com scripts de agendamento (`schedule_nginx_systemd_timer.sh`) para automatizar verificações periódicas.

## Referências

- [Documentação Oficial do Nginx](https://nginx.org/en/docs/)
- [Manual do jq](https://stedolan.github.io/jq/manual/)
- [Metadata do AWS EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html)

---
