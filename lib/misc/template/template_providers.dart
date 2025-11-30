import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'template.dart';
import '../../local_db.dart';
import 'template_service.dart';
import '../../content.dart';

const _uuid = Uuid();

class TemplateSyncManager {
  final Ref ref;
  TemplateSyncManager(this.ref) {
    ref.listen(remoteTemplatesStreamProvider, (_, next) {
      next.whenData((remoteList) {
        _handleRemoteUpdates(remoteList);
      });
    });
  }

  Future<void> syncNow() async {
    debugPrint("Template Sync Manager: Starting sync operation...");
    final pending = await localDbService.getPendingTemplates();
    
    for (final tpl in pending) {
      try {
        await TemplateService.uploadTemplate(tpl);
        final syncedTpl = tpl.copyWith(syncStatus: 'synced');
        ref.read(customTemplatesProvider.notifier).updateSynced(syncedTpl);
        debugPrint("Template Sync Manager: Uploaded ${tpl.name}");
      } catch (e) {
        debugPrint('Template Sync failed for ${tpl.name}: $e');
      }
    }
  }
  
  void _handleRemoteUpdates(List<Template> remoteList) {
    final localList = ref.read(customTemplatesProvider).value ?? [];
    
    for (final remoteTpl in remoteList) {
      Template? localTpl;
      try {
        localTpl = localList.firstWhere((e) => e.id == remoteTpl.id);
      } catch (e) {
      }
      
      // Simple conflict resolution: remote wins if local doesn't exist or is older
      if (localTpl == null || remoteTpl.updatedAt > (localTpl.updatedAt)) {
        ref.read(customTemplatesProvider.notifier).updateSynced(remoteTpl.copyWith(syncStatus: 'synced'));
      }
    }
  }
}

final templateSyncManagerProvider = Provider((ref) => TemplateSyncManager(ref));

final remoteTemplatesStreamProvider = StreamProvider<List<Template>>((ref) {
  return TemplateService.downloadUserTemplatesStream();
});


// --- STATE NOTIFIER (Custom Templates) ---
class CustomTemplatesNotifier extends AsyncNotifier<List<Template>> {
  
  @override
  Future<List<Template>> build() async {
    return localDbService.getAllTemplates();
  }

  Future<void> add(Template tpl) async {
    final newLocalId = _uuid.v4(); 
    final newLocalTpl = tpl.copyWith(
      id: newLocalId,
      isCustom: true,
      syncStatus: 'pending',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    
    await localDbService.saveTemplate(newLocalTpl);
    state = AsyncData([...(state.value ?? []), newLocalTpl]);
    ref.read(templateSyncManagerProvider).syncNow(); 
  }
  
  Future<void> delete(Template tpl) async {
    if (tpl.id == null) return;
    
    // 1. Updated local DB with soft delete flag
    final deletedTpl = tpl.copyWith(
      isDeleted: true,
      syncStatus: 'pending',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await localDbService.saveTemplate(deletedTpl);

    // 2. Updated state (remove from list immediately for snappy UI)
    state = AsyncData(state.value!.where((e) => e.id != tpl.id).toList());
    
    // 3. Triggered sync to push deletion to Firebase
    ref.read(templateSyncManagerProvider).syncNow();
  }

  // Updated state after sync/remote update
  void updateSynced(Template syncedTpl) {
    if (state.value == null) return;
    
    final newList = state.value!.map((e) {
      return e.id == syncedTpl.id ? syncedTpl : e;
    }).toList();
    
    state = AsyncData(newList);
    localDbService.saveTemplate(syncedTpl);
  }
}

final customTemplatesProvider = AsyncNotifierProvider<CustomTemplatesNotifier, List<Template>>(() => CustomTemplatesNotifier());


final allTemplatesProvider = Provider<AsyncValue<List<Template>>>((ref) {
  final customTemplatesAsync = ref.watch(customTemplatesProvider);
  
  return customTemplatesAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
    data: (customList) => AsyncValue.data([
      ...baseTemplates,
      ...customList,
    ]),
  );
});