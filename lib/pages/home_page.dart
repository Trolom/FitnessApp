// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../../charts/calories_chart.dart';
import '../../charts/muscle_groups_chart.dart';
import '../../charts/body_tracker_chart.dart';
import '../../template_card.dart';
import '../../mock_data.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('Dashboard'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Calories (last 7 days)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 12),
                          SizedBox(height: 180, child: CaloriesChart()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Muscle Groups',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 12),
                                SizedBox(height: 180, child: MuscleGroupsChart()),
                              ],
                            ),
                          ),
                        ),
                  Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Body Tracker',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 12),
                                SizedBox(height: 180, child: BodyTrackerChart()),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 12),
                  const Text(
                    'Available Templates',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ...mockTemplates.map(
                        (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TemplateCard(template: t),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
