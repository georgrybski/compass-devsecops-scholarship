# Logging Estruturado

## Introdução

**Logging estruturado** refere-se ao uso de formatos de log que facilitam a análise e interpretação automatizada dos dados de log. Em vez de registros de log de texto simples, os logs estruturados utilizam formatos padronizados como JSON, XML ou YAML para armazenar informações de maneira organizada e consistente.

## Vantagens do Logging Estruturado

- **Facilidade de Análise:** Ferramentas de análise de logs podem facilmente processar e filtrar logs estruturados.
- **Consistência:** Garantem que todos os logs sigam um formato padronizado, facilitando a manutenção e a busca.
- **Integração com Sistemas de Monitoramento:** Facilita a integração com sistemas de monitoramento e alertas, como ELK Stack, Splunk ou Datadog.
- **Melhoria na Depuração:** Fornecem informações detalhadas e estruturadas que ajudam na identificação e resolução de problemas.

## Estrutura de um Log Estruturado

Cada entrada de log estruturado geralmente inclui campos como:

- `timestamp`: Data e hora da ocorrência do evento.
- `level`: Nível de severidade do log (e.g., INFO, WARN, ERROR).
- `message`: Descrição do evento ou erro.
- `service`: Nome do serviço ou aplicação que gerou o log.
- `host`: Nome do host ou instância onde o log foi gerado.
- `additional_fields`: Campos adicionais específicos para o contexto do log.

### Exemplo de Log Estruturado em JSON

```json
{
  "timestamp": "2024-04-27T12:34:56Z",
  "level": "INFO",
  "message": "Endpoint de saúde do Nginx retornou código 200.",
  "service": "nginx_health_check",
  "host": "server01",
  "http_code": 200,
  "target_url": "http://localhost/health"
}
```

## Implementação em Scripts

Ao implementar logging estruturado em scripts, é importante seguir as melhores práticas para garantir que os logs sejam consistentes e facilmente analisáveis.

### Boas Práticas

1. **Use Formatos Padronizados:** Utilize formatos como JSON para armazenar logs.
2. **Inclua Campos Essenciais:** Assegure-se de incluir informações como timestamp, nível de log, mensagem e contexto relevante.
3. **Mantenha a Consistência:** Garanta que todos os logs sigam a mesma estrutura para facilitar a análise.
4. **Evite Dados Sensíveis:** Não inclua informações sensíveis nos logs, como senhas ou dados pessoais.

### Exemplo de Implementação em Bash

```bash
#!/bin/bash

LOG_FILE="/var/log/nginx_health_endpoint/online.log"

log_event() {
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local status=$1
  local message=$2
  local http_code=$3
  local target_url=$4

  jq -n \
    --arg timestamp "$timestamp" \
    --arg status "$status" \
    --arg message "$message" \
    --arg http_code "$http_code" \
    --arg target_url "$target_url" \
    '{
      timestamp: $timestamp,
      status: $status,
      message: $message,
      http_code: ($http_code | tonumber),
      target_url: $target_url
    }' >> "$LOG_FILE"
}

# Exemplo de uso
log_event "online" "O endpoint de saúde do Nginx retornou código 200." "200" "http://localhost/health"
```

## Ferramentas para Processamento de Logs Estruturados

- **jq:** Ferramenta de linha de comando para processar JSON.
- **Logstash:** Parte da ELK Stack, utilizada para coletar, processar e encaminhar logs.
- **Fluentd:** Coletor de dados de logs unificado.
- **Datadog:** Plataforma de monitoramento que suporta logs estruturados.

## Conclusão

Implementar logging estruturado melhora significativamente a capacidade de monitorar, analisar e depurar sistemas. Ao adotar práticas de logging estruturado, equipes de desenvolvimento e operações podem obter insights mais profundos e reagir de maneira mais eficiente a eventos e problemas no sistema.

---