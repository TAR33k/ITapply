import 'package:flutter/material.dart';
import 'package:itapply_desktop/config/app_theme.dart';

class TabbedCard extends StatefulWidget {
  final List<String> tabTitles;
  final List<Widget> tabViews;
  final String title;
  final IconData? icon;

  const TabbedCard({
    super.key,
    required this.tabTitles,
    required this.tabViews,
    required this.title,
    this.icon,
  }) : assert(tabTitles.length == tabViews.length);

  @override
  State<TabbedCard> createState() => _TabbedCardState();
}

class _TabbedCardState extends State<TabbedCard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 28, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                ],
                Text(widget.title, style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: widget.tabTitles.map((title) => Tab(text: title)).toList(),
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: AppTheme.secondaryColor,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          const Divider(height: 1, thickness: 1),
          SizedBox(
            height: 800,
            child: TabBarView(
              controller: _tabController,
              children: widget.tabViews,
            ),
          ),
        ],
      ),
    );
  }
}