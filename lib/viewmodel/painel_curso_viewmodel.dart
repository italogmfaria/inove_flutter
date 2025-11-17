import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/course_model.dart';
import '../model/section_model.dart';
import '../model/content_model.dart';
import '../services/course_service.dart';
import '../services/section_service.dart';
import '../services/content_service.dart';
import '../services/feedback_service.dart';
import '../services/user_progress_service.dart';
import '../core/utils/helpers.dart';
import 'package:inove_flutter/core/utils/profanity_list.dart';

class PainelCursoViewModel extends ChangeNotifier {
  final CursoService _cursoService;
  final SectionService _sectionService;
  final ContentService _contentService;
  final FeedbackService _feedbackService;
  final UserProgressService _userProgressService;

  CursoModel? _curso;
  List<SectionModel> _sections = [];
  int? _currentSectionIndex;
  int? _currentContentIndex;
  ContentModel? _currentContent;
  double _progress = 0.0;
  bool _isLoading = false;
  String? _errorMessage;
  String _feedbackComment = '';
  bool _isSubmittingFeedback = false;
  Set<int> _completedContentIds = {};
  double _courseProgress = 0.0;
  bool _hasMarkedCurrentContentComplete = false;
  int _totalContents = 0;
  late Set<String> _profanityList;

  PainelCursoViewModel(
    this._cursoService,
    this._sectionService,
    this._contentService,
    this._feedbackService,
    this._userProgressService,
  ) {
    // Inicializar lista de profanidades
    _profanityList = ProfanityList.getProfanityWords();
  }

  CursoModel? get curso => _curso;
  List<SectionModel> get sections => _sections;
  int? get currentSectionIndex => _currentSectionIndex;
  int? get currentContentIndex => _currentContentIndex;
  ContentModel? get currentContent => _currentContent;
  double get progress => _progress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get feedbackComment => _feedbackComment;
  bool get isSubmittingFeedback => _isSubmittingFeedback;
  Set<int> get completedContentIds => _completedContentIds;
  double get courseProgress => _courseProgress;
  int get totalContents => _totalContents;

  bool isContentCompleted(int contentId) {
    return _completedContentIds.contains(contentId);
  }

  void setCurso(CursoModel curso) {
    _curso = curso;
    // Ordenar seções por ID
    _sections = List.from(curso.sections)
      ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    notifyListeners();
  }

  Future<void> loadCurso(int cursoId, {BuildContext? context, bool navigateToUncompleted = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _curso = await _cursoService.getCursoById(cursoId);

      // Usar as seções que já vêm com o curso
      if (_curso != null && _curso!.sections.isNotEmpty) {
        // Ordenar seções por ID
        _sections = List.from(_curso!.sections)
          ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));

        // Carregar conteúdos para cada seção
        await _loadContentsForAllSections(cursoId);

        _calculateProgress();

        // Carregar progresso do usuário primeiro
        await loadUserProgress();

        // Navegar para o primeiro conteúdo não concluído ou auto-selecionar primeiro conteúdo
        if (navigateToUncompleted) {
          navigateToFirstUncompletedContent();
        } else if (_sections.isNotEmpty && _sections[0].contents.isNotEmpty) {
          setCurrentContent(0, 0);
        }
      } else {
        // Fallback: tentar carregar seções separadamente
        await loadSections(cursoId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar curso: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      if (context != null) {
        Helpers.showError(context, _errorMessage!);
      }
    }
  }

  /// Carrega conteúdos para todas as seções
  Future<void> _loadContentsForAllSections(int cursoId) async {
    for (int i = 0; i < _sections.length; i++) {
      final section = _sections[i];
      if (section.id != null) {
        try {
          final contents = await _contentService.getContents(cursoId, section.id!);

          // Ordenar conteúdos por ID
          final sortedContents = List<ContentModel>.from(contents)
            ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));

          // Atualizar a seção com os conteúdos carregados e ordenados
          _sections[i] = section.copyWith(contents: sortedContents);
        } catch (e) {
          // Continuar com outras seções mesmo se uma falhar
        }
      }
    }

    // Atualizar o curso com as seções completas
    if (_curso != null) {
      _curso = _curso!.copyWith(sections: _sections);
    }
  }

  Future<void> loadSections(int cursoId) async {
    try {
      final sections = await _sectionService.getSections(cursoId);

      // Ordenar seções por ID
      _sections = List.from(sections)
        ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));

      // Carregar conteúdos para cada seção
      await _loadContentsForAllSections(cursoId);

      _calculateProgress();

      // Carregar progresso do usuário
      await loadUserProgress();

      // Navegar para o primeiro conteúdo não concluído
      navigateToFirstUncompletedContent();

      notifyListeners();
    } catch (e) {
      // Silently fail
    }
  }

  void setCurrentSection(int sectionIndex) {
    _currentSectionIndex = sectionIndex;
    _currentContentIndex = null;
    _currentContent = null;
    notifyListeners();
  }

  void setCurrentContent(int sectionIndex, int contentIndex) async {
    _currentSectionIndex = sectionIndex;
    _currentContentIndex = contentIndex;

    if (_sections.isNotEmpty &&
        sectionIndex < _sections.length &&
        _sections[sectionIndex].contents.isNotEmpty &&
        contentIndex < _sections[sectionIndex].contents.length) {
      _currentContent = _sections[sectionIndex].contents[contentIndex];

      // Reset the completion flag for the new content
      _hasMarkedCurrentContentComplete = _completedContentIds.contains(_currentContent!.id);

      notifyListeners();
    }
  }

  void nextContent() {
    if (_currentSectionIndex == null || _currentContentIndex == null) return;

    final currentSection = _sections[_currentSectionIndex!];

    if (_currentContentIndex! < currentSection.contents.length - 1) {
      setCurrentContent(_currentSectionIndex!, _currentContentIndex! + 1);
    }
    else if (_currentSectionIndex! < _sections.length - 1) {
      setCurrentContent(_currentSectionIndex! + 1, 0);
    }
  }

  void previousContent() {
    if (_currentSectionIndex == null || _currentContentIndex == null) return;

    if (_currentContentIndex! > 0) {
      setCurrentContent(_currentSectionIndex!, _currentContentIndex! - 1);
    }
    else if (_currentSectionIndex! > 0) {
      final previousSection = _sections[_currentSectionIndex! - 1];
      if (previousSection.contents.isNotEmpty) {
        setCurrentContent(_currentSectionIndex! - 1, previousSection.contents.length - 1);
      }
    }
  }

  void _calculateProgress() {
    if (_sections.isEmpty) {
      _progress = 0.0;
      _totalContents = 0;
      return;
    }

    int totalContents = 0;
    int completedContents = 0;

    for (var section in _sections) {
      totalContents += section.contents.length;
    }

    _totalContents = totalContents;

    if (totalContents > 0) {
      _progress = completedContents / totalContents;
    } else {
      _progress = 0.0;
    }
  }

  void setFeedbackComment(String comment) {
    _feedbackComment = comment;
    notifyListeners();
  }

  String? validateFeedback(String? value) {
    // Verifica se o comentário está vazio
    if (value == null || value.trim().isEmpty) {
      return 'O comentário não pode estar vazio';
    }

    // Verifica se contém profanidades
    if (_containsProfanity(value)) {
      return 'Seu comentário contém linguagem inapropriada. Por favor, tenha mais respeito.';
    }

    return null;
  }

  // Verifica se o texto contém palavras ofensivas
  bool _containsProfanity(String text) {
    final lowerText = text.toLowerCase();

    // Divide o texto em palavras e remove pontuação
    final words = lowerText.split(RegExp(r'\s+'));

    return words.any((word) {
      // Remove caracteres especiais e pontuação
      final cleanWord = word.replaceAll(RegExp(r'[.,/#!$%^&*;:{}=\-_`~()]'), '');
      return _profanityList.contains(cleanWord);
    });
  }

  Future<bool> submitFeedback(BuildContext context, String comment) async {
    final feedbackError = validateFeedback(comment);

    if (feedbackError != null) {
      _errorMessage = feedbackError;
      notifyListeners();
      await Helpers.showWarningDialog(context, feedbackError);
      return false;
    }

    if (_curso == null) {
      _errorMessage = 'Curso não encontrado';
      notifyListeners();
      Helpers.showError(context, 'Curso não encontrado');
      return false;
    }

    _isSubmittingFeedback = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _feedbackService.addFeedback(_curso!.id!, comment);
      _feedbackComment = '';
      _isSubmittingFeedback = false;

      // Reload course to update feedbacks
      if (_curso!.id != null) {
        await loadCurso(_curso!.id!, context: context);
      }

      notifyListeners();
      Helpers.showSuccess(context, 'Feedback enviado com sucesso!');
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao enviar feedback: ${e.toString()}';
      _isSubmittingFeedback = false;
      notifyListeners();
      Helpers.showError(context, _errorMessage!);
      return false;
    }
  }

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Obter userId do storage
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // Verificar se o usuário já tem feedback neste curso
  Future<bool> userHasFeedback() async {
    if (_curso == null || _curso!.feedBacks.isEmpty) return false;
    final userId = await _getUserId();
    if (userId == null) return false;

    return _curso!.feedBacks.any((feedback) => feedback.student?.id == userId);
  }

  // Obter feedback do usuário atual
  Future<dynamic> getUserFeedback() async {
    if (_curso == null) return null;
    final userId = await _getUserId();
    if (userId == null) return null;

    try {
      return _curso!.feedBacks.firstWhere(
        (feedback) => feedback.student?.id == userId,
      );
    } catch (e) {
      return null;
    }
  }

  // Editar feedback próprio
  Future<bool> updateFeedback(BuildContext context, int feedbackId, String newComment) async {
    final feedbackError = validateFeedback(newComment);

    if (feedbackError != null) {
      _errorMessage = feedbackError;
      notifyListeners();
      await Helpers.showWarningDialog(context, feedbackError);
      return false;
    }

    _isSubmittingFeedback = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _feedbackService.updateMyFeedback(feedbackId, newComment);
      _isSubmittingFeedback = false;

      // Reload course to update feedbacks
      if (_curso!.id != null) {
        await loadCurso(_curso!.id!, context: context);
      }

      notifyListeners();
      Helpers.showSuccess(context, 'Feedback atualizado com sucesso!');
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar feedback: ${e.toString()}';
      _isSubmittingFeedback = false;
      notifyListeners();
      Helpers.showError(context, _errorMessage!);
      return false;
    }
  }

  // Deletar feedback próprio
  Future<bool> deleteFeedback(BuildContext context, int feedbackId) async {
    _isSubmittingFeedback = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _feedbackService.deleteMyFeedback(feedbackId);
      _isSubmittingFeedback = false;

      // Reload course to update feedbacks
      if (_curso!.id != null) {
        await loadCurso(_curso!.id!, context: context);
      }

      notifyListeners();
      Helpers.showSuccess(context, 'Feedback removido com sucesso!');
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao remover feedback: ${e.toString()}';
      _isSubmittingFeedback = false;
      notifyListeners();
      Helpers.showError(context, _errorMessage!);
      return false;
    }
  }

  // Ordenar feedbacks colocando o do usuário no topo
  Future<List<dynamic>> getOrderedFeedbacks() async {
    if (_curso == null || _curso!.feedBacks.isEmpty) return [];

    final userId = await _getUserId();
    if (userId == null) return _curso!.feedBacks;

    final feedbacks = List.from(_curso!.feedBacks);
    final userFeedback = feedbacks.where((f) => f.student?.id == userId).toList();
    final otherFeedbacks = feedbacks.where((f) => f.student?.id != userId).toList();

    return [...userFeedback, ...otherFeedbacks];
  }

  Future<void> onVideoProgressUpdate(double progressPercentage) async {
    if (_currentContent == null || _curso == null || _currentSectionIndex == null) return;

    // Apenas marcar como concluído quando atingir >= 95%
    if (progressPercentage < 95) return;

    // IMPORTANTE: Verificar se já está marcado como concluído (evita marcação duplicada)
    // Verifica tanto a flag local quanto a lista global de IDs completados
    if (_hasMarkedCurrentContentComplete || _completedContentIds.contains(_currentContent!.id)) {
      if (!_hasMarkedCurrentContentComplete) {
        _hasMarkedCurrentContentComplete = true; // Atualiza flag se estava desatualizada
      }
      return;
    }

    final userId = await _getUserId();
    if (userId == null) {
      debugPrint('[PainelCursoViewModel] UserId não encontrado');
      return;
    }

    // Marcar como concluído ANTES de fazer a requisição
    _hasMarkedCurrentContentComplete = true;

    try {
      final currentSection = _sections[_currentSectionIndex!];
      await _userProgressService.markContentAsCompleted(
        _curso!.id!,
        currentSection.id!,
        _currentContent!.id!,
        userId,
      );

      // Adicionar à lista de concluídos
      _completedContentIds.add(_currentContent!.id!);

      debugPrint('[PainelCursoViewModel] Conteúdo marcado como concluído: ${_currentContent!.id} (${progressPercentage.toStringAsFixed(1)}%)');

      // Recarregar progresso para atualizar porcentagem
      await loadUserProgress();
    } catch (e) {
      debugPrint('[PainelCursoViewModel] Erro ao atualizar progresso: $e');
      // Reverter flag em caso de erro
      _hasMarkedCurrentContentComplete = false;
    }
  }

  Future<void> onPdfCompleted() async {
    if (_currentContent == null || _curso == null || _currentSectionIndex == null) return;

    // IMPORTANTE: Verificar se já está marcado como concluído (evita marcação duplicada)
    // Verifica tanto a flag local quanto a lista global de IDs completados
    if (_hasMarkedCurrentContentComplete || _completedContentIds.contains(_currentContent!.id)) {
      if (!_hasMarkedCurrentContentComplete) {
        _hasMarkedCurrentContentComplete = true; // Atualiza flag se estava desatualizada
      }
      debugPrint('[PainelCursoViewModel] PDF já está marcado como concluído');
      return;
    }

    final userId = await _getUserId();
    if (userId == null) {
      debugPrint('[PainelCursoViewModel] UserId não encontrado');
      return;
    }

    // Marcar como concluído ANTES de fazer a requisição
    _hasMarkedCurrentContentComplete = true;

    try {
      final currentSection = _sections[_currentSectionIndex!];
      await _userProgressService.markContentAsCompleted(
        _curso!.id!,
        currentSection.id!,
        _currentContent!.id!,
        userId,
      );

      // Adicionar à lista de concluídos
      _completedContentIds.add(_currentContent!.id!);

      debugPrint('[PainelCursoViewModel] PDF marcado como concluído (chegou na última página ou 95% de scroll)');

      // Recarregar progresso para atualizar porcentagem
      await loadUserProgress();
    } catch (e) {
      debugPrint('[PainelCursoViewModel] Erro ao marcar PDF como concluído: $e');
      // Reverter flag em caso de erro
      _hasMarkedCurrentContentComplete = false;
    }
  }

  Future<void> markCurrentContentAsCompleted() async {
    if (_currentContent == null || _curso == null || _currentSectionIndex == null) return;

    // IMPORTANTE: Verificar se já está marcado como concluído (evita marcação duplicada)
    // Verifica tanto a flag local quanto a lista global de IDs completados
    if (_hasMarkedCurrentContentComplete || _completedContentIds.contains(_currentContent!.id)) {
      if (!_hasMarkedCurrentContentComplete) {
        _hasMarkedCurrentContentComplete = true; // Atualiza flag se estava desatualizada
      }
      debugPrint('[PainelCursoViewModel] Conteúdo já está marcado como concluído');
      return;
    }

    final userId = await _getUserId();
    if (userId == null) {
      debugPrint('[PainelCursoViewModel] UserId não encontrado');
      return;
    }

    // Marcar como concluído ANTES de fazer a requisição
    _hasMarkedCurrentContentComplete = true;

    try {
      final currentSection = _sections[_currentSectionIndex!];
      await _userProgressService.markContentAsCompleted(
        _curso!.id!,
        currentSection.id!,
        _currentContent!.id!,
        userId,
      );

      // Adicionar à lista de concluídos
      _completedContentIds.add(_currentContent!.id!);

      debugPrint('[PainelCursoViewModel] Conteúdo marcado como concluído manualmente');

      // Recarregar progresso para atualizar porcentagem
      await loadUserProgress();
    } catch (e) {
      debugPrint('[PainelCursoViewModel] Erro ao marcar conteúdo como concluído: $e');
      // Reverter flag em caso de erro
      _hasMarkedCurrentContentComplete = false;
    }
  }

  Future<void> loadUserProgress() async {
    if (_curso == null) return;

    final userId = await _getUserId();
    if (userId == null) return;

    try {
      final progressData = await _userProgressService.getUserProgress(_curso!.id!, userId);
      final completedContents = progressData['completedContents'] as List?;
      final completePercentage = progressData['completePercentage'] as double?;

      // Atualizar lista de conteúdos concluídos
      if (completedContents != null) {
        _completedContentIds = completedContents
            .map((c) => c['contentId'] as int)
            .toSet();
      }

      // Atualizar porcentagem de progresso
      _courseProgress = completePercentage ?? 0.0;

      debugPrint('[PainelCursoViewModel] Progresso carregado: ${_completedContentIds.length} conteúdos concluídos');
      debugPrint('[PainelCursoViewModel] Porcentagem: ${(_courseProgress * 100).toStringAsFixed(1)}%');

      notifyListeners();
    } catch (e) {
      debugPrint('[PainelCursoViewModel] Erro ao carregar progresso: $e');
    }
  }

  // Encontra o primeiro conteúdo não concluído
  Map<String, int>? findFirstUncompletedContent() {
    for (int sectionIndex = 0; sectionIndex < _sections.length; sectionIndex++) {
      final section = _sections[sectionIndex];
      for (int contentIndex = 0; contentIndex < section.contents.length; contentIndex++) {
        final content = section.contents[contentIndex];
        if (content.id != null && !_completedContentIds.contains(content.id)) {
          debugPrint('[PainelCursoViewModel] Primeiro conteúdo não concluído encontrado: Seção $sectionIndex, Conteúdo $contentIndex');
          return {
            'sectionIndex': sectionIndex,
            'contentIndex': contentIndex,
          };
        }
      }
    }
    debugPrint('[PainelCursoViewModel] Nenhum conteúdo não concluído encontrado');
    return null;
  }

  // Navegar para o primeiro conteúdo não concluído após carregar o progresso
  void navigateToFirstUncompletedContent() {
    final uncompletedContent = findFirstUncompletedContent();
    if (uncompletedContent != null) {
      setCurrentContent(
        uncompletedContent['sectionIndex']!,
        uncompletedContent['contentIndex']!,
      );
    } else {
      // Se todos estão concluídos, vai para o primeiro
      if (_sections.isNotEmpty && _sections[0].contents.isNotEmpty) {
        setCurrentContent(0, 0);
      }
    }
  }
}

