import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../misc/template/template_card.dart';
import '../misc/template/template_bloc.dart';  
import '../misc/template/template_state.dart';
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
          const SliverAppBar(
            floating: true,
            snap: true,
            title: Text('Dashboard'),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // --- DASHBOARD CHARTS ---
                  _buildChartCard('Calories (last 7 days)', const CaloriesChart()),
                  const SizedBox(height: 12),
                  _buildChartCard('Muscle Groups', const MuscleGroupsChart()),
                  const SizedBox(height: 12),
                  _buildChartCard('Body Tracker', const BodyTrackerChart()),

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

                  BlocBuilder<TemplateBloc, TemplateState>(
                    builder: (context, state) {
                      if (state.status == TemplateStatus.loading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (state.status == TemplateStatus.error) {
                        return Center(
                          child: Text('Error loading templates: ${state.errorMessage}'),
                        );
                      }

                      final allTemplates = state.allTemplates;
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
                          
                          // ----- USER TEMPLATES -----
                          if (userTemplatesList.isNotEmpty) ...[
                            const SizedBox(height: 20),
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

  // Helper method to keep the chart code clean
  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(height: 180, child: chart),
          ],
        ),
      ),
    );
  }
}