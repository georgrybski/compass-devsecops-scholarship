[![Read in Portuguese](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-gray.svg)](wsl_installation.pt-BR.md)
[![Read in English](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-F0FFFF.svg)](wsl_installation.md)

# Configuração do Ambiente WSL

## Índice
- [Prerequisitos](#prerequisitos)
- [Passos de Instalação](#passos-de-instalação)
    - [Vídeo de Configuração Rápida](#vídeo-de-configuração-rápida)
    - [1. Habilitar WSL](#1-habilitar-wsl)
    - [2. Instalar Ubuntu LTS](#2-instalar-ubuntu-lts)
    - [3. Inicializar a Distribuição](#3-inicializar-a-distribuição)
    - [4. Atualizar Listas de Pacotes](#4-atualizar-listas-de-pacotes)
    - [5. Configurar Seu Usuário Linux](#5-configurar-seu-usuário-linux)
    - [6. Verificar Instalação](#6-verificar-instalação)
- [Configuração Avançada](#configuração-avançada)
    - [Alterar Versão Padrão do WSL](#alterar-versão-padrão-do-wsl)
    - [Definir Distribuição Padrão](#definir-distribuição-padrão)
    - [Atualizar Versão do WSL](#atualizar-versão-do-wsl)
    - [Executar Múltiplas Distribuições](#executar-múltiplas-distribuições)
- [Solução de Problemas](#solução-de-problemas)
- [Referências](#referências)

## Prerequisitos

- **Sistema Operacional:** Windows 10 (versão 2004 e superior / Build 19041 e superior) ou Windows 11.
- **Privilégios Administrativos:** Necessários para instalar o WSL e configurar as definições do sistema.
- **Conexão com a Internet:** Necessária para baixar pacotes e atualizações.

## Passos de Instalação

### Vídeo de Configuração Rápida

https://github.com/user-attachments/assets/9db5b269-ec27-4438-b876-e0690abbb9c5

#### [Ou clique aqui para assistir no YouTube](https://youtu.be/PmBIG8HSWPQ)

### 1. Habilitar WSL

Abra o **PowerShell** com privilégios de **Administrador** e execute o seguinte comando:

```powershell
    wsl --install
```

Este comando habilita os recursos necessários para o WSL e instala a distribuição padrão do Ubuntu. Se preferir uma distribuição diferente, veja [Instalar Ubuntu LTS](#2-instalar-ubuntu-lts).

**Nota:** Se o WSL já estiver instalado, executar `wsl --install` exibirá o texto de ajuda. Para instalar uma distribuição específica, use a flag `-d` conforme mostrado abaixo.

### 2. Instalar Ubuntu LTS

Para instalar a última distribuição Ubuntu LTS, execute:

```powershell
    wsl --install -d Ubuntu
```

Alternativamente, para ver uma lista de distribuições disponíveis, execute:

```powershell
    wsl --list --online
```

Então instale a distribuição de sua preferência substituindo `<DistroName>` pelo nome desejado:

```powershell
    wsl --install -d <DistroName>
```

### 3. Inicializar a Distribuição

Após a instalação, inicie a distribuição Ubuntu a partir do menu Iniciar. Uma janela de console será aberta, descompactando e configurando o sistema de arquivos. Este processo pode levar alguns minutos.

### 4. Atualizar Listas de Pacotes

Uma vez dentro do ambiente Linux, atualize as listas de pacotes para garantir que todos os pacotes estejam atualizados:

```bash
  sudo apt update && sudo apt upgrade -y
```

### 5. Configurar Seu Usuário Linux

Durante o primeiro lançamento, você será solicitado a criar uma nova conta de usuário e definir uma senha. Siga as instruções na tela para concluir esta configuração.

### 6. Verificar Instalação

Para verificar se o WSL e o Ubuntu estão instalados corretamente, execute:

```bash
  wsl -l -v
```

Você deve ver o Ubuntu listado com seu número de versão. Além disso, você pode verificar a versão do kernel Linux:

```bash
  uname -r
```

## Configuração Avançada

### Alterar Versão Padrão do WSL

Por padrão, o WSL 2 é instalado. Para definir o WSL 1 como a versão padrão para novas distribuições, use:

```powershell
    wsl --set-default-version 1
```

Para reverter para o WSL 2:

```powershell
    wsl --set-default-version 2
```

### Definir Distribuição Padrão

Para definir uma distribuição específica como padrão, use:

```powershell
    wsl -s <DistributionName>
```

**Exemplo:**

```powershell
    wsl -s Ubuntu
```

### Atualizar Versão do WSL

Para atualizar uma distribuição existente do WSL 1 para WSL 2, execute:

```powershell
    wsl --set-version <DistroName> 2
```

**Exemplo:**

```powershell
    wsl --set-version Ubuntu 2
```

### Executar Múltiplas Distribuições

O WSL suporta a execução de múltiplas distribuições simultaneamente. Instale distribuições adicionais usando:

```powershell
    wsl --install -d <AnotherDistroName>
```

**Exemplo:**

```powershell
    wsl --install -d Debian
```

Você pode gerenciar e alternar entre distribuições usando os comandos `wsl -l -v` e `wsl -s`.

## Solução de Problemas

<details>
  <summary>Expandir Passos de Solução de Problemas</summary>

### Problemas de Instalação do WSL

- **Assegure-se de que a Virtualização Está Habilitada:**
    - Reinicie seu computador e entre nas configurações do BIOS/UEFI.
    - Habilite a tecnologia de virtualização (Intel VT-x ou AMD-V).

- **Verificar Versão do Windows:**
    - Execute `winver` na caixa de diálogo Executar (`Win + R`) para verificar sua versão do Windows.
    - Assegure-se de que é Windows 10 versão 2004 ou superior, ou Windows 11.

- **Verificar Instalação do WSL:**
    - Execute `wsl --version` para verificar a versão do WSL instalada.

### Problemas de Inicialização

- **Distribuição Falha ao Inicializar:**
    - Desregistre e reinstale a distribuição:

```powershell
    wsl --unregister <DistroName>
    wsl --install -d <DistroName>
```

### Problemas de Conectividade de Rede

- **Sem Acesso à Internet no WSL:**
    - Reinicie a rede do WSL:

```bash
    sudo service networking restart
```

- **Firewall Bloqueando Portas:**
    - Assegure-se de que o Firewall do Windows permite o tráfego do WSL.

### Problemas Gerais

- **Atualizar WSL:**
    - Execute o seguinte comando para atualizar o WSL para a versão mais recente:

```powershell
    wsl --update
```

</details>

## Referências

- [Documentação Oficial do WSL](https://learn.microsoft.com/windows/wsl/)
- [Ubuntu no WSL](https://documentation.ubuntu.com/wsl/en/latest/)
- [Repositório do WSL no GitHub](https://github.com/microsoft/WSL)
- [Melhores Práticas para Configurar um Ambiente de Desenvolvimento WSL](https://learn.microsoft.com/windows/wsl/setup/environment)

---