# POLYS Mobile

Aplicativo mobile do POLYS desenvolvido em **Flutter/Dart**, conectando-se ao backend **NestJS + Prisma + PostgreSQL**.

## 📱 Visão Geral

O POLYS é uma plataforma comunitária que permite:
- 🚀 **Projetos Comunitários**: Criação, votação e financiamento de projetos locais
- 🛒 **Loja Local**: Marketplace de produtos da comunidade
- 🔧 **Serviços**: Oferta e contratação de serviços locais
- 🗺️ **Zonas Geográficas**: Organização por regiões/bairros

## 🏗️ Arquitetura

O projeto segue uma arquitetura limpa (Clean Architecture) adaptada para Flutter:

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # App configuration
├── core/                     # Core utilities
│   ├── constants/            # Colors, strings, endpoints
│   ├── errors/               # Custom exceptions
│   ├── network/              # API client, interceptors
│   ├── storage/              # Secure storage
│   └── utils/                # Formatters, validators, helpers
├── data/                     # Data layer
│   ├── models/               # Data models (JSON serializable)
│   └── repositories/         # Repository implementations
├── presentation/             # UI layer
│   ├── providers/            # State management (Provider)
│   ├── screens/              # Pages/Screens
│   ├── widgets/              # Reusable widgets
│   └── theme/                # App theme
└── routes/                   # Navigation
```

## 🚀 Começando

### Pré-requisitos

- Flutter SDK 3.2.0 ou superior
- Dart 3.2.0 ou superior
- Android Studio / VS Code
- Emulador ou dispositivo físico

### Instalação

1. Clone o repositório:
```bash
git clone <repository-url>
cd Polys-Mobile
```

2. Instale as dependências:
```bash
flutter pub get
```

3. **Inicializar estrutura do projeto (se necessário):**
   Se o projeto não tiver as pastas `android/` ou `ios/`, execute:
   ```bash
   flutter create .
   ```
   Isso criará todos os arquivos necessários para Android, iOS e outras plataformas.

4. Configure a URL da API:
   - Edite `lib/core/constants/api_endpoints.dart`
   - Ou defina via variável de ambiente: `--dart-define=API_BASE_URL=http://seu-servidor:3001`

### 🎯 Executando a Aplicação

#### ⚡ Comandos Diretos (Recomendado para Produção)

**1. Verificar/Criar emulador:**
```bash
flutter emulators
```

Se não houver emuladores, crie um:
```bash
flutter emulators --create
```

**2. Iniciar emulador:**
```bash
flutter emulators --launch flutter_emulator
```

**3. Verificar dispositivos disponíveis:**
```bash
flutter devices
```

**4. Executar o app:**
```bash
flutter run
```

**Ou especificar o dispositivo diretamente (evita seleção interativa):**
```bash
flutter run -d emulator-5554
```

**Comando completo (se o emulador já estiver rodando):**
```bash
flutter run -d emulator-5554
```

O Flutter detectará automaticamente o emulador em execução. Se houver múltiplos dispositivos, use `-d <device_id>` para evitar a seleção interativa.

#### Opção 2: Emulador Android (Passo a Passo)

**Método Alternativo (Android Studio):**

1. **Configurar Emulador Android:**
   - Abra o Android Studio
   - Vá em **Tools > Device Manager** (ou **AVD Manager**)
   - Clique em **Create Device**
   - Escolha um dispositivo (ex: Pixel 5)
   - Selecione uma imagem do sistema (recomendado: API 33 ou superior)
   - Finalize a criação

2. **Iniciar o Emulador:**
   - No Device Manager, clique em ▶️ (Play) no emulador criado
   - Ou via terminal:
   ```bash
   flutter emulators --launch <nome_do_emulador>
   ```

3. **Verificar dispositivos disponíveis:**
   ```bash
   flutter devices
   ```

4. **Executar o app:**
   ```bash
   flutter run
   ```

**Método Alternativo (Android Studio):**

1. **Configurar Emulador Android:**
   - Abra o Android Studio
   - Vá em **Tools > Device Manager** (ou **AVD Manager**)
   - Clique em **Create Device**
   - Escolha um dispositivo (ex: Pixel 5)
   - Selecione uma imagem do sistema (recomendado: API 33 ou superior)
   - Finalize a criação

2. **Iniciar o Emulador:**
   - No Device Manager, clique em ▶️ (Play) no emulador criado
   - Ou via terminal:
   ```bash
   flutter emulators --launch <nome_do_emulador>
   ```

3. **Verificar dispositivos disponíveis:**
   ```bash
   flutter devices
   ```

4. **Executar o app:**
   ```bash
   flutter run
   ```
   O Flutter detectará automaticamente o emulador em execução.

#### Opção 3: Executar em Dispositivo Específico

**Listar dispositivos:**
```bash
flutter devices
```

**Executar em dispositivo específico:**
```bash
flutter run -d <device_id>
```

Exemplo:
```bash
flutter run -d emulator-5554
```

#### Opção 4: Dispositivo Físico Android

1. **Habilitar Modo Desenvolvedor:**
   - Vá em **Configurações > Sobre o telefone**
   - Toque 7 vezes em **Número da versão** ou **Versão do MIUI**
   - Volte para **Configurações > Sistema > Opções do desenvolvedor**
   - Ative **Depuração USB**

2. **Conectar o dispositivo:**
   - Conecte o celular ao computador via USB
   - Aceite a autorização de depuração USB no celular (se solicitado)

3. **Verificar conexão:**
   ```bash
   flutter devices
   ```
   Você deve ver seu dispositivo listado.

4. **Executar o app:**
   ```bash
   flutter run
   ```

#### Opção 5: Emulador iOS (apenas macOS)

1. **Abrir Simulador iOS:**
   ```bash
   open -a Simulator
   ```

2. **Executar o app:**
   ```bash
   flutter run
   ```

#### Opção 6: Dispositivo iOS Físico (apenas macOS)

1. **Conectar iPhone/iPad via USB**
2. **Confiar no computador** (se solicitado no dispositivo)
3. **Executar:**
   ```bash
   flutter run
   ```

#### Comandos Úteis Durante a Execução

Quando o app estiver rodando, você pode usar:

- **Hot Reload:** Pressione `r` no terminal (recarrega mudanças sem perder estado)
- **Hot Restart:** Pressione `R` no terminal (reinicia o app mantendo o estado)
- **Ver logs:** Pressione `v` no terminal
- **Sair:** Pressione `q` no terminal

#### Comandos de Build para Produção

**Build APK (Android):**
```bash
flutter build apk --release
```

**Build App Bundle (Android - Google Play):**
```bash
flutter build appbundle --release
```

**Build iOS (apenas macOS):**
```bash
flutter build ios --release
```

#### Troubleshooting

- **"No devices found" ou só aparecem Windows/Chrome/Edge:**
  - Isso significa que não há emulador rodando ou dispositivo físico conectado
  - **Solução:** Crie e inicie um emulador:
    ```bash
    flutter emulators --create
    flutter emulators --launch flutter_emulator
    ```
  - Aguarde 20-30 segundos e verifique com `flutter devices`
  - Se ainda não aparecer, execute `flutter doctor` para verificar a configuração

- **"No emulators available":**
  - Execute `flutter emulators --create` para criar um emulador automaticamente
  - Ou crie manualmente pelo Android Studio (Device Manager)

- **Emulador aparece como "offline":**
  - Aguarde mais alguns segundos (o emulador demora para inicializar)
  - Verifique se o emulador está visível na tela (janela do Android)
  - Execute `flutter devices` novamente após 30 segundos

- **Erro de conexão com API:**
  - Se estiver usando emulador Android, use `10.0.2.2` em vez de `localhost` para acessar o servidor local
  - Exemplo: `http://10.0.2.2:3001` em vez de `http://localhost:3001`

- **Erro de permissões:**
  - Verifique se as permissões necessárias estão configuradas no `AndroidManifest.xml` (Android) ou `Info.plist` (iOS)

- **"AndroidManifest.xml could not be found" ou "No application found for TargetPlatform.android_x64":**
  - Execute `flutter create .` para criar a estrutura do projeto Android/iOS
  - Isso criará todos os arquivos necessários sem sobrescrever seu código em `lib/`

## 📡 API Backend

O app se conecta ao backend NestJS. Endpoints principais:

- `POST /auth/login` - Autenticação
- `POST /auth/register` - Cadastro
- `GET /projects` - Lista projetos
- `GET /products` - Lista produtos
- `GET /services` - Lista serviços
- `GET /zones` - Lista zonas

## 🎨 Design System

### Cores Principais
- **Primary (Teal)**: `#14B8A6`
- **Secondary (Emerald)**: `#10B981`
- **Projetos**: `#14B8A6` (Teal)
- **Produtos**: `#8B5CF6` (Purple)
- **Serviços**: `#F59E0B` (Amber)

### Tipografia
- Font: Inter (Google Fonts)
- Títulos: Bold, 24-32sp
- Body: Regular, 14-16sp

## 📦 Dependências Principais

- `provider` - Gerenciamento de estado
- `dio` - Cliente HTTP
- `flutter_secure_storage` - Armazenamento seguro
- `flutter_map` - Mapas
- `geolocator` - Geolocalização
- `fl_chart` - Gráficos

## 👥 Cargos de Usuário

- **USER**: Visualizar, votar, doar, comprar, agendar
- **gestor**: + Criar projetos, moderar conteúdo
- **admin/administrador**: + Todas as funções administrativas
- **suporte**: + Gerenciar tickets

## 📱 Telas

### Autenticação
- Splash Screen
- Login
- Cadastro

### Principal
- Dashboard
- Projetos (lista e detalhes)
- Loja (produtos)
- Serviços
- Perfil

### Vendedor
- Painel do Vendedor
- Criar/Editar Produtos
- Criar/Editar Serviços

### Admin
- Gestão de Usuários
- Gestão de Zonas
- Configurações do App

## 🔐 Segurança

- JWT Token armazenado de forma segura
- Interceptor automático para autenticação
- Logout automático em token expirado

## 📄 Licença

Projeto privado - Todos os direitos reservados.
