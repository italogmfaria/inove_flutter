import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_routes.dart';
import '../guards/auth_guard.dart';
import '../guards/guarded_route.dart';

// Views
import '../../view/index/index_view.dart';
import '../../view/inicial/inicial_view.dart';
import '../../view/login/login_view.dart';
import '../../view/cadastro/cadastro_view.dart';
import '../../view/cadastro_escola/cadastro_escola_view.dart';
import '../../view/esqueci_senha/esqueci_senha_view.dart';
import '../../view/verificar_codigo/verificar_codigo_view.dart';
import '../../view/redefinir_senha/redefinir_senha_view.dart';
import '../../view/cursos/cursos_view.dart';
import '../../view/meus_cursos/meus_cursos_view.dart';
import '../../view/perfil/perfil_view.dart';
import '../../view/preview_curso/preview_curso_view.dart';
import '../../view/painel_curso/painel_curso_view.dart';

// ViewModels
import '../../viewmodel/index_viewmodel.dart';
import '../../viewmodel/inicial_viewmodel.dart';
import '../../viewmodel/login_viewmodel.dart';
import '../../viewmodel/cadastro_viewmodel.dart';
import '../../viewmodel/cadastro_escola_viewmodel.dart';
import '../../viewmodel/esqueci_senha_viewmodel.dart';
import '../../viewmodel/verificar_codigo_viewmodel.dart';
import '../../viewmodel/redefinir_senha_viewmodel.dart';
import '../../viewmodel/cursos_viewmodel.dart';
import '../../viewmodel/meus_cursos_viewmodel.dart';
import '../../viewmodel/perfil_viewmodel.dart';
import '../../viewmodel/preview_curso_viewmodel.dart';
import '../../viewmodel/painel_curso_viewmodel.dart';

// Services
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/course_service.dart';
import '../../services/school_service.dart';
import '../../services/section_service.dart';
import '../../services/content_service.dart';
import '../../services/feedback_service.dart';
import '../../services/password_recovery_service.dart';

class AppPages {
  // Inicializar services (singleton-like)
  static final ApiService _apiService = ApiService();
  static final AuthService _authService = AuthService(_apiService);
  static final UserService _userService = UserService(_apiService);
  static final CursoService _cursoService = CursoService(_apiService);
  static final SchoolService _schoolService = SchoolService(_apiService);
  static final SectionService _sectionService = SectionService(_apiService);
  static final ContentService _contentService = ContentService(_apiService);
  static final FeedbackService _feedbackService = FeedbackService(_apiService);
  static final PasswordRecoveryService _passwordRecoveryService = PasswordRecoveryService(_apiService);

  static Map<String, WidgetBuilder> get routes {
    return {

      // ====== ROTAS PÚBLICAS ======
      AppRoutes.index: (context) => GuardedRoute(
            guardType: RouteGuardType.public,
            child: ChangeNotifierProvider(
              create: (_) => IndexViewModel(_authService),
              child: const IndexView(),
            ),
          ),
      AppRoutes.cursos: (context) => GuardedRoute(
            guardType: RouteGuardType.public,
            child: ChangeNotifierProvider(
              create: (_) => CursosViewModel(_cursoService),
              child: const CursosView(),
            ),
          ),
      AppRoutes.previewCurso: (context) => GuardedRoute(
            guardType: RouteGuardType.public,
            child: ChangeNotifierProvider(
              create: (_) => PreviewCursoViewModel(_cursoService, _feedbackService),
              child: const PreviewCursoView(),
            ),
          ),



      // ====== ROTAS APENAS PARA NÃO LOGADOS ======
      AppRoutes.inicial: (context) => GuardedRoute(
            guardType: RouteGuardType.onlyGuest,
            child: ChangeNotifierProvider(
              create: (_) => InicialViewModel(),
              child: const InicialView(),
            ),
          ),
      AppRoutes.login: (context) => GuardedRoute(
            guardType: RouteGuardType.onlyGuest,
            child: ChangeNotifierProvider(
              create: (_) => LoginViewModel(_authService),
              child: const LoginView(),
            ),
          ),
      AppRoutes.cadastro: (context) => GuardedRoute(
            guardType: RouteGuardType.onlyGuest,
            child: ChangeNotifierProvider(
              create: (_) => CadastroViewModel(_userService, _schoolService),
              child: const CadastroView(),
            ),
          ),
      AppRoutes.cadastroEscola: (context) => GuardedRoute(
            guardType: RouteGuardType.onlyGuest,
            child: ChangeNotifierProvider(
              create: (_) => CadastroEscolaViewModel(_schoolService),
              child: const CadastroEscolaView(),
            ),
          ),
      AppRoutes.esqueciSenha: (context) => GuardedRoute(
            guardType: RouteGuardType.onlyGuest,
            child: ChangeNotifierProvider(
              create: (_) => EsqueciSenhaViewModel(_passwordRecoveryService),
              child: const EsqueciSenhaView(),
            ),
          ),
      AppRoutes.verificarCodigo: (context) => GuardedRoute(
            guardType: RouteGuardType.onlyGuest,
            child: ChangeNotifierProvider(
              create: (_) => VerificarCodigoViewModel(_passwordRecoveryService),
              child: const VerificarCodigoView(),
            ),
          ),
      AppRoutes.redefinirSenha: (context) => GuardedRoute(
            guardType: RouteGuardType.onlyGuest,
            child: ChangeNotifierProvider(
              create: (_) => RedefinirSenhaViewModel(_passwordRecoveryService),
              child: const RedefinirSenhaView(),
            ),
          ),


      // ====== ROTAS APENAS PARA LOGADOS ======
      AppRoutes.meusCursos: (context) => GuardedRoute(
            guardType: RouteGuardType.onlyAuth,
            child: ChangeNotifierProvider(
              create: (_) => MeusCursosViewModel(_userService),
              child: const MeusCursosView(),
            ),
          ),
      AppRoutes.perfil: (context) => GuardedRoute(
            guardType: RouteGuardType.onlyAuth,
            child: ChangeNotifierProvider(
              create: (_) => PerfilViewModel(_userService, _schoolService, _authService),
              child: const PerfilView(),
            ),
          ),
      AppRoutes.painelCurso: (context) => GuardedRoute(
            guardType: RouteGuardType.onlyAuth,
            child: ChangeNotifierProvider(
              create: (_) => PainelCursoViewModel(
                _cursoService,
                _sectionService,
                _contentService,
                _feedbackService,
              ),
              child: const PainelCursoView(),
            ),
          ),
    };
  }

  static String get initialRoute => AppRoutes.index;
}
