import 'package:flutter/material.dart';
import 'package:george_pick_mate/features/product/presentation/widgets/product_detail_card_decoration.dart';

class ProductDetailMediaPanel extends StatelessWidget {
  const ProductDetailMediaPanel({
    super.key,
    required this.images,
    required this.imageIndex,
    required this.pageController,
    required this.thumbScrollController,
    required this.onPageChanged,
    required this.onThumbnailTap,
  });

  final List<String> images;
  final int imageIndex;
  final PageController pageController;
  final ScrollController thumbScrollController;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onThumbnailTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: productDetailCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 110,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(5),
            ),
            child: ListView.separated(
              controller: thumbScrollController,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final selectedThumb = imageIndex == index;
                return GestureDetector(
                  onTap: () => onThumbnailTap(index),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        width: 2,
                        color: selectedThumb
                            ? Colors.black
                            : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Color(0x22111111),
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.12),
                child: images.isEmpty
                    ? const Center(child: Icon(Icons.image_not_supported))
                    : PageView.builder(
                        controller: pageController,
                        itemCount: images.length,
                        onPageChanged: onPageChanged,
                        itemBuilder: (_, index) => Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
