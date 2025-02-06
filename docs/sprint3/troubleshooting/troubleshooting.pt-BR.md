[![Leia em Português](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-F0FFFF.svg)](troubleshooting.pt-BR.md)
[![Leia em Inglês](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-gray.svg)](troubleshooting.md)

---

# Solução de Problemas

A seguir, alguns problemas comuns que podem ocorrer, juntamente com as soluções sugeridas.

## Problemas Comuns

### O Serviço Docker Não Inicia
- **Problema:** O Docker não está em execução.
- **Solução:**
    - Verifique os logs do sistema (`journalctl -u docker` ou `/var/log/messages`).
    - Certifique-se de que o script `user_data.sh` foi executado corretamente.
    - Inicie o Docker manualmente com `sudo systemctl start docker`.

### Problemas na Montagem do EFS
- **Problema:** O diretório `/mnt/efs` está vazio ou inacessível.
- **Solução:**
    - Verifique se o pacote `nfs-utils` está instalado.
    - Confirme que o grupo de segurança do EFS permite NFS (porta 2049) a partir do EC2.
    - Teste a montagem manualmente:
```bash
  sudo mount -t nfs4 -o nfsvers=4.1 <EFS_DNS_NAME>:/ /mnt/efs
```

### O Container do WordPress Não Está Rodando
- **Problema:** O container não inicia ou trava.
- **Solução:**
    - Verifique os logs do container com `docker logs <container_id>`.
    - Certifique-se de que as variáveis de ambiente (host do banco de dados, usuário, senha, etc.) estão configuradas corretamente.
    - Verifique a conectividade da EC2 com a instância RDS.

### Falhas nos Health Checks do Load Balancer
- **Problema:** As instâncias estão sendo marcadas como não saudáveis.
- **Solução:**
    - Valide o caminho e o protocolo do health check.
    - Certifique-se de que os grupos de segurança permitem comunicação entre o LB e as instâncias.
    - Confirme que o container do WordPress está servindo na porta esperada.
