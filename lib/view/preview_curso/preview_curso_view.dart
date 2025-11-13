import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/theme_provider.dart';
import '../../services/api_service.dart';
import '../../services/course_service.dart';
import '../../services/user_service.dart';
import '../../services/file_service.dart';
import '../../viewmodel/preview_curso_viewmodel.dart';
import '../../model/course_model.dart';
import '../../widgets/background_decoration.dart';

class PreviewCursoView extends StatefulWidget {
  const PreviewCursoView({super.key});

  @override
  State<PreviewCursoView> createState() => _PreviewCursoViewState();
}

class _PreviewCursoViewState extends State<PreviewCursoView> {
  late PreviewCursoViewModel _viewModel;
  CursoModel? _curso;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _curso = ModalRoute.of(context)!.settings.arguments as CursoModel?;

      if (_curso?.id != null) {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final cursoService = CursoService(apiService);
        final userService = UserService(apiService);
        _viewModel = PreviewCursoViewModel(cursoService, userService);
        _viewModel.loadCurso(_curso!.id!, context: context);
      }
      _initialized = true;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Data não disponível';
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
        'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
      ];
      return '${date.day} de ${months[date.month - 1]} de ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_curso?.id == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.tertiaryColor : AppColors.backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Erro',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: BackgroundDecoration(
          child: Center(
            child: Text(
              'Curso não encontrado',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: isDark ? Colors.white : AppColors.textColor,
              ),
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.tertiaryColor : AppColors.backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            _curso?.name ?? 'Nome do Curso',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await themeProvider.toggleTheme();
                  },
                );
              },
            ),
            const SizedBox(width: 3),
          ],
        ),
        body: BackgroundDecoration(
          child: Consumer<PreviewCursoViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.primaryButton : AppColors.primaryColor,
                    ),
                  ),
                );
              }

              final curso = viewModel.curso ?? _curso!;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Imagem do curso (largura completa)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildCourseImage(context, curso, isDark),
                    ),

                    const SizedBox(height: 20),

                    // Container principal com conteúdo
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 30 : 10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sobre o curso
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sobre o curso',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : AppColors.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    curso.description,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white.withAlpha(200)
                                          : AppColors.inputColor,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Informações do instrutor e datas
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.tertiaryColor.withAlpha(50)
                                      : AppColors.backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.inputColor.withAlpha(30)
                                        : AppColors.borderColor.withAlpha(50),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Instrutor
                                    _buildInfoRow(
                                      icon: Icons.person_outline,
                                      label: 'Instrutor',
                                      value: curso.instructors.isNotEmpty
                                          ? curso.instructors.first.name
                                          : 'Não informado',
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 16),

                                    // Data de criação
                                    _buildInfoRow(
                                      icon: Icons.calendar_today_outlined,
                                      label: 'Data de criação',
                                      value: _formatDate(curso.creationDate),
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 16),

                                    // Última atualização
                                    _buildInfoRow(
                                      icon: Icons.schedule_outlined,
                                      label: 'Última atualização',
                                      value: _formatDate(curso.lastUpdateDate),
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Botão de inscrever-se
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: _buildEnrollButton(viewModel, isDark),
                            ),

                            // Feedbacks
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Feedbacks',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : AppColors.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Lista de Feedbacks
                                  if (curso.feedBacks.isEmpty)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Text(
                                          'Nenhum comentário ainda',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: isDark
                                                ? Colors.white.withAlpha(150)
                                                : AppColors.inputColor,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    ...curso.feedBacks.map((feedback) {
                                      return _buildCommentCard(feedback, isDark);
                                    }).toList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCourseImage(BuildContext context, CursoModel curso, bool isDark) {
    return FutureBuilder<String?>(
      future: curso.id != null
          ? FileService(Provider.of<ApiService>(context, listen: false))
              .getCourseImageUrl(curso.id!)
          : Future.value(null),
      builder: (context, snapshot) {
        return Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: isDark ? AppColors.primaryColor : AppColors.primaryButton,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 30 : 10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? AppColors.primaryButton : Colors.white,
                      ),
                      strokeWidth: 3,
                    ),
                  )
                : snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty
                    ? Image.network(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  color: Colors.white,
                                  size: 64,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Imagem do curso',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              color: Colors.white,
                              size: 64,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Imagem do curso',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark
              ? Colors.white.withAlpha(180)
              : AppColors.inputColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark
                      ? Colors.white.withAlpha(150)
                      : AppColors.inputColor.withAlpha(180),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnrollButton(PreviewCursoViewModel viewModel, bool isDark) {
    if (viewModel.isEnrolled) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.green.withAlpha(30)
                  : Colors.green.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Você já está inscrito',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => viewModel.navigateToCursoPainel(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Acessar Curso',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: viewModel.isEnrolling
            ? null
            : () => viewModel.enrollInCourse(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primaryButton.withAlpha(150),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: viewModel.isEnrolling
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Inscrever-se',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildCommentCard(dynamic feedback, bool isDark) {
    final userName = feedback.student?.name ?? 'Usuário';
    final comment = feedback.comment ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.tertiaryColor.withAlpha(50)
            : AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.inputColor.withAlpha(30)
              : AppColors.borderColor.withAlpha(50),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Nome e comentário
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withAlpha(200)
                        : AppColors.inputColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

