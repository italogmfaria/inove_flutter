# INOVE - Plataforma Educacional Online para Apoio ao Ensino (Mobile)

O **INOVE (Inovação Online para Vivências Educacionais)** é uma plataforma educacional online destinada exclusivamente a docentes, com o objetivo de apoiá-los no aprendizado e na aplicação de ferramentas digitais e metodologias de ensino inovadoras. O aplicativo mobile foi desenvolvido em Flutter, consumindo a API RESTful do back-end em Spring Boot. A autenticação é baseada em JWT, com tokens armazenados localmente via SharedPreferences; os conteúdos (vídeos e PDFs) são transmitidos diretamente da AWS S3 e reproduzidos natively no dispositivo.
Entre as funcionalidades implementadas destacam-se autenticação com JWT, navegação protegida por papéis (guards de rota), catálogo de cursos com busca, matrícula e cancelamento, reprodução de vídeos e visualização de PDFs, controle de progresso por conteúdo, sistema de feedback por curso, gerenciamento de perfil e associação com escola. A arquitetura segue o padrão **MVVM** com Provider como gerenciador de estado, suportando temas claro e escuro via Material Design 3.

---

## Tecnologias Utilizadas

- Flutter 3 (SDK Dart ^3.9.0)
- Provider 6.1.1 (gerenciamento de estado — ChangeNotifier/MVVM)
- HTTP 1.2.0 (cliente REST)
- SharedPreferences 2.2.2 (armazenamento local de tokens)
- Google Fonts 6.2.1 (tipografia — família Inter)
- Flutter SVG 2.0.9 (suporte a imagens vetoriais)
- Cached Network Image 3.3.1 (cache de imagens remotas)
- Video Player 2.8.2 + Chewie 1.7.5 (reprodução de vídeos)
- Flutter PDFView 1.3.2 (visualização de PDFs)
- Image Picker 1.1.1 (seleção de imagem de perfil)
- JSON Annotation 4.8.1 + JSON Serializable 6.7.1 (serialização)
- Build Runner 2.4.8 (geração de código)
- Flutter Launcher Icons 0.14.1 (ícones de app)

---

## Perfis de Usuários

O aplicativo mobile é voltado exclusivamente ao perfil **Discente**, com acesso controlado por guards de rota que verificam o token JWT e o papel do usuário. Tentativas de acesso com perfil diferente de `STUDENT` são rejeitadas silenciosamente no momento do login.

**Discente (Usuário):** usuário final, professores que consomem os cursos da plataforma. Realiza cadastro e login, navega pelo catálogo de cursos disponíveis, realiza matrícula e cancelamento, acessa seções e conteúdos (vídeos e PDFs), acompanha seu progresso por conteúdo, deixa feedbacks sobre os cursos e gerencia seu perfil, incluindo a associação com uma escola.

---

## Estrutura do Sistema

### Arquitetura

```
lib/
├── main.dart                          # Entry point com configuração do MultiProvider
├── core/                              # Configurações centrais da aplicação
│   ├── guards/
│   │   ├── auth_guard.dart           # Lógica de proteção de rotas
│   │   └── guarded_route.dart        # Widget de rota protegida
│   ├── routes/
│   │   ├── app_routes.dart           # Constantes de rotas nomeadas
│   │   └── app_pages.dart            # Definição de rotas com injeção de dependência
│   ├── theme/
│   │   ├── app_colors.dart           # Paleta de cores
│   │   └── app_theme.dart            # Temas claro e escuro (Material Design 3)
│   └── utils/
│       ├── constants.dart            # Constantes globais (URLs da API, flags)
│       ├── formatters.dart           # Utilitários de formatação de texto
│       ├── helpers.dart              # Funções auxiliares de UI
│       ├── validators.dart           # Validação de formulários (e-mail, CPF, senha)
│       ├── theme_provider.dart       # Provider de tema claro/escuro
│       └── profanity_list.dart       # Filtro de conteúdo inapropriado
├── model/                             # Modelos de dados (DTOs)
│   ├── auth_response.dart            # Resposta de autenticação (token + userId)
│   ├── user_model.dart               # Dados do usuário/discente
│   ├── course_model.dart             # Curso com relações aninhadas
│   ├── section_model.dart            # Seções de um curso
│   ├── content_model.dart            # Conteúdo (vídeo ou PDF)
│   ├── feedback_model.dart           # Feedback de curso
│   ├── completed_content_model.dart  # Progresso por conteúdo
│   ├── school_model.dart             # Escola vinculada ao usuário
│   └── user_role.dart                # Enumeração de papéis de usuário
├── services/                          # Camada de serviços (integração com a API)
│   ├── api_service.dart              # Cliente HTTP com injeção de token Bearer
│   ├── auth_service.dart             # Autenticação e gerenciamento de sessão
│   ├── user_service.dart             # Perfil, matrícula e cursos do usuário
│   ├── course_service.dart           # Listagem e detalhes de cursos
│   ├── section_service.dart          # Seções de um curso
│   ├── content_service.dart          # Conteúdos de uma seção
│   ├── feedback_service.dart         # CRUD de feedbacks
│   ├── school_service.dart           # Listagem de escolas
│   ├── user_progress_service.dart    # Marcação e consulta de progresso
│   ├── password_recovery_service.dart # Recuperação de senha por e-mail
│   └── file_service.dart             # Operações de arquivo
├── view/                              # Telas da aplicação (14 telas)
│   ├── index/                        # Splash screen (verificação de sessão)
│   ├── inicial/                      # Tela de boas-vindas
│   ├── login/                        # Login do discente
│   ├── cadastro/                     # Cadastro de discente
│   ├── cadastro_escola/              # Cadastro de escola
│   ├── esqueci_senha/                # Início da recuperação de senha
│   ├── verificar_codigo/             # Verificação do código de recuperação
│   ├── redefinir_senha/              # Redefinição de senha
│   ├── cursos/                       # Catálogo público de cursos
│   ├── meus_cursos/                  # Cursos matriculados do discente
│   ├── preview_curso/                # Detalhes e prévia de um curso
│   ├── painel_curso/                 # Painel de conteúdo do curso (vídeo/PDF + progresso)
│   └── perfil/                       # Perfil do usuário
├── viewmodel/                         # ViewModels (Provider + ChangeNotifier)
│   ├── index_viewmodel.dart
│   ├── inicial_viewmodel.dart
│   ├── login_viewmodel.dart
│   ├── cadastro_viewmodel.dart
│   ├── cadastro_escola_viewmodel.dart
│   ├── esqueci_senha_viewmodel.dart
│   ├── verificar_codigo_viewmodel.dart
│   ├── redefinir_senha_viewmodel.dart
│   ├── cursos_viewmodel.dart
│   ├── meus_cursos_viewmodel.dart
│   ├── painel_curso_viewmodel.dart
│   ├── preview_curso_viewmodel.dart
│   └── perfil_viewmodel.dart
└── widgets/                           # Componentes reutilizáveis (10 widgets)
    ├── background_decoration.dart    # Fundo decorativo padrão
    ├── custom_bottom_nav.dart        # Barra de navegação inferior customizada
    ├── custom_dropdown.dart          # Dropdown customizado
    ├── custom_input.dart             # Campo de formulário customizado
    ├── edit_profile_modal.dart       # Modal de edição de perfil
    ├── pdf_viewer_widget.dart        # Visualizador de PDF (flutter_pdfview)
    ├── video_player_widget.dart      # Player de vídeo (Chewie + video_player)
    ├── primary_button.dart           # Botão primário (estilo padrão)
    └── secondary_button.dart         # Botão secundário (estilo outline)
```

### Navegação e Guards de Rota

O sistema de navegação utiliza rotas nomeadas do Navigator com três tipos de proteção:

| Tipo de Guard       | Comportamento                                              | Rotas protegidas                                                         |
|---------------------|------------------------------------------------------------|--------------------------------------------------------------------------|
| `onlyGuest`         | Redireciona para `/cursos` se o usuário já estiver logado  | `/login`, `/cadastro`, `/cadastro-escola`, `/esqueci-senha`, `/verificar-codigo`, `/redefinir-senha` |
| `onlyAuth`          | Redireciona para `/login` se não estiver autenticado       | `/meus-cursos`, `/perfil`, `/painel-curso`                               |
| `public`            | Acessível por todos                                        | `/cursos`, `/preview-curso`                                              |

**Fluxo inicial:**
1. App inicia em `/` (splash screen)
2. `IndexViewModel` verifica token salvo no SharedPreferences
3. Redireciona para `/inicial` (sem sessão) ou `/meus-cursos` (autenticado)

### Telas da Aplicação

| Tela                  | Rota               | Guard        | Descrição                                                    |
|-----------------------|--------------------|--------------|--------------------------------------------------------------|
| `IndexView`           | `/`                | —            | Splash screen com verificação de sessão                      |
| `InicialView`         | `/inicial`         | onlyGuest    | Tela de boas-vindas com opções de login e cadastro           |
| `LoginView`           | `/login`           | onlyGuest    | Autenticação do discente com e-mail e senha                  |
| `CadastroView`        | `/cadastro`        | onlyGuest    | Cadastro de novo discente com validação de CPF               |
| `CadastroEscolaView`  | `/cadastro-escola` | onlyGuest    | Cadastro de escola vinculada ao usuário                      |
| `EsqueciSenhaView`    | `/esqueci-senha`   | onlyGuest    | Solicitação de recuperação de senha por e-mail               |
| `VerificarCodigoView` | `/verificar-codigo`| onlyGuest    | Verificação do código de 6 dígitos enviado por e-mail        |
| `RedefinirSenhaView`  | `/redefinir-senha` | onlyGuest    | Redefinição da senha com o código verificado                 |
| `CursosView`          | `/cursos`          | public       | Catálogo de cursos com busca e prévia de conteúdo            |
| `MeusCursosView`      | `/meus-cursos`     | onlyAuth     | Cursos em que o discente está matriculado, com progresso     |
| `PreviewCursoView`    | `/preview-curso`   | public       | Detalhes do curso, instrutor, seções e opção de matrícula    |
| `PainelCursoView`     | `/painel-curso`    | onlyAuth     | Reprodução de vídeo/PDF, marcação de progresso e feedbacks   |
| `PerfilView`          | `/perfil`          | onlyAuth     | Visualização e edição de perfil, escola vinculada e logout   |

### Modelos de Dados

| Modelo                   | Campos principais                                                          | Origem                        |
|--------------------------|----------------------------------------------------------------------------|-------------------------------|
| `AuthResponse`           | token, refreshToken, userId                                                | POST /auth/login              |
| `UserModel`              | id, nome, cpf, email, dataNasc, role, motivacao                            | GET /usuarios/{id}            |
| `CourseModel`            | id, nome, descricao, imageUrl, instrutor, sections, progresso              | GET /cursos, /cursos/{id}     |
| `SectionModel`           | id, titulo, descricao, contents                                            | GET /cursos/{id}/secoes       |
| `ContentModel`           | id, titulo, descricao, contentType, fileUrl, fileName                      | GET .../conteudos             |
| `FeedbackModel`          | id, comentario, usuario, courseId                                          | GET /feedbacks/course/{id}    |
| `CompletedContentModel`  | userId, contentId                                                          | POST .../progresso            |
| `SchoolModel`            | id, nome, cidade, estado, email                                            | GET /escolas, /usuarios/{id}/school |
| `UserRole`               | `STUDENT`, `INSTRUCTOR`, `ADMINISTRATOR`                                   | Extraído do token JWT         |

### Serviços e Integração com a API

O `ApiService` centraliza todas as requisições HTTP, injetando automaticamente o token JWT armazenado no SharedPreferences. O ambiente é configurado via `Constants.isProduction`:

| Ambiente    | URL base                                                   |
|-------------|------------------------------------------------------------|
| Local       | `http://localhost:8080/api/inove`                          |
| Produção    | `https://inove-production.up.railway.app/api/inove`        |

| Serviço                     | Endpoints consumidos                                                                       |
|-----------------------------|--------------------------------------------------------------------------------------------|
| `AuthService`               | POST /auth/login, /auth/forgot-password/{email}, /auth/verify-code, /auth/reset-password  |
| `UserService`               | GET /usuarios/{id}, /usuarios/{id}/cursos, /usuarios/{id}/school; POST /usuarios/discente; PUT /usuarios/{id}; POST /usuarios/{id}/inscreverse/{courseId}; DELETE /usuarios/{id}/cursos/{courseId} |
| `CourseService`             | GET /cursos, /cursos/{id}, /cursos/instrutor/{id}                                          |
| `SectionService`            | GET /cursos/{courseId}/secoes                                                              |
| `ContentService`            | GET /cursos/{courseId}/secoes/{sectionId}/conteudos, /conteudos/{id}                       |
| `FeedbackService`           | GET /feedbacks/course/{courseId}; POST /feedbacks; PUT /feedbacks/{id}; DELETE /feedbacks/{id} |
| `UserProgressService`       | POST .../conteudos/{contentId}/discente/{userId}/progresso; GET /cursos/{courseId}/discente/{userId}/progresso |
| `SchoolService`             | GET /escolas                                                                               |
| `PasswordRecoveryService`   | POST /auth/forgot-password/{email}, /auth/verify-code, /auth/reset-password               |

### Tema e Identidade Visual

| Token          | Cor       | Uso                                    |
|----------------|-----------|----------------------------------------|
| Primary        | `#204B9E` | Cor principal (azul escuro)            |
| Secondary      | `#EEF2FF` | Fundos e superfícies secundárias       |
| Tertiary       | `#04213F` | Textos e elementos de destaque escuros |
| Button/Accent  | `#F59E0B` | Botões de ação e destaques âmbar       |
| Error          | `#C52222` | Mensagens de erro                      |
| Success        | `#22C55E` | Confirmações e sucesso                 |
| Input/Border   | `#64748B` | Bordas e campos de entrada             |

---

## Como Executar

### Pré-requisitos

- Flutter SDK 3.x e Dart SDK ^3.9.0
- Android SDK (para Android) ou Xcode (para iOS)
- Back-end INOVE em execução (Spring Boot — ver repositório `inove-api`)

### Verificar ambiente Flutter

```bash
flutter doctor
```

### Instalar dependências

```bash
flutter pub get
```

### Configuração da URL da API

Edite o arquivo `lib/core/utils/constants.dart` e defina o ambiente desejado:

```dart
// true = produção (Railway), false = local
static const bool isProduction = false;
```

### Executar em modo debug

```bash
# Listar dispositivos disponíveis
flutter devices

# Executar no dispositivo/emulador conectado
flutter run

# Executar em dispositivo específico
flutter run -d <device_id>
```

### Gerar APK para distribuição

```bash
# APK release
flutter build apk --release

# APK por ABI (menor tamanho)
flutter build apk --split-per-abi
```

### Gerar build iOS (requer macOS + Xcode)

```bash
flutter build ios --release
```

### Regenerar código de serialização JSON

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Regenerar ícones do launcher

```bash
dart run flutter_launcher_icons
```

### Exemplos de uso

- Login do discente
- Credenciais: e-mail cadastrado + senha (mínimo 6 caracteres com letras e números)
- Apenas usuários com role `STUDENT` têm acesso ao app mobile
- Token JWT retornado é armazenado localmente e enviado automaticamente em todas as requisições subsequentes
-------------------------------------------------------------
- Cadastro de discente
- Campos obrigatórios: nome, CPF (com validação de dígitos verificadores), e-mail, senha e data de nascimento
- Após cadastro, o usuário é redirecionado para a tela de login
-------------------------------------------------------------
- Matrícula em curso
- Acesse a tela de catálogo de cursos (`/cursos`), selecione um curso e clique em "Matricular-se"
- O curso aparecerá em "Meus Cursos" com o progresso iniciado em 0%
-------------------------------------------------------------
- Reprodução de conteúdo
- Dentro de um curso, selecione uma seção e um conteúdo; vídeos são reproduzidos com o player Chewie, PDFs são renderizados com flutter_pdfview
- Ao concluir o conteúdo, clique em "Marcar como concluído" para registrar o progresso
-------------------------------------------------------------
- Recuperação de senha
- Informe o e-mail cadastrado em `/esqueci-senha`
- Insira o código de 6 dígitos recebido por e-mail em `/verificar-codigo`
- Redefina a senha em `/redefinir-senha`

---

## Membros do Projeto

```
Diego Ribeiro Araújo
Flávio Diniz de Sousa
Ítalo Gonçalves Meireles Faria
João Gabriel de Oliveira Meireles
José Antonio Ribeiro Souto
Pedro Henrique Marques Rocha
```

Projeto Integrador IV - Bacharelado em Sistemas de Informação
Instituto Federal Goiano - Campus Urutaí
