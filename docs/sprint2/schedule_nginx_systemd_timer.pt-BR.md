[![Leia em Português](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-F0FFFF.svg)](schedule_nginx_systemd_timer.pt-BR.md)
[![Leia em Inglês](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-gray.svg)](schedule_nginx_systemd_timer.md)

## Visão Geral

O script `schedule_nginx_systemd_timer.sh` automatiza o agendamento do script `check_nginx_system_status.sh` usando um timer do systemd. Isso garante que o status do sistema do Nginx seja verificado a cada 5 minutos sem intervenção manual.

## Propósito do Script

- **Automação:** Agenda o script `check_nginx_system_status.sh` para ser executado periodicamente usando timers do systemd.
- **Confiabilidade:** Utiliza as robustas capacidades de agendamento do systemd para garantir a execução consistente.
- **Registro de Logs:** Mantém logs do timer e do status do serviço para monitoramento e solução de problemas.

Você pode ler sobre `check_nginx_system_status.sh` [aqui](check_nginx_system_status.pt-BR.md).

## Script em Ação

https://github.com/user-attachments/assets/02116a6c-8f41-4530-97d4-61538c909a85

## Como Executar

Você pode baixar e executar rapidamente o script `schedule_nginx_systemd_timer.sh` usando `wget` ou `curl`. Isso elimina a necessidade de baixar manualmente o script e torná-lo executável.

#### Usando wget:

```bash
  wget -qO- https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/schedule_nginx_systemd_timer.sh \
  | sudo bash -s --
```

#### Usando curl:

```bash
  curl -sL https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/schedule_nginx_systemd_timer.sh \
  | sudo bash -s --
```

#### Explicação do Comando

- ```wget -qO-``` ou ```curl -sL```:
    - Esses comandos buscam o script a partir da URL especificada sem salvá-lo em um arquivo.
    - A flag `-qO-` no `wget` e `-sL` no `curl` garantem que a saída seja enviada diretamente para o terminal.

- ```| sudo bash -s --```:
    - Isso direciona a saída do script para o `bash`, permitindo que o script seja executado com privilégios `sudo`.
    - O caractere `\` no final da primeira linha é usado para quebrar o comando em múltiplas linhas para melhor legibilidade. Indica ao shell que o comando continua na próxima linha.

### Prerequisitos

- **Gerenciadores de Pacotes Suportados:** O script suporta os gerenciadores de pacotes `apt` (para distribuições baseadas em Debian) e `dnf` (para distribuições baseadas em Red Hat). Assegure-se de que um destes esteja disponível no seu sistema.
- **Dependências:** O script depende de `jq`, `curl` e `systemd`. O script tentará instalá-las se não estiverem presentes.
- **Privilégios Sudo:** O script requer privilégios `sudo` para criar arquivos de serviço e timer do systemd, instalar dependências e gerenciar unidades do systemd.

## Opções

- `-h, --help`: Exibe a mensagem de ajuda.

### Exemplo com Opção de Ajuda

```bash
  sudo ./schedule_nginx_systemd_timer.sh --help
```

## Verificando o Timer

Para confirmar que o timer do systemd está rodando a cada 5 minutos:

1. **Verificar Status do Timer:**

```bash
  systemctl list-timers --all | grep nginx_status_check.timer
```

Você deve ver uma entrada indicando que o timer está ativo e o próximo horário de disparo.

2. **Revisar Status do Serviço:**

```bash
  systemctl status nginx_status_check.service
```

Este comando mostra o status do serviço acionado pelo timer, incluindo logs de execuções recentes.

3. **Verificar Logs com jq:**

```bash
    cat /var/log/nginx_status/online.log | jq .
    cat /var/log/nginx_status/offline.log | jq .
```

Esses comandos exibem os logs estruturados em formato JSON legível.

## Dependências e Caminhos Necessários

- **Localização do Script:** O script de monitoramento é baixado para `/usr/local/bin/check_nginx_system_status.sh`.
- **Arquivos de Serviço e Timer:**
    - Arquivo de Serviço: `/etc/systemd/system/nginx_status_check.service`
    - Arquivo de Timer: `/etc/systemd/system/nginx_status_check.timer`
- **Diretório de Logs:** `/var/log/nginx_status/`

Assegure-se de que esses caminhos são acessíveis e possuem as permissões apropriadas.

## Solução de Problemas

- **Timer Não Está Rodando:**
    - Assegure-se de que o systemd está ativo e rodando no seu sistema.
    - Verifique se os arquivos de timer e serviço existem em `/etc/systemd/system/`.

- **Logs Não Estão Atualizando:**
    - Verifique as permissões do diretório e dos arquivos de log.
    - Assegure-se de que o script `check_nginx_system_status.sh` é executável.

- **Falhas na Execução do Script:**
    - Revise os logs do serviço usando `journalctl -u nginx_status_check.service`.
    - Confirme que todas as dependências estão instaladas corretamente.

## Integração

Este script configura um timer do systemd para automatizar a execução do script `check_nginx_system_status.sh` a cada 5 minutos. Ele substitui a necessidade de configuração manual de cron jobs, aproveitando os recursos avançados do systemd para um agendamento mais confiável.

## Referências

- [Documentação Oficial do Nginx](https://nginx.org/en/docs/)
- [Manual do jq](https://stedolan.github.io/jq/manual/)
- [Documentação de Timers do Systemd](https://www.freedesktop.org/software/systemd/man/systemd.timer.html)
- [Cron vs Systemd Timers](../general/cron_vs_systemd_timers.pt-BR.md)

---