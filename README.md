# 📊 Monitor de Serviços - Flutter

Um aplicativo móvel moderno e eficiente desenvolvido em **Flutter** para monitorar a disponibilidade de sites e serviços web em tempo real. O aplicativo permite que o usuário cadastre suas próprias URLs, salva os dados localmente no dispositivo e emite **Notificações Nativas** caso algum serviço fique fora do ar.

## 🚀 Funcionalidades

* **Cadastro Dinâmico:** Adicione serviços personalizados (Nome e URL/IP) diretamente pelo aplicativo.
* **Armazenamento Local:** Integração com **SQLite** para salvar seus serviços de forma segura e offline.
* **Isolamento de Dados (UUID):** Geração de um identificador único para o dispositivo, garantindo que o banco de dados carregue apenas as configurações do aparelho atual.
* **Monitoramento Automatizado:** Checagem contínua do status dos serviços a cada 5 minutos.
* **Notificações Locais:** Alertas visuais e sonoros integrados ao sistema operacional (Android/iOS) que avisam instantaneamente quando um serviço cai, sem depender de APIs de terceiros.
* **Lógica Anti-Spam de Alertas:** Sistema inteligente que limita a emissão de notificações a cada 10 minutos por serviço.

---

## 📁 Estrutura do Projeto

O projeto adota uma arquitetura limpa, separando interface, banco de dados e regras de negócio:

```text
lib/
│
├── models/
│   └── service_model.dart         # Estrutura do serviço e conversores para o SQLite (toMap/fromMap).
│
├── widgets/
│   └── service_card.dart          # Componente visual reutilizável para a lista.
│
├── pages/
│   └── dashboard_page.dart        # Tela principal, controle de temporizadores e interface de cadastro.
│
├── services/
│   ├── monitoring_service.dart    # Lógica de requisições HTTP para validar o status das URLs.
│   ├── database_service.dart      # Gerenciamento do SQLite (Criação, Inserção, Atualização e Leitura).
│   └── notification_service.dart  # Configuração e disparo de notificações locais nativas.
│
└── main.dart                      # Ponto de entrada do app e inicialização de serviços.

```

---

## 🛠️ Tecnologias e Pacotes Utilizados

* **Flutter / Dart** (Framework e Linguagem)
* **[sqflite](https://pub.dev/packages/sqflite):** Para o banco de dados relacional local.
* **[flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications):** Para emissão de alertas nativos do dispositivo.
* **[http](https://pub.dev/packages/http):** Para checagem de ping/status das URLs.
* **[uuid](https://pub.dev/packages/uuid):** Para gerar o identificador único do celular.

---

## ⚙️ Permissões do Android

Para o funcionamento correto em dispositivos Android (especialmente Android 13 ou superior), o aplicativo exige as seguintes permissões no arquivo `AndroidManifest.xml`:

* `<uses-permission android:name="android.permission.INTERNET" />` (Para testar o status das URLs)
* `<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />` (Para emitir os alertas)

---

## 🏃 Como Executar o Projeto

1. Clone este repositório para a sua máquina local:
```bash
git clone [https://github.com/seu-usuario/seu-repositorio.git](https://github.com/seu-usuario/seu-repositorio.git)

```


2. Abra o terminal na pasta do projeto e baixe as dependências:
```bash
flutter pub get

```


3. Conecte um emulador ou dispositivo físico e execute:
```bash
flutter run

```


4. Para gerar a versão final (Release) para Android:
```bash
flutter build apk --release

```



---

## 🧠 Conceitos Aplicados

Este projeto serve como um excelente portfólio de conhecimentos sólidos em desenvolvimento mobile:

* **Persistência de Dados:** Operações CRUD utilizando banco de dados SQL dentro do celular.
* **Comunicação Nativa:** Uso de *Method Channels* de forma abstraída para acionar recursos do sistema operacional (Notificações).
* **Design Patterns:** Utilização do padrão *Singleton* para garantir uma única instância de conexão com o banco de dados.
* **Programação Assíncrona e HTTP:** Gestão eficiente de *Futures* para validar conexões de rede sem travar a interface do usuário.
