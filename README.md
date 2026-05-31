# 🚨 ServiceAlert - Monitor de Status de Serviços

**ServiceAlert** é um aplicativo mobile desenvolvido em Flutter projetado para monitorar a disponibilidade de servidores, sites e APIs em tempo real. O aplicativo roda de forma ininterrupta em segundo plano, enviando notificações locais imediatas caso algum serviço cadastrado saia do ar.

Este projeto foi desenvolvido como **Projeto Final da disciplina de Desenvolvimento Mobile**.

---

## 🚀 Funcionalidades Principais

* **Identificação Única e Persistente (UUID):** Geração de um identificador exclusivo para o dispositivo na primeira inicialização, armazenado de forma segura via `SharedPreferences`. Os dados não são perdidos ao fechar o app.
* **Gerenciamento de Serviços (CRUD Completo):** Interface intuitiva para adicionar, listar, editar endereços/nomes e excluir serviços monitorados com caixas de diálogo de confirmação.
* **Monitoramento em Segundo Plano (Foreground Service):** Integração com o `flutter_background_service` para garantir checagens estritas a cada **5 minutos**, mesmo se o aplicativo for minimizado ou fechado pelo sistema.
* **Sistema de Alertas Inteligente:** Disparo de notificações locais (`flutter_local_notifications`) quando uma queda é detectada, respeitando um intervalo de 10 minutos entre alertas idênticos para evitar spam.
* **Sincronização Manual com Feedback Dinâmico:** Botão de atualização na interface que força a checagem imediata da rede e exibe um `SnackBar` contextualizável ("Tudo certo por aqui" ou "Ainda existem sistemas fora do ar").
* **Próxima Verificação Visível:** Contador estático que exibe o horário exato (HH:mm:ss) em que a próxima checagem em segundo plano será disparada.

---

## 🛠️ Tecnologias e Pacotes Utilizados

* **Flutter & Dart** (Configurado com suporte moderno a Kotlin DSL `.kts` no Android)
* **SQFlite:** Banco de dados relacional local para persistência dos sites cadastrados e histórico de status.
* **SharedPreferences:** Armazenamento chave-valor para retenção estável do UUID do dispositivo.
* **Flutter Background Service:** Criação do serviço nativo em primeiro plano (Foreground Task) para imunidade contra o encerramento do sistema.
* **Flutter Local Notifications:** Motor de agendamento e exibição de alertas visuais e sonoros no sistema operacional.
* **Http / Internet Connection Check:** Módulo responsável por testar a conectividade ativa das URLs/IPs configurados.

---

## ⚙️ Configurações Nativas Obrigatórias (Android)

Para o correto funcionamento do monitoramento persistente de 5 em 5 minutos, o projeto conta com as seguintes configurações críticas:

### 1. Java 8+ Desugaring (`android/app/build.gradle.kts`)
Ativação do tradutor de APIs modernas para compatibilidade com fusos horários e notificações em dispositivos legados:
```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
    isCoreLibraryDesugaringEnabled = true
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

```

### 2. Permissões de Sistema (`android/app/src/main/AndroidManifest.xml`)

Declaração de privilégios para execução em background e sincronização contínua de dados:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />

<application ...>
    <service
        android:name="id.flutter.flutter_background_service.BackgroundService"
        android:foregroundServiceType="dataSync"
        android:exported="true" />
</application>

```

---

## 📦 Como Instalar e Executar o Projeto

Siga os passos abaixo no seu terminal para clonar, limpar caches antigos e compilar o aplicativo de forma limpa:

1. **Clonar o repositório:**
```bash
git clone [https://github.com/seu-usuario/app_servicealert.git](https://github.com/seu-usuario/app_servicealert.git)
cd app_servicealert

```


2. **Limpar o cache de compilações nativas anteriores:**
```bash
flutter clean

```


3. **Baixar e vincular as dependências do `pubspec.yaml`:**
```bash
flutter pub get

```


4. **Executar em um emulador ou dispositivo físico conectado:**
```bash
flutter run

```


---

## 👥 Desenvolvedor

* **Leandro Coelho** - *Desenvolvimento Mobile*
