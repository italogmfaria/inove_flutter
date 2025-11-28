# INOVE

## Inovação Online para Vivências Educacionais

#### Logo do Projeto

![](assets/logo_colored.png)

#### Contextualização

No cenário educacional atual, a utilização de ferramentas de ensino e metodologias inovadoras tem se mostrado cada vez mais essencial para promover uma experiência de aprendizado efetiva e engajadora. Este projeto surge da necessidade de acompanhar o avanço tecnológico e inovar no processo de ensino.

#### Objetivo do Projeto

O objetivo do projeto INOVE é desenvolver uma aplicação mobile educacional voltada especificamente para professores e alunos, proporcionando ferramentas inovadoras e metodologias pedagógicas mais ativas e personalizadas, complementando a plataforma web.

#### Resultados esperados

1. **Capacitação de Professores**  
   - Os professores participantes serão formados para utilizar ferramentas de ensino e metodologias inovadoras, ampliando suas competências pedagógicas. Como resultado, espera-se que se sintam mais preparados e motivados a adotar práticas mais criativas e eficientes em suas aulas, promovendo um ambiente de ensino mais dinâmico e atualizado.

2. **Melhoria da Experiência de Ensino e Aprendizagem**  
   - Com a aplicação das ferramentas inovadoras em sala de aula, projeta-se uma transformação na forma como alunos e professores interagem. Os alunos terão uma participação mais ativa e colaborativa, facilitando uma aprendizagem mais significativa e duradoura, ao mesmo tempo em que se promove um clima de motivação e engajamento.

3. **Avaliação da Efetividade das Metodologias**  
   - O projeto inclui uma avaliação contínua das ferramentas implementadas, visando medir sua contribuição para o processo de ensino-aprendizagem. Esta análise permitirá identificar práticas pedagógicas mais eficazes e fornecerá subsídios para a melhoria contínua da aplicação e do projeto como um todo.

4. **Democratização e Inclusão Digital**  
   - A aplicação mobile será disponibilizada gratuitamente, garantindo amplo acesso a recursos educacionais de alta qualidade em qualquer lugar e momento. Dessa forma, espera-se promover a inclusão digital e educacional, ampliando as oportunidades de aprendizado para diferentes públicos e fortalecendo a democratização da educação.

5. **Disseminação dos Resultados**  
   - Os resultados obtidos ao longo do projeto serão compartilhados com a comunidade acadêmica e educacional, por meio de relatórios, publicações e eventos. Essa disseminação visa ampliar o impacto do projeto, incentivando outras instituições a adotarem práticas semelhantes e reforçando o compromisso com a inovação no ensino.

#### Nome dos Membros do Projeto

```bash
Flávio Diniz de Sousa
Italo Gonçalves Meireles Faria
João Gabriel de Oliveira Meireles
José Antonio Ribeiro Souto
Pedro Henrique Marques
```

#### Instruções de Uso do Projeto

#### Para executar a Aplicação Mobile INOVE, siga estas etapas:

1. **Configuração do Ambiente Flutter:**

   - Certifique-se de que você tem o **Flutter SDK** e **Dart SDK** instalados em sua máquina. Para verificar, use os seguintes comandos:
     ```bash
     flutter --version
     dart --version
     ```

   - Se não tiver Flutter instalado, acesse [flutter.dev](https://flutter.dev/docs/get-started/install) e siga as instruções de instalação para seu sistema operacional.

2. **Configuração do Backend API:**

   - Verifique se o backend (Spring Boot) está rodando corretamente, conforme as instruções do projeto backend.
   - Certifique-se de que a API está rodando no endereço correto (exemplo: `http://localhost:8080`), que será utilizada pela aplicação Flutter para fazer requisições.
   - Anote a URL da API, pois será necessária para configurar a aplicação.

3. **Instalar Dependências do Projeto:**

   - Navegue para o diretório do projeto Flutter e instale as dependências necessárias executando o comando abaixo:
     ```bash
     flutter pub get
     ```

4. **Configuração de Variáveis de Ambiente:**

   - Configure a URL da API no arquivo de constantes ou variáveis de ambiente. Geralmente isso é feito em um arquivo como `lib/config/constants.dart` ou similar:
     ```dart
     const String API_BASE_URL = 'http://localhost:8080/api';
     ```

5. **Executar a Aplicação:**

   - Para executar a aplicação em um emulador ou dispositivo físico, use o seguinte comando:
     ```bash
     flutter run
     ```

   - Alternativamente, se desejar compilar um APK para distribuição:
     ```bash
     flutter build apk --release
     ```

   - Ou para compilar para iOS (em máquina com macOS):
     ```bash
     flutter build ios --release
     ```

6. **Conectar a um Dispositivo (Opcional):**

   - Para rodar em um dispositivo físico Android:
     ```bash
     flutter devices  # lista dispositivos conectados
     flutter run -d <device_id>
     ```

7. **Testar Funcionalidades:**

   - Após iniciar a aplicação, você poderá testar as operações de login, visualização de cursos, envio de atividades e outras funcionalidades que integram com o backend.
   - Para cada operação que a aplicação faz, ela irá se comunicar com o backend através das rotas configuradas na API.

#### Estrutura do Projeto

O projeto Flutter segue a seguinte estrutura de diretórios:

```
lib/
├── config/          # Configurações gerais
├── models/          # Modelos de dados
├── screens/         # Telas da aplicação
├── services/        # Serviços de API
├── widgets/         # Componentes reutilizáveis
└── main.dart        # Arquivo principal
```

#### Tecnologias Utilizadas

- **Flutter**: Framework para desenvolvimento mobile
- **Dart**: Linguagem de programação
- **HTTP**: Cliente para requisições REST
- **Provider/GetX**: Gerenciamento de estado (conforme configurado)
- **API REST**: Integração com backend Spring Boot

#### Recursos Adicionais

- [Documentação oficial do Flutter](https://docs.flutter.dev/)
- [Documentação oficial do Dart](https://dart.dev/guides)
- [Cookbook Flutter](https://docs.flutter.dev/cookbook)

Para mais informações ou dúvidas sobre o projeto, entre em contato com os membros da equipe.
