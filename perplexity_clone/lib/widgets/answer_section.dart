import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:perplexity_clone/services/chat_web_service.dart';
import 'package:perplexity_clone/theme/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class AnswerSection extends StatefulWidget {
  const AnswerSection({super.key});

  @override
  State<AnswerSection> createState() => _AnswerSectionState();
}

class _AnswerSectionState extends State<AnswerSection> {
  // State variables
  bool isLoading = true;
  bool answerComplete = false;
  
  // Data management
  final StringBuffer _fullResponseBuffer = StringBuffer();
  String _displayedResponse = "";
  List<Map<String, dynamic>> sources = [];

  // Stream management
  StreamSubscription? _searchSubscription;
  StreamSubscription? _contentSubscription;
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();
    _setupStreams();
  }

  void _setupStreams() {
    // 1. Listen for Search Sources (Citations)
    _searchSubscription = ChatWebService().searchResultStream.listen((data) {
      if (!mounted) return;
      setState(() {
        sources = List<Map<String, dynamic>>.from(data['data'] ?? []);
      });
    });

    // 2. Listen for Content (Text Stream)
    _contentSubscription = ChatWebService().contentStream.listen((data) {
      if (!mounted) return;

      final chunk = data['data'] as String;

      // Initialize on first chunk
      if (isLoading) {
        setState(() {
          isLoading = false;
          answerComplete = false;
          _fullResponseBuffer.clear();
          _displayedResponse = "";
        });
        _startTypewriterTicker();
      }

      // Add to buffer immediately (don't setState here to avoid race conditions)
      _fullResponseBuffer.write(chunk);
    });
  }

  /// Ticker that pulls text from buffer to UI smoothly
  void _startTypewriterTicker() {
    _typewriterTimer?.cancel();
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final fullText = _fullResponseBuffer.toString();
      
      // If display catches up to buffer
      if (_displayedResponse.length >= fullText.length) {
        // If we have a lot of text and the stream seems quiet, we might be done.
        // But usually, we rely on the user to stop or just leave it 'complete'
        if (_displayedResponse.length > 100 && !answerComplete) {
           setState(() => answerComplete = true);
        }
        return;
      }

      // Calculate next chunk size (adaptive speed)
      // If we are far behind, type faster. If close, type slower.
      int charsToAdd = 2;
      int pending = fullText.length - _displayedResponse.length;
      if (pending > 50) charsToAdd = 5;
      if (pending > 100) charsToAdd = 10;

      final int nextIndex = (_displayedResponse.length + charsToAdd).clamp(0, fullText.length);
      
      setState(() {
        _displayedResponse = fullText.substring(0, nextIndex);
      });
    });
  }

  @override
  void dispose() {
    _searchSubscription?.cancel();
    _contentSubscription?.cancel();
    _typewriterTimer?.cancel();
    super.dispose();
  }

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  Widget _buildSourceCards() {
    if (sources.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 130, // Slightly compact
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sources.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final source = sources[index];
          return Container(
            width: 240,
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _launchURL(source['url']),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${index + 1}. ${source['title'] ?? 'Source'}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      source['url'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blueAccent.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.auto_awesome, size: 20, color: Colors.tealAccent),
              SizedBox(width: 8),
              Text(
                'Perplexity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          // 1. Sources Section (Horizontal Scroll)
          Skeletonizer(
            enabled: isLoading && sources.isEmpty,
            child: _buildSourceCards(),
          ),
          
          const SizedBox(height: 24),

          // 2. Main Answer Section
          Skeletonizer(
            enabled: isLoading,
            child: isLoading
                ? _buildLoadingPlaceholder()
                : MarkdownBody(
                    data: _displayedResponse,
                    selectable: true,
                    onTapLink: (text, href, title) => _launchURL(href),
                    styleSheet: MarkdownStyleSheet(
                      // Text Styles
                      p: const TextStyle(fontSize: 16, height: 1.6, color: Colors.white),
                      h1: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, height: 2),
                      h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 2),
                      h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white, height: 1.5),
                      
                      // List Styles (Bullets)
                      listBullet: const TextStyle(color: Colors.tealAccent, fontSize: 16),
                      listIndent: 24.0,
                      
                      // Code Styles
                      code: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: Colors.orangeAccent,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      
                      // Blockquote
                      blockquote: TextStyle(color: Colors.grey.shade300, fontStyle: FontStyle.italic),
                      blockquoteDecoration: BoxDecoration(
                        color: AppColors.cardColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                        border: const Border(
                          left: BorderSide(color: Colors.tealAccent, width: 4),
                        ),
                      ),
                    ),
                  ),
          ),
          
          // 3. Footer Status
          if (!isLoading && answerComplete)
             Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 40.0),
              child: Row(
                children: [
                   const Icon(Icons.check_circle, size: 16, color: Colors.tealAccent),
                   const SizedBox(width: 8),
                   Text(
                     "Answer Generated", 
                     style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)
                   ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: double.infinity, height: 16, color: Colors.grey),
        const SizedBox(height: 8),
        Container(width: double.infinity, height: 16, color: Colors.grey),
        const SizedBox(height: 8),
        Container(width: 200, height: 16, color: Colors.grey),
      ],
    );
  }
}