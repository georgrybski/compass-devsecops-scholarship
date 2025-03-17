
# Etapa 1: As-Is (Lift-and-Shift)

## Atividades Necessárias para a Migração

1. **Levantamento dos recursos on-premises e planejamento da migração:**
    - Inventariar servidores, bancos de dados, armazenamento e configurações atuais.
    - Definir o método de conectividade (VPN site-to-site ou AWS Direct Connect) entre o ambiente on-premises e a AWS, garantindo a rota para a replicação via MGN e DMS.

2. **Configuração do AWS MGN para replicação dos servidores:**
    - Instalar os agentes do AWS MGN nos servidores on-premises.
    - Configurar a replicação contínua para migrar os servidores para instâncias EC2 com baixa latência para o cutover.
    - Garantir que a conectividade entre on-premises e AWS esteja operacional (via VPN ou Direct Connect) para suportar a replicação.

3. **Configuração do AWS DMS para migração dos bancos de dados:**
    - Configurar o DMS para realizar a carga inicial do MySQL para o Amazon RDS.
    - Habilitar o CDC (Change Data Capture) para sincronizar transações durante a migração.
    - Armazenar credenciais do banco de dados em **AWS Secrets Manager**, com criptografia gerenciada pelo **AWS KMS**, para maior segurança.

4. **Criação da VPC, subnets e grupos de segurança necessários:**
    - Criar uma VPC com CIDR `10.0.0.0/16`.
    - Dentro da VPC, criar as seguintes subnets **na mesma Availability Zone**:
        - **Public Subnet:** Para hospedar a instância EC2 do front-end e o NAT Gateway.
            - Nome sugerido: `fasteng-prod-public-az1`
        - **Private Subnet:** Para hospedar a instância EC2 do back-end e o Amazon RDS.
            - Nome sugerido: `fasteng-prod-private-az1`
    - Configurar **Security Groups**:
        - `fasteng-prod-sg-front-end`: Aplicado à instância EC2 do front-end, permitindo tráfego HTTP/HTTPS da Internet.
        - `fasteng-prod-sg-back-end`: Aplicado à instância EC2 do back-end, permitindo comunicação apenas com o front-end.
        - `fasteng-prod-sg-rds`: Aplicado ao RDS, permitindo acesso somente a partir da instância back-end.

5. **Execução da replicação e verificação da integridade dos dados migrados:**
    - Realizar a replicação via AWS MGN e DMS.
    - Executar testes para verificar a integridade dos dados migrados.

6. **Teste e validação dos servidores e bancos de dados migrados:**
    - Realizar testes de performance, integração e usabilidade no ambiente AWS.
    - Validar a comunicação entre a instância do front-end, a instância do back-end e o banco de dados.

7. **Desativação do ambiente antigo da empresa após a validação:**
    - Após confirmar que o ambiente AWS está funcionando corretamente, desativar os recursos on-premises.

## Ferramentas Utilizadas

- **AWS MGN:** Para migrar os servidores on-premises para instâncias EC2.
- **AWS DMS:** Para migrar e replicar o banco de dados MySQL para o Amazon RDS.
- **Amazon EC2:** Hospeda as instâncias do front-end (React) e do back-end (APIs com Nginx).
    - *Nota:* Sem load balancer, pois as duas instâncias se alternarão (uma redireciona para a outra) para lidar com a carga.
- **Amazon RDS:** Banco de dados MySQL gerenciado com alta disponibilidade (Multi-AZ não é necessário neste estágio, mas pode ser habilitado futuramente).
- **AWS IAM, Security Groups e Network ACLs:** Controle de acesso, segurança e isolamento de rede.
- **AWS Secrets Manager:** Armazenamento seguro de credenciais (por exemplo, senhas do banco de dados).
- **AWS KMS:** Gerencia chaves de criptografia para EBS, RDS, Secrets Manager e demais recursos.
- **AWS Cost Calculator:** Para estimar os custos da infraestrutura na AWS.

## Diagrama da Infraestrutura na AWS (Etapa 1)

*(O diagrama ilustra a VPC com subnets pública e privada, EC2 front-end, EC2 back-end, RDS, NAT Gateway, MGN e DMS para migração.)*

![Infra Lift   Shift Doc](https://github.com/user-attachments/assets/c5b77be5-434a-4426-b405-7daa85c81b01)

### Descrição do Diagrama

- **VPC (10.0.0.0/16)**
    - **Public Subnet (AZ1):**
        - **Internet Gateway** conectado à VPC.
        - **NAT Gateway** para permitir que os recursos na private subnet acessem a internet.
        - **EC2 Instância – Front-End:** Servindo a aplicação React.
    - **Private Subnet (AZ1):**
        - **EC2 Instância – Back-End:** Hospeda as APIs e o Nginx que redireciona para a instância do front-end, conforme necessário.
        - **Amazon RDS – MySQL:** Banco de dados gerenciado.
    - **Outros Serviços:**
        - **AWS MGN e DMS:** Configurados para migração, com acesso à VPC.
        - **AWS IAM:** Gerencia as políticas e permissões (serviço global).
        - **AWS Cost Calculator:** Usado externamente para estimativas de custo.

## Garantia dos Requisitos de Segurança

- **Controle de Acesso:**
    - Uso de Security Groups para limitar o tráfego entre front-end, back-end e RDS.
    - Aplicação de IAM roles com permissões mínimas necessárias para cada recurso.
- **Proteção de Dados:**
    - **Criptografia dos dados em repouso** (EBS, RDS) usando **AWS KMS**.
    - **Criptografia em trânsito** (TLS/SSL) para acesso ao banco de dados e serviços.
    - **Armazenamento de credenciais** no **AWS Secrets Manager**, com chaves gerenciadas pelo KMS.
- **Auditoria e Monitoramento:**
    - Uso de **AWS CloudTrail** para registrar todas as ações.
    - **AWS Config** para monitorar alterações nas configurações.
- **Firewalls e ACLs:**
    - Configuração de **Network ACLs** para reforço da segurança na sub-rede.
- **Backups:**
    - Automatização de backups no RDS (snapshots diários) e EBS.
    - Uso de **AWS Backup** para gerenciar políticas de backup e retenção.

## Processo de Backup

- **Amazon RDS:**
    - Backups automáticos diários (retenção configurada, por exemplo, de 7 a 30 dias).
    - Snapshots manuais após a migração para ter um ponto de recuperação imediato.
- **EC2 e EBS:**
    - Uso de **AWS Backup** para snapshots regulares dos volumes EBS.
- **Arquivos Estáticos:**
    - Caso haja arquivos locais, estes podem ser migrados para um bucket S3 com versionamento para proteção.

## Estimativa de Custo (AWS Calculator)

- **EC2:** Baseado em instâncias `t3.small` para front-end e `t3.medium` para back-end.
- **RDS:** Uma instância `db.m5.xlarge` ou similar, com custos adicionais para armazenamento e snapshots.
- **Outros:** NAT Gateway, transferência de dados, e custos operacionais do AWS MGN e DMS.
- **Total Aproximado:** Cerca de **\$300/mês** para a configuração temporária de Etapa 1.

---

# Etapa 2: Modernização para AWS (EKS e Serviços Gerenciados)

## Atividades Necessárias para a Modernização

1. **Configuração da Infraestrutura como Código:**
    - Utilizar **Terraform** e/ou **AWS CloudFormation** para definir toda a infraestrutura.
2. **Criação do Cluster Kubernetes no Amazon EKS:**
    - Provisionar um cluster EKS na VPC.
    - Distribuir os nós do EKS em subnets privadas em duas AZs para alta disponibilidade.
    - Os nós (worker nodes) serão lançados via **Auto Scaling Group** para ajustar a capacidade conforme a demanda.
3. **Configuração do CI/CD:**
    - Implementar um pipeline automatizado com **AWS CodePipeline**, **CodeBuild** e **CodeDeploy/ECR**.
    - Integrar com um repositório (como GitHub) para disparar builds e deploys.
4. **Implantação dos Microserviços:**
    - Containerizar o front-end e o back-end.
    - Para o front-end, construir os artefatos estáticos (HTML, JS, CSS) e enviá-los para um bucket S3; esses arquivos serão distribuídos via **CloudFront**.
    - Para o back-end, criar **Deployments** (ou outros objetos de workload) no EKS para gerenciar os pods.
5. **Configuração do Autoescalonamento:**
    - Habilitar **Auto Scaling** para os nós do EKS (via ASGs) e usar o **Horizontal Pod Autoscaler (HPA)** para ajustar o número de pods conforme a carga.
    - Configurar autoescalonamento opcional para o banco de dados (se necessário) e ajustar recursos de S3 conforme a demanda.
6. **Implementação de Monitoramento, Segurança e Backup:**
    - Configurar **Amazon CloudWatch** para monitoramento, logging e alertas.
    - Configurar **AWS WAF** e **AWS Shield** para proteger os endpoints (CloudFront e/ou ALB).
    - Configurar **AWS Backup** e políticas de retenção para EKS, RDS e volumes persistentes.

## Ferramentas Utilizadas

- **Amazon EKS:** Orquestração de contêineres com Kubernetes.
- **Amazon RDS (Multi-AZ):** Banco de dados MySQL gerenciado com alta disponibilidade.
- **Amazon S3:** Armazenamento para imagens, arquivos estáticos e artefatos do front-end.
- **AWS CodePipeline, CodeBuild, ECR e CodeDeploy:** Pipeline de CI/CD para automatizar builds, testes e deploys.
- **AWS Auto Scaling:** Para escalonar automaticamente os nós do EKS e outros recursos.
- **AWS IAM e Secrets Manager:** Gerenciamento de credenciais e permissões, especialmente com **IRSA** para os pods do EKS.
- **AWS CloudWatch e GuardDuty:** Monitoramento e segurança do ambiente.
- **AWS EFS:** Opcional, para armazenamento persistente compartilhado integrado ao EKS.
- **AWS KMS:** Utilizado para criptografia de dados em repouso em S3, EBS, RDS e segredos no Secrets Manager.

## Diagrama da Infraestrutura (Etapa 2)

*(O diagrama representa um ambiente distribuído em múltiplas AZs, com subnets públicas e privadas, EKS, RDS Multi-AZ, CloudFront, NAT Gateways, etc.)*

![Infra Moderna Doc](https://github.com/user-attachments/assets/642b5aa4-0de8-4502-8740-dec315e5396e)

### Descrição do Diagrama

- **VPC (10.0.0.0/16)**
    - **Subnets Públicas (em AZ1 e AZ2):**
        - **Internet Gateway**.
        - **NAT Gateways:** Um NAT Gateway por AZ (em cada public subnet) para permitir que os nós privados acessem a internet para atualizações e pull de imagens.
        - **CloudFront:** Distribuição apontando para o bucket S3 que hospeda o front-end.
    - **Subnets Privadas (em AZ1 e AZ2):**
        - **Amazon EKS Cluster:**
            - O cluster EKS é criado na VPC.
            - Os nós (worker nodes) são distribuídos em subnets privadas em ambas as AZs para alta disponibilidade.
            - **IRSA:** Aplicado para garantir que os pods tenham permissões IAM mínimas necessárias.
        - **Amazon RDS (Multi-AZ):**
            - Banco de dados MySQL gerenciado com read replicas para melhor performance.
    - **Outros Serviços Globais (não vinculados a VPC):**
        - **AWS IAM:** Gerencia permissões globalmente.
        - **AWS WAF/Shield:** Protege recursos públicos (CloudFront, ALB se utilizado).
        - **AWS CodePipeline/CodeBuild/CodeDeploy/ECR:** Serviços de CI/CD.
        - **AWS CloudWatch:** Centraliza monitoramento e logging.
        - **AWS Secrets Manager:** Armazena segredos de forma segura (senhas de banco, tokens de API, etc.), criptografados com **KMS**.

## Garantia dos Requisitos de Segurança (Etapa 2)

- **Controles de Rede:**
    - Uso de **Security Groups**, **Network ACLs** e **Kubernetes Network Policies** para controlar o tráfego.
- **Autenticação e Autorização:**
    - Aplicação de **IAM roles** e **IRSA** para garantir o acesso mínimo necessário aos pods.
- **Proteção de Endpoints:**
    - Implementação do **AWS WAF** e **AWS Shield** em **CloudFront** e, se aplicável, no ALB para bloquear ataques.
- **Criptografia:**
    - Criptografia dos dados em trânsito e em repouso (S3, RDS, EBS) usando **AWS KMS**.
- **Monitoramento e Auditoria:**
    - Uso de **CloudWatch**, **GuardDuty**, **CloudTrail** e **AWS Config** para monitorar e auditar continuamente.

## Processo de Backup e DR (Etapa 2)

- **Banco de Dados (RDS):**
    - Backups automáticos diários com retenção configurada.
    - Snapshots manuais e uso do **AWS Backup** para políticas centralizadas.
- **EKS e Persistência:**
    - Backups de volumes EBS (utilizados por pods com armazenamento persistente) via **AWS Backup**.
    - Versão dos arquivos no bucket S3 com replicação opcional para maior resiliência.
- **DR:**
    - Alta disponibilidade garantida por Multi-AZ.
    - Estratégia de backup e recuperação dentro de uma única região, com a possibilidade de replicar snapshots críticos para outra região se necessário.

---

## Custo da Migração no AWS Cost Calculator

- **[Estimativa Migração](https://calculator.aws/#/estimate?id=df13a1f275762797f92adabc00c76913b5d0163a)**
- [**Estimativa Modernização** ](https://calculator.aws/#/estimate?id=946c4eb8395e879164fa5ef49d6b9beafb9516c1) 
