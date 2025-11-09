import 'package:flutter/material.dart';
import 'account_card.dart';

class MagneticSlider extends StatefulWidget {
  final List<String> accounts;
  final Function(String) onAccountSelected;

  const MagneticSlider({
    super.key,
    required this.accounts,
    required this.onAccountSelected,
  });

  @override
  State<MagneticSlider> createState() => _MagneticSliderState();
}

class _MagneticSliderState extends State<MagneticSlider> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // استفاده از postFrameCallback به جای مستقیم فراخوانی
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.accounts.isNotEmpty) {
        widget.onAccountSelected(widget.accounts.first);
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final scrollPosition = _scrollController.position.pixels;
    final itemWidth = 160.0;
    final newIndex = (scrollPosition / itemWidth).round();

    if (newIndex != _selectedIndex &&
        newIndex >= 0 &&
        newIndex < widget.accounts.length) {
      setState(() {
        _selectedIndex = newIndex;
      });
      widget.onAccountSelected(widget.accounts[newIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.accounts.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: const Text(
          'حسابی موجود نیست',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.accounts.length,
        itemBuilder: (context, index) {
          final account = widget.accounts[index];
          final isSelected = index == _selectedIndex;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: AccountCard(
              accountName: account,
              balance: 0,
              isCenter: isSelected,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
