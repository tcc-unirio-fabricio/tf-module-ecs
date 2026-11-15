# Changelog

Mudancas relevantes deste modulo serao registradas aqui.

## Unreleased

### Added

- Modulo ECS Fargate com integracao a um cluster e ALB existentes.
- Suporte opcional a EFS para persistencia de dados.
- Defaults para imagem Nginx, CPU, memoria, logs e demais configuracoes opcionais.

### Changed

- Arquivos Terraform organizados na pasta `terraform/`; README e changelog permanecem na raiz.
- Exemplo de `source` atualizado para selecionar a subpasta `terraform` do repositorio.
