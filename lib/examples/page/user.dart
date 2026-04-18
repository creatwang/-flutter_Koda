import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  static const _products = <_ProductItem>[
    _ProductItem(
      title: 'Camaleonda Sofa',
      price: r'$42,800',
      tag: 'NEW COLLECTION',
      color: Color(0xFF1F6B60),
    ),
    _ProductItem(
      title: 'CH24 Wishbone Chair',
      price: r'$8,200',
      color: Color(0xFF9B6A3A),
    ),
    _ProductItem(
      title: 'Brutalist Slate Coffee Table',
      price: r'$15,600',
      color: Color(0xFF5E5A55),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9A9894),
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SideProfilePanel(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeader(),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 230,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _products.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 14),
                              itemBuilder: (_, index) => _ProductCard(item: _products[index]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const _BottomTabBar(),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: const [
          Text(
            'LUXE MALL',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          Spacer(),
          Icon(Icons.shopping_cart_outlined, color: Colors.white70, size: 16),
          SizedBox(width: 12),
          Icon(Icons.account_circle_outlined, color: Colors.white70, size: 16),
        ],
      ),
    );
  }
}

class _SideProfilePanel extends StatelessWidget {
  const _SideProfilePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF101010),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.person, color: Colors.white70, size: 36),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E5CA8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white70),
                    ),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Julian Vance',
              style: TextStyle(color: Colors.white, fontSize: 26 * 0.62, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 2),
          const Center(
            child: Text(
              'SENIOR CURATOR',
              style: TextStyle(color: Colors.white60, fontSize: 9, letterSpacing: 1.1),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: _MetricCard(number: '128', label: 'SAVED ITEMS')),
              SizedBox(width: 8),
              Expanded(child: _MetricCard(number: '24', label: 'CONCEPTS')),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'ACCOUNT & PREFERENCES',
            style: TextStyle(color: Colors.white60, fontSize: 9, letterSpacing: 1.1),
          ),
          const SizedBox(height: 6),
          const _MenuItem(icon: Icons.settings, title: 'Account Settings'),
          const SizedBox(height: 6),
          const _MenuItem(icon: Icons.groups_2_outlined, title: 'My Customers'),
          const SizedBox(height: 6),
          const _MenuItem(icon: Icons.notifications_none, title: 'Order Center', selected: true),
          const SizedBox(height: 6),
          const _MenuItem(icon: Icons.favorite_border, title: 'Favorites'),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.number,
    required this.label,
  });

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24 * 0.58),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 7.5, letterSpacing: 0.7),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? Colors.black.withValues(alpha: 0.22) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 10.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white54, size: 14),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Favorites',
          style: TextStyle(color: Colors.white, fontSize: 31 * 0.62, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            children: [
              Icon(Icons.tune, size: 12, color: Colors.white70),
              SizedBox(width: 6),
              Text(
                'All Statuses',
                style: TextStyle(color: Colors.white70, fontSize: 10.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.item});

  final _ProductItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 146,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 144,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                if (item.tag != null)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.tag!,
                        style: const TextStyle(
                          color: Color(0xFF45618D),
                          fontSize: 7.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: item.color.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.favorite_border, size: 13, color: Colors.white60),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            item.price,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomTabBar extends StatelessWidget {
  const _BottomTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          _TabItem(icon: Icons.home_outlined, label: 'HOME'),
          _TabItem(icon: Icons.inventory_2_outlined, label: 'PRODUCTS', selected: true),
          _TabItem(icon: Icons.folder_open_outlined, label: 'CASES'),
          _TabItem(icon: Icons.travel_explore_outlined, label: 'STYLES'),
          _TabItem(icon: Icons.person_outline, label: 'PROFILE'),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 32,
      decoration: BoxDecoration(
        color: selected ? Colors.black.withValues(alpha: 0.35) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 7.5,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductItem {
  const _ProductItem({
    required this.title,
    required this.price,
    required this.color,
    this.tag,
  });

  final String title;
  final String price;
  final String? tag;
  final Color color;
}
