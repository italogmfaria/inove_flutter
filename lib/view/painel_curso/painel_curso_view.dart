import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/background_decoration.dart';
import '../../widgets/video_player_widget.dart';
import '../../widgets/pdf_viewer_widget.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/theme_provider.dart';
import '../../viewmodel/painel_curso_viewmodel.dart';
import '../../services/api_service.dart';
import '../../services/course_service.dart';
import '../../services/section_service.dart';
import '../../services/content_service.dart';
import '../../services/feedback_service.dart';
import '../../model/course_model.dart';
import '../../model/content_model.dart';  // Para acessar ContentType enum

class PainelCursoView extends StatefulWidget {
  const PainelCursoView({super.key});

  @override
  State<PainelCursoView> createState() => _PainelCursoViewState();
}

class _PainelCursoViewState extends State<PainelCursoView> {
  late PainelCursoViewModel _viewModel;
  CursoModel? _curso;
  bool _initialized = false;

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _curso = ModalRoute.of(context)!.settings.arguments as CursoModel?;

      if (_curso?.id != null) {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final cursoService = CursoService(apiService);
        final sectionService = SectionService(apiService);
        final contentService = ContentService(apiService);
        final feedbackService = FeedbackService(apiService);

        _viewModel = PainelCursoViewModel(
          cursoService,
          sectionService,
          contentService,
          feedbackService,
        );
        // Não usar setCurso aqui, deixar loadCurso carregar tudo completo
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
          title: Consumer<PainelCursoViewModel>(
            builder: (context, viewModel, child) {
              final curso = viewModel.curso ?? _curso;
              return Text(
                curso?.name ?? 'Painel do Curso',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              );
            },
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
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
            const SizedBox(width: 3),
          ],
        ),
        body: BackgroundDecoration(
          child: Consumer<PainelCursoViewModel>(
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card com preview do conteúdo
                      _buildContentPreviewCard(curso, isDark),

                      const SizedBox(height: 16),

                      // Progress indicator
                      if (viewModel.sections.isNotEmpty)
                        _buildProgressIndicator(viewModel, isDark),

                      const SizedBox(height: 24),

                      // Conteúdo do Curso
                      Text(
                        'Conteúdo do Curso',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Lista de seções
                      ...viewModel.sections.asMap().entries.map((entry) {
                        return _buildSectionCard(entry.value, entry.key, viewModel, isDark);
                      }).toList(),

                      const SizedBox(height: 24),

                      // Informações do Curso
                      Text(
                        'Informações do Curso',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCourseInfoCard(curso, isDark),

                      const SizedBox(height: 24),

                      // Feedbacks
                      Text(
                        'Feedbacks',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Lista de Feedbacks (ordenados com usuário no topo)
                      FutureBuilder<List<dynamic>>(
                        future: viewModel.getOrderedFeedbacks(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return _buildEmptyComments(isDark);
                          }

                          final feedbacks = snapshot.data!;
                          if (feedbacks.isEmpty) {
                            return _buildEmptyComments(isDark);
                          }

                          return FutureBuilder<int?>(
                            future: _getUserId(),
                            builder: (context, userIdSnapshot) {
                              final userId = userIdSnapshot.data;
                              return Column(
                                children: feedbacks.map((feedback) {
                                  final isUserFeedback = userId != null &&
                                      feedback.student?.id == userId;
                                  return _buildCommentCard(
                                    feedback,
                                    isDark,
                                    isUserFeedback: isUserFeedback,
                                    viewModel: viewModel,
                                  );
                                }).toList(),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Botão de inserir comentário (só aparece se usuário não tem feedback)
                      FutureBuilder<bool>(
                        future: viewModel.userHasFeedback(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data == true) {
                            return const SizedBox.shrink();
                          }
                          return _buildAddCommentButton(viewModel, isDark);
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContentPreviewCard(CursoModel curso, bool isDark) {
    return Consumer<PainelCursoViewModel>(
      builder: (context, viewModel, child) {
        final currentContent = viewModel.currentContent;
        final hasContent = currentContent != null;


        return Column(
          children: [
            // Container do conteúdo
            Container(
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
                children: [
                  // Área do vídeo/conteúdo
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.backgroundColor.withAlpha(50)
                          : AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: hasContent
                          ? _buildContentPlayer(currentContent, isDark)
                          : _buildEmptyState(isDark),
                    ),
                  ),
                ],
              ),
            ),

            // Botões de navegação abaixo do container
            if (hasContent) ...[
              const SizedBox(height: 16),
              _buildNavigationButtons(viewModel, isDark),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNavigationButtons(PainelCursoViewModel viewModel, bool isDark) {
    final hasPrevious = viewModel.currentSectionIndex != null &&
        (viewModel.currentContentIndex! > 0 || viewModel.currentSectionIndex! > 0);

    bool hasNext = false;
    if (viewModel.currentSectionIndex != null && viewModel.currentContentIndex != null) {
      final currentSection = viewModel.sections[viewModel.currentSectionIndex!];
      hasNext = viewModel.currentContentIndex! < currentSection.contents.length - 1 ||
          viewModel.currentSectionIndex! < viewModel.sections.length - 1;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Botão Anterior
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: hasPrevious ? () => viewModel.previousContent() : null,
              icon: Icon(
                Icons.arrow_back_ios,
                size: 18,
                color: hasPrevious ? Colors.white : (isDark ? Colors.white.withAlpha(50) : AppColors.inputColor.withAlpha(100)),
              ),
              label: Text(
                'Anterior',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasPrevious ? Colors.white : (isDark ? Colors.white.withAlpha(50) : AppColors.inputColor.withAlpha(100)),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasPrevious
                    ? AppColors.primaryButton
                    : (isDark ? AppColors.inputColor.withAlpha(30) : AppColors.borderColor.withAlpha(100)),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Botão Próximo
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: hasNext ? () => viewModel.nextContent() : null,
              label: Text(
                'Próximo',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasNext ? Colors.white : (isDark ? Colors.white.withAlpha(50) : AppColors.inputColor.withAlpha(100)),
                ),
              ),
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: hasNext ? Colors.white : (isDark ? Colors.white.withAlpha(50) : AppColors.inputColor.withAlpha(100)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasNext
                    ? AppColors.primaryButton
                    : (isDark ? AppColors.inputColor.withAlpha(30) : AppColors.borderColor.withAlpha(100)),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentPlayer(ContentModel content, bool isDark) {
    // Validar se fileUrl não está vazio
    if (content.fileUrl.isEmpty) {
      return _buildUrlMissingError(isDark, content);
    }

    if (content.contentType == ContentType.VIDEO) {
      return VideoPlayerWidget(videoUrl: content.fileUrl);
    } else if (content.contentType == ContentType.PDF) {
      return PdfViewerWidget(
        pdfUrl: content.fileUrl,
        fileName: content.fileName,
      );
    } else {
      return _buildUnsupportedContent(isDark);
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryButton,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Conteúdo do curso',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Selecione um conteúdo',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withAlpha(150)
                  : AppColors.inputColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedContent(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 64,
            color: isDark ? Colors.white.withAlpha(150) : AppColors.inputColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Tipo de conteúdo não suportado',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? Colors.white : AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlMissingError(bool isDark, ContentModel content) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link_off,
              size: 48,
              color: isDark ? Colors.orange.shade300 : Colors.orange,
            ),
            const SizedBox(height: 12),
            Text(
              'URL do arquivo não disponível',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'O conteúdo "${content.title}" não possui um arquivo associado.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? Colors.white.withAlpha(150) : AppColors.inputColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.orange.withAlpha(30)
                    : Colors.orange.withAlpha(50),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.orange.shade300 : Colors.orange,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Detalhes do conteúdo:',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Tipo: ${content.contentType}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark ? Colors.white.withAlpha(200) : Colors.black87,
                    ),
                  ),
                  Text(
                    'Arquivo: ${content.fileName.isEmpty ? "Não informado" : content.fileName}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark ? Colors.white.withAlpha(200) : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(dynamic section, int index, PainelCursoViewModel viewModel, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            section.title ?? 'Seção ${index + 1}',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textColor,
            ),
          ),
          iconColor: isDark ? Colors.white : AppColors.textColor,
          collapsedIconColor: isDark ? Colors.white : AppColors.textColor,
          children: [
            ...section.contents.asMap().entries.map((contentEntry) {
              return _buildContentItem(
                contentEntry.value,
                contentEntry.key,
                index,
                viewModel,
                isDark,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildContentItem(dynamic content, int contentIndex, int sectionIndex, PainelCursoViewModel viewModel, bool isDark) {
    final isSelected = viewModel.currentSectionIndex == sectionIndex &&
                       viewModel.currentContentIndex == contentIndex;

    IconData getContentIcon() {
      // Comparar diretamente com o enum ContentType

      if (content.contentType == ContentType.VIDEO) {
        return Icons.play_circle_outline;
      } else if (content.contentType == ContentType.PDF) {
        return Icons.description_outlined;
      }
      return Icons.article_outlined;
    }

    return InkWell(
      onTap: () {
        viewModel.setCurrentContent(sectionIndex, contentIndex);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryButton.withAlpha(30) : AppColors.primaryButton.withAlpha(20))
              : Colors.transparent,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.inputColor.withAlpha(30)
                  : AppColors.borderColor.withAlpha(50),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Ícone de status/play
            Icon(
              isSelected ? Icons.play_arrow : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppColors.primaryButton
                  : (isDark ? Colors.white.withAlpha(100) : AppColors.inputColor),
              size: 20,
            ),
            const SizedBox(width: 12),

            // Título do conteúdo
            Expanded(
              child: Text(
                content.title ?? 'Aula ${contentIndex + 1}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primaryButton
                      : (isDark ? Colors.white.withAlpha(200) : AppColors.textColor),
                ),
              ),
            ),

            // Ícone do tipo de conteúdo
            Icon(
              getContentIcon(),
              color: isSelected
                  ? AppColors.primaryButton
                  : (isDark ? Colors.white.withAlpha(150) : AppColors.inputColor),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseInfoCard(CursoModel curso, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Instrutor',
            value: curso.instructors.isNotEmpty
                ? curso.instructors.first.name
                : 'Não informado',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Data de criação',
            value: _formatDate(curso.creationDate),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.schedule_outlined,
            label: 'Última atualização',
            value: _formatDate(curso.lastUpdateDate),
            isDark: isDark,
          ),
        ],
      ),
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

  Widget _buildEmptyComments(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
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
    );
  }

  Widget _buildCommentCard(
    dynamic feedback,
    bool isDark, {
    bool isUserFeedback = false,
    PainelCursoViewModel? viewModel,
  }) {
    final userName = feedback.student?.name ?? 'Usuário';
    final comment = feedback.comment ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isUserFeedback
            ? Border.all(color: AppColors.primaryButton, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          if (isUserFeedback) ...[
            const SizedBox(width: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botão Editar
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 24,
                    color: isDark ? Colors.white : AppColors.primaryButton,
                  ),
                  onPressed: () => _showEditCommentDialog(
                    viewModel!,
                    feedback,
                    isDark,
                  ),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  tooltip: 'Editar',
                ),
                const SizedBox(width: 6),
                // Botão Deletar
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 24,
                    color: isDark ? Colors.red.shade300 : Colors.red,
                  ),
                  onPressed: () => _showDeleteCommentDialog(
                    viewModel!,
                    feedback,
                    isDark,
                  ),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  tooltip: 'Excluir',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddCommentButton(PainelCursoViewModel viewModel, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _showAddCommentDialog(viewModel, isDark),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFA500),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Inserir comentário',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(PainelCursoViewModel viewModel, bool isDark) {
    // Calculate total contents
    int totalContents = 0;
    for (var section in viewModel.sections) {
      totalContents += section.contents.length;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso do Curso',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textColor,
                ),
              ),
              Text(
                '${(viewModel.progress * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryButton,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: viewModel.progress,
              backgroundColor: isDark
                  ? AppColors.inputColor.withAlpha(30)
                  : AppColors.borderColor.withAlpha(100),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryButton),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total de aulas: $totalContents',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark
                  ? Colors.white.withAlpha(150)
                  : AppColors.inputColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCommentDialog(PainelCursoViewModel viewModel, bool isDark) {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.primaryColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          title: Text(
            'Adicionar Comentário',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textColor,
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              controller: commentController,
              maxLines: 6,
              style: GoogleFonts.inter(
                color: isDark ? Colors.white : AppColors.textColor,
              ),
              decoration: InputDecoration(
                hintText: 'Digite seu comentário...',
                hintStyle: GoogleFonts.inter(
                  color: isDark
                      ? Colors.white.withAlpha(100)
                      : AppColors.inputColor,
                ),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.inputColor.withAlpha(50)
                        : AppColors.borderColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.inputColor.withAlpha(50)
                        : AppColors.borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryButton,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white.withAlpha(150) : AppColors.inputColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.isNotEmpty) {
                  final success = await viewModel.submitFeedback(context, commentController.text);
                  if (success) {
                    Navigator.of(context).pop();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Enviar',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditCommentDialog(
    PainelCursoViewModel viewModel,
    dynamic feedback,
    bool isDark,
  ) {
    final TextEditingController commentController = TextEditingController(
      text: feedback.comment ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.primaryColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          title: Text(
            'Editar Comentário',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textColor,
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              controller: commentController,
              maxLines: 6,
              autofocus: true,
              style: GoogleFonts.inter(
                color: isDark ? Colors.white : AppColors.textColor,
              ),
              decoration: InputDecoration(
                hintText: 'Digite seu comentário...',
                hintStyle: GoogleFonts.inter(
                  color: isDark
                      ? Colors.white.withAlpha(100)
                      : AppColors.inputColor,
                ),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.inputColor.withAlpha(50)
                        : AppColors.borderColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.inputColor.withAlpha(50)
                        : AppColors.borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryButton,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white.withAlpha(150) : AppColors.inputColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.isNotEmpty) {
                  final success = await viewModel.updateFeedback(
                    context,
                    feedback.id!,
                    commentController.text,
                  );
                  if (success) {
                    Navigator.of(context).pop();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Salvar',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCommentDialog(
    PainelCursoViewModel viewModel,
    dynamic feedback,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.primaryColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Remover Comentário',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textColor,
            ),
          ),
          content: Text(
            'Tem certeza que deseja remover seu comentário?',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? Colors.white.withAlpha(200) : AppColors.textColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white.withAlpha(150) : AppColors.inputColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await viewModel.deleteFeedback(
                  context,
                  feedback.id!,
                );
                if (success) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.red.shade400 : Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Remover',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
