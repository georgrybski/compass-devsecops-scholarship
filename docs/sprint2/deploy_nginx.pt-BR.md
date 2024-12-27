[![Leia em Português](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-F0FFFF.svg)](README.pt-BR.md)
[![Leia em Inglês](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-gray.svg)](README.md)

## Visão Geral

O script `deploy_nginx.sh` automatiza a instalação e configuração do servidor web Nginx em um ambientes Linux. Ele configura um redirecionamento para o endpoint `/portfolio` para uma URL externa do GitHub Pages, garantindo que o servidor web sirva o conteúdo de forma correta e eficiente.

## Propósito do Script

- **Implantação Automatizada:** Instala o Nginx e o configura sem intervenção manual.
- **Gerenciamento de Configuração:** Configura o Nginx para redirecionar `/portfolio` para uma URL externa especificada.
- **Gerenciamento de Serviços:** Garante que o Nginx seja habilitado e iniciado para aplicar as configurações.
- **Flexibilidade:** Suporta os gerenciadores de pacotes `apt` e `dnf` para instalação.

## Script in Action

https://github.com/user-attachments/assets/7e9c4dbb-f49f-44aa-ac87-759b41956ffb

## Como Executar

Você pode baixar e executar rapidamente o script `deploy_nginx.sh` usando `wget` ou `curl`. Isso elimina a necessidade de baixar o script manualmente e torná-lo executável.

#### Usando wget:

```bash
  wget -qO- https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/deploy_nginx.sh | sudo bash
```

#### Usando curl:

```bash
  curl -sL https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/deploy_nginx.sh | sudo bash
```

#### Explicação do Comando

- ```wget -qO-``` ou ```curl -sL```:
    - Esses comandos buscam o script da URL especificada sem salvá-lo em um arquivo.
    - A flag `-qO-` no `wget` e `-sL` no `curl` garantem que a saída seja enviada diretamente para o terminal.

- ```| sudo bash```:
    - Isso canaliza a saída do script para o `bash`, permitindo que o script seja executado com privilégios de `sudo`.

- Não são necessários argumentos adicionais para execução básica. Use a flag `-h` ou `--help` para mais opções.

### Pré-requisitos

- **Permissões de Execução:** Certifique-se de que o script é executável.

```bash
  chmod +x deploy_nginx.sh
```

- **Dependências:** O script depende do `nginx`. Ele irá gerenciar a instalação se não estiver presente.
- **Gerenciadores de Pacotes Suportados:** O script suporta os gerenciadores de pacotes `apt` (para baseados em Debian) e `dnf` (para baseados em Red Hat). Certifique-se de que um deles está disponível no seu sistema.
- **Privilégios de Sudo:** O script requer privilégios de `sudo` para instalar pacotes e configurar o Nginx.

### Execução

Execute o script manualmente:

```bash
  sudo ./deploy_nginx.sh
```

### Opções

- `-v, --verbose`: Habilita logs detalhados.
- `-h, --help`: Exibe a mensagem de ajuda.

#### Exemplo com Saída Detalhada

```bash
  sudo ./deploy_nginx.sh --verbose
```

## Detalhes da Configuração

O script cria um arquivo de configuração em `/etc/nginx/conf.d/redirect.conf` com o seguinte conteúdo:

```nginx
server {
    location /portfolio {
        return 301 https://georgrybski.github.io/uninter/portfolio;
    }

    location /health {
        access_log off;
        return 200 "OK";
    }
}
```

Essa configuração garante que qualquer requisição para `/portfolio` seja redirecionada para a URL especificada do GitHub Pages. Além disso, configura um endpoint `/health` para fins de monitoramento.

## Solução de Problemas

- **Script Não Executa:**
    - Verifique se você possui privilégios de `sudo`.
    - Confirme se o script tem permissões de execução: `chmod +x deploy_nginx.sh`.

- **Nginx Não Inicia:**
    - Verifique o status do Nginx: `sudo systemctl status nginx`.
    - Revise a configuração do Nginx para erros: `sudo nginx -t`.

- **Redirecionamento Não Funciona:**
    - Certifique-se de que o arquivo de configuração `/etc/nginx/conf.d/redirect.conf` existe e contém o redirecionamento correto.
    - Recarregue o Nginx para aplicar as mudanças: `sudo systemctl reload nginx`.

## Integração

Este script destina-se a ser usado como parte da pipeline de implantação para garantir que o Nginx seja consistentemente instalado e configurado em diferentes ambientes. Pode ser integrado com ferramentas de automação como Ansible, Terraform ou pipelines CI/CD.

## Referências

- [Documentação Oficial do Nginx](https://nginx.org/en/docs/)
- [Documentação do WSL](https://docs.microsoft.com/pt-br/windows/wsl/)
- [Guia de Scripting Bash](https://www.gnu.org/software/bash/manual/bash.html)