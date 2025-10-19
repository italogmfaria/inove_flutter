import 'package:flutter/material.dart';
import '../model/course_model.dart';
import '../model/section_model.dart';
import '../model/content_model.dart';
import '../services/course_service.dart';
import '../services/section_service.dart';
import '../services/content_service.dart';
import '../services/feedback_service.dart';
import '../core/utils/helpers.dart';
import '../core/utils/validators.dart';

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
    _sections = curso.sections;
    notifyListeners();
  }

  Future<void> loadCurso(int cursoId, {BuildContext? context}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _curso = await _cursoService.getCursoById(cursoId);
      await loadSections(cursoId);
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

  Future<void> loadSections(int cursoId) async {
    try {
      _sections = await _sectionService.getSections(cursoId);
      _calculateProgress();
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar seções: ${e.toString()}');
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
    return Validators.minLength(value, 10, fieldName: 'Comentário');
  }

  Future<bool> submitFeedback(BuildContext context) async {
    final feedbackError = validateFeedback(_feedbackComment);

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
      await _feedbackService.addFeedback(_curso!.id!, _feedbackComment);
      _feedbackComment = '';
      _isSubmittingFeedback = false;
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
}
