import 'template.dart';

abstract class TemplateEvent {}

class LoadTemplatesEvent extends TemplateEvent {}

class AddTemplateEvent extends TemplateEvent {
  final Template template;
  AddTemplateEvent(this.template);
}

class DeleteTemplateEvent extends TemplateEvent {
  final String id;
  DeleteTemplateEvent(this.id);
}

class SyncTemplatesUpdateEvent extends TemplateEvent {
  final List<Template> templates;
  SyncTemplatesUpdateEvent(this.templates);
}