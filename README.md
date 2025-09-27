# Projeto de Modernização DevOps para Aplicação PHP

## 1. Visão Geral
Este repositório contém a solução completa para a primeira fase de modernização de uma aplicação PHP. Saindo de um processo de deploy manual, lento e arriscado, para uma fundação moderna, automatizada e segura, pronta para acompanhar o crescimento da  aplicação PHP. 

Usada uma aplicação simples como exemplo.

## 2. Estrutura do Repositório
```
.
├── .github/
│   └── workflows/
│       └── main.yml         # Pipeline de Integração Contínua (CI)
├── infra/
│   ├── main.tf              # Código Terraform da infraestrutura (ECS)
│   ├── variables.tf         # Variáveis de configuração do Terraform
│   └── task-definition.json # Exemplo de definição de tarefa do ECS
└── Dockerfile               # Arquivo de containerização da aplicação
└── README.md                # Este relatório
```

---
## 3. Etapa 1: Containerização da Aplicação
O `Dockerfile` foi projetado com foco em otimização e segurança, utilizando as seguintes práticas:
- **Multi-Stage Builds:** Um primeiro estágio (`builder`) é usado para lidar com dependências, resultando em uma imagem de produção final menor e com superfície de ataque reduzida.
- **Imagem Base Oficial:** Utilizamos `php:8.2-alpine`, uma imagem oficial e bem mantida, com a versão fixada para garantir builds consistentes.
- **Usuário Não-Root:** A aplicação é executada por um usuário `appuser` com privilégios limitados, uma prática de segurança essencial para mitigar riscos em caso de comprometimento do contêiner.

---
## 4. Etapa 2: Pipeline de Integração Contínua (CI)
O pipeline de CI, localizado em `.github/workflows/main.yml`, é acionado a cada `push` na branch `main` e automatiza os seguintes passos:
1.  **Checkout do Código:** Baixa a versão mais recente do código.
2.  **Build & Push:** Constrói a imagem Docker e a envia para o Docker Hub, tagueada com o hash do commit para rastreabilidade.
3.  **Análise de Vulnerabilidades:** Utiliza a ferramenta **Trivy** para escanear a imagem em busca de vulnerabilidades conhecidas (CVEs), falhando o build caso encontre problemas de severidade alta ou crítica.

---
## 5. Etapa 3: Infraestrutura como Código (IaC) e Implantação (CD)

### Justificativa da Escolha: AWS ECS com Fargate
Para a orquestração de contêineres, a escolha foi **AWS ECS com Fargate** em vez de EKS (Kubernetes).
- **Simplicidade Operacional:** Fargate é *serverless*, eliminando a necessidade de gerenciar servidores. Isso reduz drasticamente a carga operacional, ideal para uma equipe em transição para DevOps.
- **Curva de Aprendizagem:** ECS é consideravelmente mais simples de aprender e configurar do que Kubernetes, permitindo uma adoção mais rápida e com menos riscos.
- **Custo-Benefício:** O modelo de pagamento por uso do Fargate é ideal para esta aplicação, evitando custos com capacidade ociosa de instâncias.

### Explicação da Implantação Contínua (CD)
Para estender o pipeline de CI para CD, um novo `job` (`deploy`) seria adicionado ao `main.yml`. Este job:
1.  Seria acionado apenas após o sucesso do job de CI (`build-scan-and-push`).
2.  Se autenticaria na AWS usando segredos armazenados no GitHub.
3.  Executaria um comando da AWS CLI (`aws ecs update-service --force-new-deployment`) para instruir o serviço ECS a baixar a nova imagem (identificada pela tag do commit) e substituir os contêineres antigos, garantindo um deploy **zero-downtime**.

---
## 6. Etapa 4: Estratégia de Observabilidade
Para monitorar a aplicação em produção, a seguinte stack de ferramentas open-source seria escolhida como sugestão:
- **Métricas:** **Prometheus** para coletar métricas de tempo real da aplicação e da infraestrutura, e **Grafana** para criar dashboards visuais e configurar alertas.
- **Logs:** **EFK Stack (Elasticsearch, Fluentd, Kibana)**. Fluentd coletaria os logs dos contêineres, Elasticsearch os centralizaria para busca e análise, e Kibana os visualizará.

### As 3 Principais Métricas para um Dashboard de Saúde
1.  **Taxa de Erros HTTP (5xx):** A métrica mais crítica para a saúde da aplicação. Um aumento repentino indica falhas graves que afetam os usuários.
2.  **Latência de Requisição (Percentil 95):** Mede o tempo de resposta para 95% dos usuários, oferecendo uma visão muito mais precisa da experiência do usuário do que a média. Essencial para detectar lentidão.
3.  **Utilização de CPU/Memória do Contêiner:** Métrica fundamental da infraestrutura. Monitorá-la previne falhas por exaustão de recursos e informa as decisões de auto-scaling.


## FAQ:
1. Como realizar o build e rodar a aplicacao localmente:

   docker-compose build

   docker-compose up

2. Como a aplicação aparece quando esta rodando:

![Aplicacao rodando](https://github.com/EBOA10/desafio-devops/blob/3ff885c28e698b55dbaa6c4fa7f35a6f14894f45/images/Screenshot_localhost_8080.png?raw=true)

3. Qual é o link para as imagens no registry?

   [Docker Hub - EBOA10](https://hub.docker.com/r/eboa10/desafio-devops/tags)
