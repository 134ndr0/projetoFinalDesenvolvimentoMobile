# 📊 Monitor de Serviços - Flutter

Um aplicativo móvel simples, moderno e eficiente desenvolvido em **Flutter** para monitorar a disponibilidade de sites e serviços web. O aplicativo checa o status das URLs configuradas e envia alertas automatizados por e-mail caso algum serviço fique fora do ar.

## 🚀 Funcionalidades

* **Monitoramento em Tempo Real:** Checagem automática do status dos serviços a cada 5 minutos.
* **Interface Moderna e Semântica:** Cores intuitivas (Verde para Online, Vermelho para Offline) que facilitam a leitura rápida do painel.
* **Favoritos:** Opção para marcar serviços de importância significativa.
* **Alertas Inteligentes por E-mail:** Integração com a API do **Brevo** para envio de e-mails de alerta.
* **Lógica Anti-Spam:** Sistema que limita o envio de alertas a cada 10 minutos por serviço, evitando sobrecarga na caixa de entrada.

---

## 📁 Estrutura do Projeto

O projeto segue uma arquitetura limpa e modular, separando as responsabilidades em pastas específicas dentro de `lib/`:

```
lib/
│
├── models/
│   └── service_model.dart       # Definição da estrutura de dados do serviço.
│
├── widgets/
│   └── service_card.dart        # Componente visual reutilizável (StatelessWidget).
│
├── pages/
│   └── dashboard_page.dart      # Tela principal e controle do temporizador (StatefulWidget).
│
├── services/
│   └── monitoring_service.dart  # Lógica de requisições HTTP e integração com a API do Brevo.
│
└── main.dart                    # Inicialização e configuração do tema do app.
```

---

## 🛠️ Tecnologias Utilizadas

* **Dart** (Linguagem de programação)
* **Flutter** (Framework UI)
* **Http Package** (Para requisições web e comunicação com a API)

---

## 🏃 Como Executar o Projeto

1. Clone este repositório para a sua máquina local.
2. Abra o terminal na raiz do projeto e instale as dependências:
```bash
flutter pub get

```


3. Execute o aplicativo em um emulador ou dispositivo físico conectado:
```bash
flutter run

```



---

## 🧠 Conceitos Praticados

Este projeto foi excelente para consolidar fundamentos essenciais do ecossistema Flutter:

* **Gerenciamento de Estado Básico:** Uso de `StatefulWidget` e `setState` para atualizar a tela após as checagens de rede.
* **Componentização:** Uso de `StatelessWidget` para criar interfaces isoladas e reutilizáveis.
* **Programação Assíncrona:** Uso de `Future`, `async` e `await` para realizar requisições HTTP sem travar a interface do usuário.
* **Ciclo de Vida de Widgets:** Implementação do `initState` e `dispose` para gerenciar a criação e destruição de temporizadores (`Timer`) em segundo plano de forma segura.
