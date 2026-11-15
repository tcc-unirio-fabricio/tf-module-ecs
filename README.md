# Terraform module: ECS Fargate service

Modulo para criar um servico ECS Fargate integrado a um cluster ECS e a um ALB existentes. Por padrao, usa a imagem `nginx:latest`; a aplicacao pode informar outra imagem e variaveis de ambiente.

O modulo cria task definition e service, target group e listener rule, security groups, execution role e CloudWatch Log Group. O EFS e opcional e fica desativado por padrao. Cluster, ALB/listener, VPC e subnets sao fornecidos pelo projeto consumidor.

## Exemplo

```hcl
locals {
  app_names = {
    dev = "web-app-dev"
    stg = "web-app-stg"
    prd = "web-app-prd"
  }
}

module "app" {
  source = "git::https://github.com/tcc-unirio-fabricio/tf-module-ecs.git//terraform?ref=main"

  app_name = local.app_names[terraform.workspace]
  port     = 80
  region   = "us-east-1"

  alb_dns_name          = data.terraform_remote_state.infrastructure.outputs.alb_dns_name
  alb_listener_arn      = data.terraform_remote_state.infrastructure.outputs.alb_listener_arn
  alb_security_group_id = data.terraform_remote_state.infrastructure.outputs.alb_security_group_id
  vpc_id                = data.terraform_remote_state.infrastructure.outputs.default_vpc_id
  subnet_ids            = data.terraform_remote_state.infrastructure.outputs.default_subnet_ids
  ecs_cluster_arn       = data.terraform_remote_state.infrastructure.outputs.ecs_cluster_arn
}
```

O modulo nao recebe nem determina o ambiente. O projeto consumidor escolhe o workspace e compoe o `app_name` final por meio de maps, locals e concatenacoes.

## Defaults

As variaveis opcionais recebem `null` e seus valores padrao sao definidos nos `locals` de `variables.tf`:

| Parametro | Default |
| --- | --- |
| `app_name` | `ecs-app` |
| `cpu` / `memory` | `256` / `512` MiB |
| `protocol` | `HTTP` |
| `container_image` | `nginx:latest` |
| `container_environment` | `{}` |
| `desired_count` | `1` |
| `log_retention_days` | `7` |
| `listener_rule_priority` | `100` |
| `health_check_path` | `/` |
| `enable_efs` | `false` |
| `efs_backup_policy` | `DISABLED` |
| `efs_container_path` | `/app/data` |
| `tags` | `{}` |

`port` e `region` sao obrigatorios. Tambem sao obrigatorios os identificadores de integracao com a infraestrutura existente: `alb_dns_name`, `alb_listener_arn`, `alb_security_group_id`, `vpc_id`, `subnet_ids` e `ecs_cluster_arn`. O provider AWS e configurado pelo projeto consumidor na mesma regiao informada em `region`.

Quando `enable_efs = true`, o modulo cria EFS, access point e mount target na primeira subnet em ordem alfabetica, e monta o volume em `efs_container_path`. A prioridade da listener rule deve ser unica no listener compartilhado.
