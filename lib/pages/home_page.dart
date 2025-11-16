import 'package:flutter/material.dart';
import '../misc/template_card.dart';
import '../misc/template.dart';
import '../content.dart';
import '../misc/template_service.dart';
import 'create_template_page.dart';
import '../../charts/calories_chart.dart';
import '../../charts/muscle_groups_chart.dart';
import '../../charts/body_tracker_chart.dart';

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

                  // ----- CHARTS -----
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Calories (last 7 days)',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
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
                          Text('Muscle Groups',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(height: 12),
                          SizedBox(height: 180, child: MuscleGroupsChart()),
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
                          Text('Body Tracker',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(height: 12),
                          SizedBox(height: 180, child: BodyTrackerChart()),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ----- TEMPLATES HEADER -----
                  const Text(
                    'Available Templates',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),

                  // CREATE BUTTON
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateTemplatePage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Template'),
                    ),
                  ),

                  // ----- BASE TEMPLATES -----
                  ...baseTemplates.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TemplateCard(template: t),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ----- USER TEMPLATES -----
                  StreamBuilder<List<Template>>(
                    stream: TemplateService.userTemplates(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final userTemplates = snapshot.data!;
                      if (userTemplates.isEmpty) {
                        return const SizedBox();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          const Text(
                            'Your Templates',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),

                          ...userTemplates.map(
                            (t) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TemplateCard(template: t),
                            ),
                          ),
                        ],
                      );
                    },
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
