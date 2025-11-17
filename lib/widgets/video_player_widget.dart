import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../core/theme/app_colors.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final Function(double progressPercentage)? onProgressUpdate;
  final Function()? onVideoCompleted;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.onProgressUpdate,
    this.onVideoCompleted,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  bool _isLoading = true;
  bool _isLoadingMetadata = true;
  String? _errorMessage;
  bool _hasEmittedCompletion = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      debugPrint('[VideoPlayer] URL mudou, reinicializando controller');
      _disposeController();
      _hasEmittedCompletion = false;
      _initializeController();
    }
  }

  void _disposeController() {
    try {
      _videoPlayerController?.removeListener(_onVideoStateChange);
    } catch (_) {}
    try {
      _videoPlayerController?.dispose();
    } catch (_) {}
  }

  Future<void> _initializeController() async {
    try {
      if (_videoPlayerController != null) {
        _disposeController();
      }
    } catch (_) {}

    setState(() {
      _isLoading = true;
      _isLoadingMetadata = true;
      _errorMessage = null;
    });

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

      await _videoPlayerController!.setLooping(false);

      await _videoPlayerController!.initialize();

      debugPrint('[VideoPlayer] Metadata carregada. Duração: ${_videoPlayerController!.value.duration.inSeconds}s');

      _videoPlayerController!.addListener(_onVideoStateChange);

      setState(() {
        _isLoading = false;
        _isLoadingMetadata = false;
      });
    } catch (e) {
      debugPrint('[VideoPlayer] Erro ao inicializar: $e');
      setState(() {
        _errorMessage = 'Erro ao carregar vídeo: $e';
        _isLoading = false;
        _isLoadingMetadata = false;
      });
    }
  }

  void _onVideoStateChange() {
    if (!mounted || _videoPlayerController == null) return;

    final position = _videoPlayerController!.value.position;
    final duration = _videoPlayerController!.value.duration;

    if (duration.inMilliseconds > 0) {
      final progressPercentage = (position.inMilliseconds / duration.inMilliseconds) * 100;

      widget.onProgressUpdate?.call(progressPercentage);

      if (progressPercentage >= 95 && !_hasEmittedCompletion) {
        _hasEmittedCompletion = true;
        debugPrint('[VideoPlayer] Vídeo concluído aos 95%');
        widget.onVideoCompleted?.call();
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _disposeController();
    super.dispose();
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });

    _hideControlsTimer?.cancel();

    if (_videoPlayerController?.value.isPlaying ?? false) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && (_videoPlayerController?.value.isPlaying ?? false)) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _togglePlayPause() async {
    if (_videoPlayerController == null) return;

    if (_videoPlayerController!.value.isPlaying) {
      await _videoPlayerController!.pause();
      setState(() {
        _showControls = true;
      });
      _hideControlsTimer?.cancel();
    } else {
      await _videoPlayerController!.play();
      _showControlsTemporarily();
    }
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
    }
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading || _isLoadingMetadata) {
      return AspectRatio(
        aspectRatio: 16/9,
        child: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height:12),
                Text(_isLoadingMetadata ? 'Carregando metadados...' : 'Carregando vídeo...', style: const TextStyle(color: Colors.white70))
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return AspectRatio(
        aspectRatio: 16/9,
        child: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(_errorMessage!, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _isLoading = true;
                    _errorMessage = null;
                    setState(() {});
                    _initializeController();
                  },
                  child: const Text('Tentar novamente')
                )
              ],
            ),
          ),
        ),
      );
    }

    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16/9,
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: const Text('Inicializando...', style: TextStyle(color: Colors.white70))
        ),
      );
    }

    final duration = _videoPlayerController!.value.duration;
    final position = _videoPlayerController!.value.position;
    final clampedPos = position > duration ? duration : position;

    return AspectRatio(
      aspectRatio: _videoPlayerController!.value.aspectRatio > 0 ? _videoPlayerController!.value.aspectRatio : 16/9,
      child: GestureDetector(
        onTap: () {
          if (_showControls) {
            if (_videoPlayerController?.value.isPlaying ?? false) {
              setState(() {
                _showControls = false;
              });
              _hideControlsTimer?.cancel();
            }
          } else {
            _showControlsTemporarily();
          }
        },
        onDoubleTap: () {
          _togglePlayPause();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            VideoPlayer(_videoPlayerController!),

            if (!_videoPlayerController!.value.isPlaying)
              Center(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle
                  ),
                  child: IconButton(
                    iconSize: 64,
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    onPressed: _togglePlayPause,
                  ),
                ),
              ),

            if (_showControls || !_videoPlayerController!.value.isPlaying)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildControls(clampedPos, duration, isDark),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(Duration position, Duration duration, bool isDark) {
    final totalMs = duration.inMilliseconds;
    final posMs = position.inMilliseconds.clamp(0, totalMs);

    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xAA000000), Color(0x00000000)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbColor: Colors.white,
                activeTrackColor: AppColors.primaryButton,
                inactiveTrackColor: Colors.white30
              ),
              child: Slider(
                min: 0,
                max: totalMs > 0 ? totalMs.toDouble() : 1,
                value: totalMs > 0 ? posMs.toDouble() : 0,
                onChanged: (v) async {
                  final target = Duration(milliseconds: v.round());
                  await _videoPlayerController!.seekTo(target);
                  _showControlsTemporarily();
                },
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _videoPlayerController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white
                  ),
                  onPressed: _togglePlayPause,
                ),
                Text(
                  '${_format(position)} / ${duration == Duration.zero ? '--:--' : _format(duration)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12)
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: () async {
                    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
                    await SystemChrome.setPreferredOrientations([
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.landscapeRight
                    ]);
                    await Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => _FullscreenPlayer(
                          controller: _videoPlayerController!,
                          format: _format
                        )
                      )
                    );
                    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                    _showControlsTemporarily();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final String Function(Duration) format;

  const _FullscreenPlayer({
    required this.controller,
    required this.format
  });

  @override
  State<_FullscreenPlayer> createState() => _FullscreenPlayerState();
}

class _FullscreenPlayerState extends State<_FullscreenPlayer> {
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_l);
    _showControlsTemporarily();
  }

  void _l() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    widget.controller.removeListener(_l);
    super.dispose();
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });

    _hideControlsTimer?.cancel();

    if (widget.controller.value.isPlaying) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && widget.controller.value.isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _togglePlayPause() async {
    if (widget.controller.value.isPlaying) {
      await widget.controller.pause();
      setState(() {
        _showControls = true;
      });
      _hideControlsTimer?.cancel();
    } else {
      await widget.controller.play();
      _showControlsTemporarily();
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    final duration = value.duration;
    final pos = value.position;
    final posClamped = pos > duration ? duration : pos;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
        child: GestureDetector(
          onTap: () {
            if (_showControls) {
              if (widget.controller.value.isPlaying) {
                setState(() {
                  _showControls = false;
                });
                _hideControlsTimer?.cancel();
              }
            } else {
              _showControlsTemporarily();
            }
          },
          onDoubleTap: () {
            _togglePlayPause();
          },
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: value.aspectRatio > 0 ? value.aspectRatio : 16/9,
                  child: VideoPlayer(widget.controller)
                )
              ),

              if (!value.isPlaying)
                Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle
                    ),
                    child: IconButton(
                      iconSize: 64,
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      onPressed: _togglePlayPause,
                    ),
                  ),
                ),

              if (_showControls || !value.isPlaying)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xCC000000), Color(0x00000000)]
                        )
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbColor: Colors.white,
                              activeTrackColor: AppColors.primaryButton,
                              inactiveTrackColor: Colors.white30
                            ),
                            child: Slider(
                              min: 0,
                              max: duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1,
                              value: duration.inMilliseconds > 0 ? posClamped.inMilliseconds.toDouble() : 0,
                              onChanged: (v) async {
                                await widget.controller.seekTo(Duration(milliseconds: v.round()));
                                _showControlsTemporarily();
                              },
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  value.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white
                                ),
                                onPressed: _togglePlayPause
                              ),
                              Text(
                                '${widget.format(posClamped)} / ${duration == Duration.zero ? '--:--' : widget.format(duration)}',
                                style: const TextStyle(color: Colors.white, fontSize: 12)
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }
                              ),
                            ]
                          )
                        ]
                      ),
                    ),
                  ),
                )
            ]
          ),
        ),
      ),
    );
  }
}
