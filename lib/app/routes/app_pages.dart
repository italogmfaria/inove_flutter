import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_routes.dart';

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

class AppPages {
  static Map<String, WidgetBuilder> get routes {
    return {
      AppRoutes.index: (context) => ChangeNotifierProvider(
            create: (_) => IndexViewModel(),
            child: const IndexView(),
          ),
      AppRoutes.inicial: (context) => ChangeNotifierProvider(
            create: (_) => InicialViewModel(),
            child: const InicialView(),
          ),
      AppRoutes.login: (context) => ChangeNotifierProvider(
            create: (_) => LoginViewModel(),
            child: const LoginView(),
          ),
      AppRoutes.cadastro: (context) => ChangeNotifierProvider(
            create: (_) => CadastroViewModel(),
            child: const CadastroView(),
          ),
      AppRoutes.cadastroEscola: (context) => ChangeNotifierProvider(
            create: (_) => CadastroEscolaViewModel(),
            child: const CadastroEscolaView(),
          ),
      AppRoutes.esqueciSenha: (context) => ChangeNotifierProvider(
            create: (_) => EsqueciSenhaViewModel(),
            child: const EsqueciSenhaView(),
          ),
      AppRoutes.verificarCodigo: (context) => ChangeNotifierProvider(
            create: (_) => VerificarCodigoViewModel(),
            child: const VerificarCodigoView(),
          ),
      AppRoutes.redefinirSenha: (context) => ChangeNotifierProvider(
            create: (_) => RedefinirSenhaViewModel(),
            child: const RedefinirSenhaView(),
          ),
      AppRoutes.cursos: (context) => ChangeNotifierProvider(
            create: (_) => CursosViewModel(),
            child: const CursosView(),
          ),
      AppRoutes.meusCursos: (context) => ChangeNotifierProvider(
            create: (_) => MeusCursosViewModel(),
            child: const MeusCursosView(),
          ),
      AppRoutes.perfil: (context) => ChangeNotifierProvider(
            create: (_) => PerfilViewModel(),
            child: const PerfilView(),
          ),
      AppRoutes.previewCurso: (context) => ChangeNotifierProvider(
            create: (_) => PreviewCursoViewModel(),
            child: const PreviewCursoView(),
          ),
      AppRoutes.painelCurso: (context) => ChangeNotifierProvider(
            create: (_) => PainelCursoViewModel(),
            child: const PainelCursoView(),
          ),
    };
  }

  static String get initialRoute => AppRoutes.index;
}

