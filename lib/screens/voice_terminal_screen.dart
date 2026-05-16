import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../services/voice_detection_service.dart';

class VoiceTerminalScreen extends StatefulWidget {
  const VoiceTerminalScreen({super.key});

  @override
  State<VoiceTerminalScreen> createState() => _VoiceTerminalScreenState();
}

class _VoiceTerminalScreenState extends State<VoiceTerminalScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Auto-start monitoring if not already on
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final voice = Provider.of<VoiceDetectionService>(context, listen: false);
      if (!voice.isMonitoring) {
        voice.startMonitoring();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'VOICE SHIELD TERMINAL',
          style: AppTheme.labelLarge.copyWith(color: Colors.white, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: Consumer<VoiceDetectionService>(
        builder: (_, voice, __) {
          // Whenever words change, scroll to bottom
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

          return Column(
            children: [
              const SizedBox(height: 40),
              
              // ── Pulsing Mic Orb ──
              Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryBlue.withOpacity(0.1 + (_pulseController.value * 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.3 * _pulseController.value),
                            blurRadius: 40 * _pulseController.value,
                            spreadRadius: 10 * _pulseController.value,
                          )
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                          ),
                          child: const Icon(Icons.mic_none_rounded, color: Colors.white, size: 40),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              Text(
                voice.isMonitoring ? 'ACTIVELY MONITORING' : 'IDLE',
                style: AppTheme.bodySmall.copyWith(
                  color: voice.isMonitoring ? AppTheme.safeGreen : AppTheme.grey400,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  voice.statusText,
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyLarge.copyWith(color: Colors.white70),
                ),
              ),

              const SizedBox(height: 40),

              // ── Transcript Monitor ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('LIVE TRANSCRIPT', style: AppTheme.bodySmall.copyWith(color: Colors.white24, fontWeight: FontWeight.bold)),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppTheme.dangerRed, shape: BoxShape.circle),
                          ).animate(onPlay: (c) => c.repeat()).fade(duration: 800.ms),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Text(
                            voice.lastRecognizedWords.isEmpty 
                                ? '> Listening for environmental cues...' 
                                : '> ${voice.lastRecognizedWords}',
                            style: GoogleFonts.firaCode(
                              color: AppTheme.primaryBlueLight,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Footer Toggles ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => voice.resetDanger(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Reset Cues'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (voice.isMonitoring) {
                            voice.stopMonitoring();
                          } else {
                            voice.startMonitoring();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: voice.isMonitoring ? AppTheme.dangerRed.withOpacity(0.2) : AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(voice.isMonitoring ? 'Stop Shield' : 'Start Shield'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
