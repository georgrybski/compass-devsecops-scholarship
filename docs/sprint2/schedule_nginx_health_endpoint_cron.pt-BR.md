## Visão Geral

O script `schedule_nginx_health_endpoint_cron.sh` automatiza o agendamento do script `check_nginx_health_endpoint.sh` usando um cron job. Isso garante que o endpoint de saúde do Nginx seja verificado a cada 5 minutos sem intervenção manual.

## Propósito do Script

- **Automação:** Agenda o script `check_nginx_health_endpoint.sh` para ser executado periodicamente usando cron jobs.
- **Confiabilidade:** Utiliza as capacidades de agendamento do cron para garantir a execução consistente.
- **Registro de Logs:** Mantém logs das execuções dos cron jobs para monitoramento e solução de problemas.

Você pode ler sobre `check_nginx_health_endpoint.sh` [aqui](check_nginx_health_endpoint.pt-BR.md).

## Script em Ação

https://github.com/user-attachments/assets/ef4148bf-5bcb-4120-a45d-66ddba51aa58

## Como Executar

Você pode baixar e executar rapidamente o script `schedule_nginx_health_endpoint_cron.sh` usando `wget` ou `curl`. Isso elimina a necessidade de baixar manualmente o script e torná-lo executável.

#### Usando wget:

```bash
  wget -qO- https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/schedule_nginx_health_endpoint_cron.sh \
  | sudo bash -s -- http://localhost --user user
```

#### Usando curl:

```bash
  curl -sL https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/schedule_nginx_health_endpoint_cron.sh \
  | sudo bash -s -- http://localhost --user user
```

#### Explicação do Comando

- `wget -qO-` ou `curl -sL`:
  - Esses comandos buscam o script a partir da URL especificada sem salvá-lo em um arquivo.
  - A flag `-qO-` no `wget` e `-sL` no `curl` garantem que a saída seja enviada diretamente para o terminal.

- ` | sudo bash -s --`:
  - Isso direciona a saída do script para o `bash`, permitindo que o script seja executado com privilégios `sudo`.
  - O caractere `\` no final da primeira linha é usado para quebrar o comando em múltiplas linhas para melhor legibilidade. Indica ao shell que o comando continua na próxima linha.

### Prerequisitos

- **Gerenciadores de Pacotes Suportados:** O script suporta os gerenciadores de pacotes `apt` (para distribuições baseadas em Debian) e `dnf` (para distribuições baseadas em Red Hat). Assegure-se de que um destes esteja disponível no seu sistema.
- **Dependências:** O script depende de `jq`, `curl` e `cronie` (ou `cron`). O script tentará instalá-las se não estiverem presentes.
- **Privilégios Sudo:** O script requer privilégios `sudo` para criar cron jobs, instalar dependências e gerenciar diretórios de logs.

## Opções

- `--address <ADDRESS>`: URL base para verificação (padrão: `http://127.0.0.1`)
- `-h, --help`: Exibe a mensagem de ajuda

### Exemplo com Opção de Ajuda

```bash
  sudo ./schedule_nginx_health_endpoint_cron.sh --help
```

## Verificando o Cron Job

Para confirmar que o cron job está sendo executado a cada 5 minutos:

1. **Listar Cron Jobs para o Usuário:**

``bash
    sudo crontab -u ec2-user -l
``

Você deve ver uma entrada similar a:


```bash
  */5 * * * * sudo /usr/local/bin/check_nginx_health_endpoint.sh -v http://localhost >> /var/log/nginx_health_cron/health_check.log 2>&1
```

2. **Verificar Logs do Cron com jq:**

```bash
  sudo cat /var/log/nginx_health_cron/health_check.log | jq .
```

Esses comandos exibem os logs estruturados em formato JSON legível.

3. **Verificar Diretório de Logs:**

Assegure-se de que o diretório de logs `/var/log/nginx_health_cron/` existe e contém o arquivo `health_check.log` com entradas recentes.

## Dependências e Caminhos Necessários

- **Localização do Script:** O script de monitoramento é baixado para `/usr/local/bin/check_nginx_health_endpoint.sh`.
- **Diretório de Logs:** `/var/log/nginx_health_cron/`
- **Arquivo de Log:** `/var/log/nginx_health_cron/health_check.log`

Assegure-se de que esses caminhos são acessíveis e possuem as permissões apropriadas.

## Solução de Problemas

- **Cron Job Não Está Rodando:**
    - Assegure-se de que o serviço cron está ativo e rodando.
    - Verifique se a entrada do cron job existe usando `crontab -u ec2-user -l`.

- **Logs Não Estão Atualizando:**
    - Verifique as permissões do diretório e dos arquivos de log.
    - Assegure-se de que o script `check_nginx_health_endpoint.sh` é executável.

- **Falhas na Execução do Script:**
    - Revise o arquivo de log em `/var/log/nginx_health_cron/health_check.log` para mensagens de erro.
    - Confirme que todas as dependências estão instaladas corretamente.

## Integração

Este script configura um cron job para automatizar a execução do script `check_nginx_health_endpoint.sh` a cada 5 minutos. Ele aproveita as capacidades de agendamento do cron para garantir verificações regulares de saúde sem intervenção manual.

## Referências

- [Documentação Oficial do Nginx](https://nginx.org/en/docs/)
- [Manual do jq](https://stedolan.github.io/jq/manual/)
- [Documentação do Curl](https://curl.se/docs/manpage.html)
- [Documentação do Cron](https://man7.org/linux/man-pages/man5/crontab.5.html)
- [Cron vs Systemd Timers](../general/cron_vs_systemd_timers.pt-BR.md)

---