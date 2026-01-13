import 'template.dart';

enum TemplateStatus { initial, loading, success, error }

class TemplateState {
  final List<Template> customTemplates;
  final List<Template> allTemplates;
  final TemplateStatus status;
  final String? errorMessage;

  TemplateState({
    this.customTemplates = const [],
    this.allTemplates = const [],
    this.status = TemplateStatus.initial,
    this.errorMessage,
  });

  TemplateState copyWith({
    List<Template>? customTemplates,
    List<Template>? allTemplates,
    TemplateStatus? status,
    String? errorMessage,
  }) {
    return TemplateState(
      customTemplates: customTemplates ?? this.customTemplates,
      allTemplates: allTemplates ?? this.allTemplates,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}