import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/course_model.dart';
import '../model/section_model.dart';
import '../model/content_model.dart';
import '../services/course_service.dart';
import '../services/section_service.dart';
import '../services/content_service.dart';
import '../services/feedback_service.dart';
import '../core/utils/helpers.dart';

class PainelCursoViewModel extends ChangeNotifier {
  final CursoService _cursoService;
  final SectionService _sectionService;
  final ContentService _contentService;
  final FeedbackService _feedbackService;

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

  PainelCursoViewModel(
    this._cursoService,
    this._sectionService,
    this._contentService,
    this._feedbackService,
  );

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

  void setCurso(CursoModel curso) {
    _curso = curso;
    // Ordenar seções por ID
    _sections = List.from(curso.sections)
      ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    notifyListeners();
  }

  Future<void> loadCurso(int cursoId, {BuildContext? context}) async {
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

        // Auto-selecionar primeiro conteúdo se disponível
        if (_sections.isNotEmpty && _sections[0].contents.isNotEmpty) {
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

      // Auto-select first content if available
      if (_sections.isNotEmpty && _sections[0].contents.isNotEmpty) {
        setCurrentContent(0, 0);
      }

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
      return;
    }

    int totalContents = 0;
    int completedContents = 0;

    for (var section in _sections) {
      totalContents += section.contents.length;
    }

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
    // Aceita qualquer tamanho de comentário
    if (value == null || value.trim().isEmpty) {
      return 'O comentário não pode estar vazio';
    }
    return null;
  }

  Future<bool> submitFeedback(BuildContext context, String comment) async {
    final feedbackError = validateFeedback(comment);

    if (feedbackError != null) {
      _errorMessage = feedbackError;
      notifyListeners();
      Helpers.showWarning(context, feedbackError);
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
      Helpers.showWarning(context, feedbackError);
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
}
