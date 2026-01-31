import 'package:flutter/material.dart';
import 'package:perplexity_clone/services/chat_web_service.dart';
import 'package:perplexity_clone/theme/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SidePanel extends StatefulWidget {
  const SidePanel({super.key});

  @override
  State<SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel> {
  bool isLoading = true;
  List<dynamic> images = [];

  @override
  void initState() {
    super.initState();
    
    // Check cache
    final cached = ChatWebService().lastSearchResult;
    if (cached != null && cached['images'] != null) {
      if (mounted) {
        setState(() {
          images = (cached['images'] as List).where((img) => img != null && img.toString().isNotEmpty).toList();
          isLoading = false;
        });
      }
    }

    ChatWebService().searchResultStream.listen((data) {
      if (!mounted) return;
      if (data['images'] != null) {
        setState(() {
          images = (data['images'] as List).where((img) => img != null && img.toString().isNotEmpty).toList();
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           if (isLoading)
             Skeletonizer(
               enabled: true,
               child: Column(
                 children: [
                   Container(height: 150, width: double.infinity, color: Colors.grey),
                   SizedBox(height: 10),
                   Container(height: 150, width: double.infinity, color: Colors.grey),
                 ],
               ),
             ),
             
           if (!isLoading && images.isNotEmpty) ...[
             const Text(
               "Related Images",
               style: TextStyle(
                 fontSize: 18, 
                 fontWeight: FontWeight.bold,
                 color: Colors.white
               ),
             ),
             const SizedBox(height: 16),
             Expanded(
               child: ListView.separated(
                 itemCount: images.length,
                 separatorBuilder: (context, index) => const SizedBox(height: 12),
                 itemBuilder: (context, index) {
                   final imgUrl = images[index];
                   return ClipRRect(
                     borderRadius: BorderRadius.circular(12),
                     child: Image.network(
                       imgUrl,
                       fit: BoxFit.cover,
                       errorBuilder: (context, error, stackTrace) {
                         return const SizedBox.shrink();
                       },
                     ),
                   );
                 },
               ),
             )
           ]
        ],
      ),
    );
  }
}
