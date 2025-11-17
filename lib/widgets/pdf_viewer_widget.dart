import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';

class PdfViewerWidget extends StatefulWidget {
  final String pdfUrl;
  final String fileName;
  final VoidCallback? onPdfCompleted;

  const PdfViewerWidget({
    super.key,
    required this.pdfUrl,
    required this.fileName,
    this.onPdfCompleted,
  });

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  String? _localFilePath;
  Uint8List? _pdfBytes; // Para web
  bool _isLoading = true;
  String? _errorMessage;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _hasReachedLastPage = false;

  @override
  void initState() {
    super.initState();
    _downloadAndLoadPdf();
  }

  @override
  void didUpdateWidget(PdfViewerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Detectar se a URL ou fileName mudou
    if (oldWidget.pdfUrl != widget.pdfUrl || oldWidget.fileName != widget.fileName) {
      // Resetar estado e carregar novo PDF
      setState(() {
        _localFilePath = null;
        _pdfBytes = null;
        _isLoading = true;
        _errorMessage = null;
        _totalPages = 0;
        _currentPage = 0;
        _hasReachedLastPage = false;
      });
      _downloadAndLoadPdf();
    }
  }

  Future<void> _downloadAndLoadPdf() async {
    try {
      print('Baixando PDF de: ${widget.pdfUrl}');

      // Download do PDF
      final response = await http.get(Uri.parse(widget.pdfUrl));

      if (response.statusCode == 200) {
        // Para WEB: usar bytes diretamente
        if (kIsWeb) {
          print('Plataforma: WEB - usando Uint8List');
          setState(() {
            _pdfBytes = response.bodyBytes;
            _isLoading = false;
          });
          return;
        }

        // Para MOBILE: salvar em arquivo local
        print('Plataforma: MOBILE - salvando em arquivo');

        // Obter diretório temporário
        final tempDir = await getTemporaryDirectory();

        // Criar estrutura de diretórios para organizar os PDFs
        // Extrair informações do URL se possível para criar path organizado
        String subPath = 'pdfs'; // path padrão

        // Tentar extrair courseId e sectionId do URL se existir
        final uri = Uri.parse(widget.pdfUrl);
        final pathSegments = uri.pathSegments;

        // Se o URL contém courses/X/sections/Y, usar essa estrutura
        if (pathSegments.contains('courses') && pathSegments.contains('sections')) {
          final courseIndex = pathSegments.indexOf('courses');
          final sectionIndex = pathSegments.indexOf('sections');

          if (courseIndex + 1 < pathSegments.length &&
              sectionIndex + 1 < pathSegments.length) {
            final courseId = pathSegments[courseIndex + 1];
            final sectionId = pathSegments[sectionIndex + 1];
            subPath = 'pdfs/courses/$courseId/sections/$sectionId';
          }
        }

        // Criar o diretório completo (recursive: true cria todos os diretórios necessários)
        final pdfDir = Directory('${tempDir.path}/$subPath');
        if (!await pdfDir.exists()) {
          await pdfDir.create(recursive: true);
          print('Diretório criado: ${pdfDir.path}');
        }

        // Extrair apenas o nome do arquivo (sem path) do fileName
        // O fileName pode vir como "courses/1/sections/1/arquivo.pdf" ou apenas "arquivo.pdf"
        final fileNameOnly = widget.fileName.split('/').last;

        // Salvar o arquivo
        final file = File('${pdfDir.path}/$fileNameOnly');
        await file.writeAsBytes(response.bodyBytes);

        print('PDF salvo em: ${file.path}');

        // Verificar se o arquivo realmente existe antes de tentar abrir
        if (!await file.exists()) {
          throw Exception('PDF não foi salvo corretamente em: ${file.path}');
        }

        print('Arquivo existe: ${await file.exists()}');
        print('Tamanho do arquivo: ${await file.length()} bytes');

        setState(() {
          _localFilePath = file.path;
          _isLoading = false;
        });
      } else {
        throw Exception('Erro ao baixar PDF: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar PDF: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar PDF: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Container(
        color: isDark ? AppColors.tertiaryColor : Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primaryButton,
              ),
              const SizedBox(height: 16),
              Text(
                'Carregando PDF...',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        color: isDark ? AppColors.tertiaryColor : Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: isDark ? Colors.red.shade300 : Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar PDF',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? Colors.white.withAlpha(150) : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_localFilePath == null && _pdfBytes == null) {
      return Container(
        color: isDark ? AppColors.tertiaryColor : Colors.grey.shade200,
        child: Center(
          child: Text(
            'PDF não disponível',
            style: GoogleFonts.inter(
              color: isDark ? Colors.white : AppColors.textColor,
            ),
          ),
        ),
      );
    }

    // Para WEB: usar bytes diretamente
    if (kIsWeb && _pdfBytes != null) {
      return _buildWebPdfViewer(isDark);
    }

    // Para MOBILE: renderizar PDF do arquivo
    // A verificação de existência já foi feita no _downloadAndLoadPdf()
    if (!kIsWeb && _localFilePath != null) {
      return _buildMobilePdfViewer(isDark);
    }

    // Fallback
    return Container(
      color: isDark ? AppColors.tertiaryColor : Colors.grey.shade200,
      child: Center(
        child: Text(
          'Plataforma não suportada',
          style: GoogleFonts.inter(
            color: isDark ? Colors.white : AppColors.textColor,
          ),
        ),
      ),
    );
  }

  // Viewer para WEB usando bytes
  Widget _buildWebPdfViewer(bool isDark) {
    return Stack(
      children: [
        PDFView(
          pdfData: _pdfBytes,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: false,
          pageFling: false,
          pageSnap: false,
          defaultPage: _currentPage,
          fitPolicy: FitPolicy.BOTH,
          fitEachPage: false,
          preventLinkNavigation: false,
          backgroundColor: isDark ? AppColors.tertiaryColor : Colors.white,
          onRender: (pages) {
            setState(() {
              _totalPages = pages ?? 0;
            });
          },
          onError: (error) {
            setState(() {
              _errorMessage = error.toString();
            });
          },
          onPageError: (page, error) {
            // Silently handle page errors
          },
          onViewCreated: (PDFViewController pdfViewController) {
            // PDF View created
          },
          onPageChanged: (int? page, int? total) {
            setState(() {
              _currentPage = page ?? 0;
            });

            // Verificar se chegou na última página
            if (page != null && total != null && page + 1 >= total && !_hasReachedLastPage) {
              _hasReachedLastPage = true;
              widget.onPdfCompleted?.call();
              print('[PDF] Usuário chegou na última página: ${page + 1} de $total');
            }
          },
        ),
        // Indicador de página
        if (_totalPages > 0)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryColor.withAlpha(230)
                      : Colors.black.withAlpha(179),
                  borderRadius: BorderRadius.circular(20),
                  border: isDark
                      ? Border.all(
                          color: AppColors.primaryButton.withAlpha(100),
                          width: 1,
                        )
                      : null,
                ),
                child: Text(
                  'Página ${_currentPage + 1} de $_totalPages',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Viewer para MOBILE usando arquivo
  Widget _buildMobilePdfViewer(bool isDark) {
    return Stack(
      children: [
        PDFView(
          filePath: _localFilePath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: false,
          pageFling: false,
          pageSnap: false,
          defaultPage: _currentPage,
          fitPolicy: FitPolicy.BOTH,
          fitEachPage: false,
          preventLinkNavigation: false,
          backgroundColor: isDark ? AppColors.tertiaryColor : Colors.white,
          onRender: (pages) {
            setState(() {
              _totalPages = pages ?? 0;
            });
          },
          onError: (error) {
            setState(() {
              _errorMessage = error.toString();
            });
          },
          onPageError: (page, error) {
            // Silently handle page errors
          },
          onViewCreated: (PDFViewController pdfViewController) {
            // PDF View created
          },
          onPageChanged: (int? page, int? total) {
            setState(() {
              _currentPage = page ?? 0;
            });

            // Verificar se chegou na última página
            if (page != null && total != null && page + 1 >= total && !_hasReachedLastPage) {
              _hasReachedLastPage = true;
              widget.onPdfCompleted?.call();
              print('[PDF] Usuário chegou na última página: ${page + 1} de $total');
            }
          },
        ),
        // Indicador de página
        if (_totalPages > 0)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryColor.withAlpha(230)
                      : Colors.black.withAlpha(179),
                  borderRadius: BorderRadius.circular(20),
                  border: isDark
                      ? Border.all(
                          color: AppColors.primaryButton.withAlpha(100),
                          width: 1,
                        )
                      : null,
                ),
                child: Text(
                  'Página ${_currentPage + 1} de $_totalPages',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

