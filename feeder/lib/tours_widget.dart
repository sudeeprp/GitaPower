import 'package:askys/feedcontent.dart';
import 'package:askys/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToursListWidget extends StatelessWidget {
  const ToursListWidget({super.key});

  Widget _buildTourCard({
    required Key key,
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withValues(alpha: 0.5),
            blurRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        key: key,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.blue).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 24, color: iconColor ?? Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
    );
  }

  List<Widget> _onlinePlayables(BuildContext context) {
    PlayablesTOC playablesTOC = Get.find();
    if (playablesTOC.playables.isEmpty) {
      return [
        Center(
            child: IconButton(
                key: const Key('tours/refresh'),
                icon:
                    const Icon(Icons.refresh, size: 32, color: Colors.blueGrey),
                tooltip: 'Refresh tours',
                onPressed: () {
                  playablesTOC.extractPlayables();
                }))
      ];
    }
    return playablesTOC.playables
        .map((playable) => _buildTourCard(
              key: Key(playable.tourFolder),
              context: context,
              icon: Icons.play_arrow,
              title: playable.title,
              onTap: () => navigateApplink(Uri.parse(playable.url)),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView(
        padding: EdgeInsets.zero,
        children: [
              _buildTourCard(
                key: const Key('tour/random'),
                context: context,
                icon: Icons.star_rounded,
                title: 'Explore Yourself',
                iconColor: Colors.deepOrange,
                onTap: () {
                  final FeedContent feedContent = Get.find();
                  feedContent.resetToRandom();
                  Get.toNamed('/feed');
                },
              ),
              _buildTourCard(
                key: const Key('tour/search'),
                context: context,
                icon: Icons.search_rounded,
                title: 'Search',
                iconColor: Colors.deepOrange,
                onTap: () => Get.toNamed('/search'),
              ),
            ] +
            _onlinePlayables(context)));
  }
}
