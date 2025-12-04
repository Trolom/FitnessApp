import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'template.dart';
import 'template_service.dart';
import '../../content.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final customTemplatesProvider = StreamProvider<List<Template>>((ref) {
  ref.watch(authStateProvider);
  return TemplateService.streamTemplates();
});

final allTemplatesProvider = Provider<AsyncValue<List<Template>>>((ref) {
  final customAsync = ref.watch(customTemplatesProvider);

  return customAsync.whenData((customList) {
    return [...baseTemplates, ...customList];
  });
});
class TemplateController {
  final Ref ref;
  TemplateController(this.ref);

  Future<void> add(Template tpl) async {
    await TemplateService.saveTemplate(tpl);
  }

  Future<void> delete(String id) async {
    await TemplateService.deleteTemplate(id);
  }
}

final templateControllerProvider = Provider((ref) => TemplateController(ref));