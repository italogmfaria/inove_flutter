import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class PdfViewerWidget extends StatefulWidget {
  final String pdfUrl;
  final String fileName;

  const PdfViewerWidget({
    super.key,
    required this.pdfUrl,
    required this.fileName,
  });

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  String? _localFilePath;
  bool _isLoading = true;
  String? _errorMessage;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _downloadAndLoadPdf();
  }

  Future<void> _downloadAndLoadPdf() async {
    try {
      print('Baixando PDF de: ${widget.pdfUrl}');

      // Download do PDF
      final response = await http.get(Uri.parse(widget.pdfUrl));

      if (response.statusCode == 200) {
        // Salvar arquivo temporariamente
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/${widget.fileName}');
        await file.writeAsBytes(response.bodyBytes);

        print('PDF salvo em: ${file.path}');

        setState(() {
          _localFilePath = file.path;
          _isLoading = false;
        });
      } else {
        throw Exception('Erro ao baixar PDF: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar PDF: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
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

    if (_localFilePath == null) {
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

    return Stack(
      children: [
        PDFView(
          filePath: _localFilePath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          pageSnap: true,
          defaultPage: _currentPage,
          fitPolicy: FitPolicy.BOTH,
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

