# Estrutura do Projeto - Organizer V2

Este documento descreve a organização das pastas e arquivos do projeto Organizer V2, uma aplicação Rails para gerenciamento financeiro pessoal.

## 📁 Estrutura Principal

```
organizer_v2/
├── app/                    # Código principal da aplicação
├── bin/                    # Scripts executáveis
├── config/                 # Configurações da aplicação
├── db/                     # Migrações e schema do banco de dados
├── lib/                    # Bibliotecas personalizadas
├── log/                    # Arquivos de log
├── public/                 # Arquivos estáticos públicos
├── spec/                   # Testes RSpec
├── storage/                # Armazenamento de arquivos
├── tmp/                    # Arquivos temporários
├── vendor/                 # Dependências externas
├── Gemfile                 # Dependências Ruby
├── package.json            # Dependências Node.js
├── README.md               # Documentação principal
└── Rakefile               # Tarefas do Rake
```

## 🏗️ App/ - Código Principal

### Controllers (`app/controllers/`)
```
controllers/
├── application_controller.rb    # Controller base
├── home_controller.rb          # Dashboard principal
├── cards_controller.rb         # Gerenciamento de cartões
├── categories_controller.rb    # Gerenciamento de categorias
├── invoices_controller.rb      # Gerenciamento de faturas
├── transferences_controller.rb # Transferências entre contas
├── account/                    # Controllers relacionados a contas
│   └── accounts_controller.rb
├── financing/                  # Controllers de financiamentos
│   └── financings_controller.rb
├── investments/                # Controllers de investimentos
│   └── investments_controller.rb
└── concerns/                   # Módulos compartilhados
```

### Models (`app/models/`)
```
models/
├── application_record.rb       # Model base
├── user.rb                    # Modelo do usuário
├── user_report.rb             # Relatórios do usuário
├── category.rb                # Categorias de despesas
├── transference.rb            # Transferências
├── account/                   # Modelos de contas
│   ├── account.rb
│   ├── savings.rb
│   ├── broker.rb
│   └── card.rb
├── financings/                # Modelos de financiamentos
│   ├── financing.rb
│   └── payment.rb
├── investments/               # Modelos de investimentos
│   ├── investment.rb
│   ├── fixed_investment.rb
│   ├── variable_investment.rb
│   ├── negotiation.rb
│   ├── position.rb
│   ├── dividend.rb
│   └── interest_on_equity.rb
└── concerns/                  # Módulos compartilhados
```

### Services (`app/services/`)
```
services/
├── application_service.rb     # Service base
├── user_services/            # Serviços relacionados ao usuário
│   ├── dashboard_data_service.rb
│   ├── consolidated_user_report.rb
│   ├── fetch_user_reports.rb
│   ├── fetch_user_accounts_summary.rb
│   ├── fetch_user_cards_summary.rb
│   ├── fetch_expenses_by_group.rb
│   ├── fetch_ideal_expense_data.rb
│   └── fetch_investments_allocation.rb
├── investments_services/     # Serviços de investimentos
│   ├── fetch_investments_by_bucket.rb
│   ├── create_fixed_investment.rb
│   ├── create_variable_investment.rb
│   ├── update_investment.rb
│   ├── update_quote.rb
│   └── fetch_investments.rb
├── account_services/         # Serviços de contas
├── category_services/        # Serviços de categorias
├── credit_services/          # Serviços de crédito
├── financing_services/       # Serviços de financiamentos
├── invoice_services/         # Serviços de faturas
├── transaction_services/     # Serviços de transações
└── transference_services/    # Serviços de transferências
```

### Views (`app/views/`)
```
views/
├── layouts/                  # Layouts da aplicação
│   ├── application.html.erb
│   └── _header.html.erb
├── home/                     # Views do dashboard
│   ├── show.html.erb
│   ├── _summary.html.erb
│   ├── _accounts.html.erb
│   ├── _cards.html.erb
│   └── _investments_by_bucket.html.erb
├── account/                  # Views de contas
├── cards/                    # Views de cartões
├── categories/               # Views de categorias
├── financing/                # Views de financiamentos
├── investments/              # Views de investimentos
├── invoices/                 # Views de faturas
├── transferences/            # Views de transferências
└── devise/                   # Views de autenticação
```

### Decorators (`app/decorators/`)
```
decorators/
├── account/                  # Decorators de contas
│   ├── account_decorator.rb
│   └── card_decorator.rb
├── financings/               # Decorators de financiamentos
│   ├── financing_decorator.rb
│   └── payment_decorator.rb
├── investments/              # Decorators de investimentos
│   ├── investment_decorator.rb
│   ├── negotiation_decorator.rb
│   ├── position_decorator.rb
│   ├── dividend_decorator.rb
│   └── interest_on_equity_decorator.rb
├── user_report_decorator.rb  # Decorator de relatórios
└── transference_decorator.rb # Decorator de transferências
```

### Assets (`app/assets/`)
```
assets/
├── images/                   # Imagens
├── javascripts/              # JavaScript
└── stylesheets/              # CSS/SCSS
```

## 🧪 Spec/ - Testes

### Estrutura de Testes (`spec/`)
```
spec/
├── rails_helper.rb           # Configuração do RSpec
├── spec_helper.rb           # Configuração base
├── factories/               # Factories do FactoryBot
│   ├── user.rb
│   ├── account.rb
│   ├── investment.rb
│   ├── negotiation.rb
│   └── ...
├── models/                  # Testes de modelos
│   ├── user_spec.rb
│   ├── account_spec.rb
│   └── investments/
├── controllers/             # Testes de controllers
├── services/                # Testes de services
│   ├── user_services/
│   ├── investments_services/
│   └── ...
├── decorators/              # Testes de decorators
│   ├── account/
│   ├── financings/
│   └── investments/
├── views/                   # Testes de views
├── requests/                # Testes de requisições
├── helpers/                 # Testes de helpers
└── support/                 # Arquivos de suporte aos testes
```

## ⚙️ Config/ - Configurações

### Configurações (`config/`)
```
config/
├── application.rb           # Configuração principal
├── boot.rb                 # Configuração de inicialização
├── database.yml            # Configuração do banco de dados
├── routes.rb               # Rotas da aplicação
├── puma.rb                 # Configuração do servidor Puma
├── environments/           # Configurações por ambiente
│   ├── development.rb
│   ├── test.rb
│   └── production.rb
├── initializers/           # Inicializadores
├── locales/                # Arquivos de tradução
│   ├── en.yml
│   ├── pt-BR.yml
│   └── ...
└── credentials.yml.enc     # Credenciais criptografadas
```

## 🗄️ DB/ - Banco de Dados

### Estrutura do Banco (`db/`)
```
db/
├── migrate/                # Migrações
│   ├── 20240325142811_create_investments.rb
│   ├── 20240517112028_add_shares_total_to_investment.rb
│   └── ...
├── schema.rb              # Schema atual do banco
├── seeds.rb               # Dados iniciais
└── structure.sql          # Estrutura SQL
```

## 📦 Outras Pastas Importantes

### Bin/ - Scripts Executáveis
```
bin/
├── rails                  # Script Rails
├── bundle                 # Script Bundler
└── setup                  # Script de configuração
```

### Lib/ - Bibliotecas Personalizadas
```
lib/
└── tasks/                 # Tarefas personalizadas do Rake
```

### Public/ - Arquivos Públicos
```
public/
├── images/                # Imagens públicas
├── stylesheets/           # CSS público
└── javascripts/           # JavaScript público
```

## 🔧 Arquivos de Configuração Principais

- **Gemfile**: Dependências Ruby e gems
- **package.json**: Dependências Node.js e scripts
- **Dockerfile**: Configuração para containerização
- **Procfile.dev**: Processos para desenvolvimento
- **esbuild.config.js**: Configuração do bundler de assets
- **yarn.lock**: Lock file do Yarn
- **Gemfile.lock**: Lock file do Bundler

## 🎯 Padrões de Organização

### Nomenclatura
- **Controllers**: `snake_case` com sufixo `_controller`
- **Models**: `snake_case` em módulos (`Account::`, `Investments::`)
- **Services**: `snake_case` em módulos por domínio
- **Views**: `snake_case` organizadas por controller
- **Decorators**: `snake_case` em módulos por domínio

### Estrutura de Serviços
- Cada domínio tem sua própria pasta (`user_services/`, `investments_services/`)
- Services seguem o padrão `ServiceName.call(params)`
- Herdam de `ApplicationService`

### Estrutura de Modelos
- Modelos agrupados por domínio em módulos
- Herdam de `ApplicationRecord`
- Relacionamentos bem definidos

### Testes
- Um arquivo de teste para cada arquivo de código
- Factories organizadas por modelo
- Testes de integração separados dos unitários

---

Esta estrutura segue as convenções do Rails e boas práticas de organização de código, facilitando a manutenção e escalabilidade do projeto.
