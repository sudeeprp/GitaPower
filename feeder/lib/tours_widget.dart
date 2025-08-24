import 'package:askys/feedcontent.dart';
import 'package:askys/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToursListWidget extends StatelessWidget {
  const ToursListWidget({super.key});

  Widget _buildTourCard({
    required Key key,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        key: key,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.blue).withOpacity(0.1),
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
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    PlayablesTOC playablesTOC = Get.find();
    return Obx(() => ListView(
          padding: EdgeInsets.zero,
          children: [
                _buildTourCard(
                  key: const Key('tour/random'),
                  icon: Icons.star_rounded,
                  title: 'Explore Yourself',
                  iconColor: Colors.orange,
                  onTap: () {
                    final FeedContent feedContent = Get.find();
                    feedContent.resetToRandom();
                    Get.toNamed('/feed');
                  },
                ),
              ] +
              playablesTOC.playables
                  .map((playable) => _buildTourCard(
                        key: Key(playable.tourFolder),
                        icon: Icons.play_arrow,
                        title: playable.title,
                        onTap: () => navigateApplink(Uri.parse(playable.url)),
                      ))
                  .toList(),
        ));
  }
}
