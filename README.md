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

3. Configure a URL da API:
   - Edite `lib/core/constants/api_endpoints.dart`
   - Ou defina via variável de ambiente: `--dart-define=API_BASE_URL=http://seu-servidor:3001`

4. Execute o app:
```bash
flutter run
```

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
