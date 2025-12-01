import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../misc/template/template_card.dart';
// import '../misc/template/template_service.dart'; // NO LONGER DIRECTLY USED
import '../misc/template/template_providers.dart';
import 'create_template_page.dart';
import '../../charts/calories_chart.dart';
import '../../charts/muscle_groups_chart.dart';
import '../../charts/body_tracker_chart.dart';


class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // ADD WidgetRef ref
    
    // WATCH: Listen to the merged list of templates (Base + Custom from Hive)
    final allTemplatesAsync = ref.watch(allTemplatesProvider);

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

                  allTemplatesAsync.when(
                    loading: () => const Center(child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    )),
                    error: (err, stack) => Center(child: Text('Error loading templates: $err')),
                    data: (allTemplates) {
                      
                      final baseTemplatesList = allTemplates.where((t) => !t.isCustom).toList();
                      final userTemplatesList = allTemplates.where((t) => t.isCustom).toList();
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ----- BASE TEMPLATES -----
                          ...baseTemplatesList.map(
                            (t) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TemplateCard(template: t),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // ----- USER TEMPLATES -----
                          if (userTemplatesList.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Your Templates',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),

                            ...userTemplatesList.map(
                              (t) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TemplateCard(template: t),
                              ),
                            ),
                          ],
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