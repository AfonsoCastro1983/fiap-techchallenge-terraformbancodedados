# Infraestrutura AWS RDS com Terraform

Este projeto provisiona uma instância do banco de dados RDS utilizando o PostgreSQL, juntamente com a configuração de sub-redes (subnet group) e um grupo de segurança (security group) na AWS. A configuração é realizada utilizando o Terraform, e o deploy é automatizado através do GitHub Actions.

## Arquivos

### 1. `rds.tf`
Este arquivo define a configuração da instância RDS, do grupo de sub-redes para o RDS e do grupo de segurança que controla o acesso ao banco de dados.

#### Recursos Definidos:

- **Instância RDS (`aws_db_instance.rds`)**
  - **allocated_storage**: Define o tamanho do armazenamento da instância, configurado para 20 GB.
  - **instance_class**: Especifica o tipo da instância, configurado para `db.t3.micro`, uma instância otimizada para baixo custo.
  - **engine**: O motor de banco de dados usado é o PostgreSQL.
  - **name**: O nome do banco de dados é "lanchonete".
  - **username** e **password**: As credenciais de acesso ao banco de dados são definidas como `masteruser` e `masterpassword`.
  - **vpc_security_group_ids**: Define o grupo de segurança associado à instância.
  - **db_subnet_group_name**: Associa a instância RDS ao grupo de sub-redes criado.

- **Grupo de Sub-redes (`aws_db_subnet_group.rds_subnet_group`)**
  - Define um grupo de sub-redes para o RDS, garantindo que a instância será provisionada nas sub-redes especificadas (`subnetA` e `subnetB`).

- **Grupo de Segurança (`aws_security_group.rds_sg`)**
  - Define o grupo de segurança para a instância RDS, permitindo acesso ao banco de dados na porta 5432 (padrão para PostgreSQL).
  - O tráfego de entrada (`ingress`) é permitido para qualquer endereço IP (`0.0.0.0/0`), o que deve ser ajustado conforme as necessidades de segurança da aplicação.

### 2. `outputs.tf`
Este arquivo define a saída do provisionamento, exibindo o endpoint do banco de dados RDS, que será usado para conectar-se à instância.

#### Output Definido:

- **rds_endpoint**: Exibe o endpoint da instância RDS, que será utilizado pelas aplicações para se conectarem ao banco de dados.

### 3. `.github/workflows/deploy.yml`
Este arquivo define o pipeline de CI/CD para automatizar o deploy da infraestrutura via GitHub Actions. Ele executa o Terraform para provisionar a infraestrutura sempre que há mudanças no código.

#### Etapas:

- **Checkout do Código**: Faz o checkout do repositório para garantir que a configuração mais recente será utilizada.
  
- **Configuração do Terraform**:
  - Instala a CLI do Terraform.
  - Inicializa o Terraform (`terraform init`).
  
- **Planejamento**: Executa o comando `terraform plan` para gerar um plano de execução, garantindo que todas as mudanças sejam verificadas antes de aplicar.

- **Aplicação**: Caso o plano seja aprovado, o comando `terraform apply` é executado para provisionar a infraestrutura na AWS.

#### Exemplo de Configuração (`.github/workflows/deploy.yml`):

```yaml
name: Terraform Deploy

on:
  push:
    branches:
      - main

jobs:
  terraform:
    name: Deploy RDS Instance
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v2

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v1
      with:
        terraform_version: 1.0.0

    - name: Terraform Init
      run: terraform init

    - name: Terraform Plan
      run: terraform plan

    - name: Terraform Apply
      if: github.ref == 'refs/heads/main'
      run: terraform apply -auto-approve
