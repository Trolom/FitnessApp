import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'template_event.dart';
import 'template_state.dart';
import 'template_service.dart';
import '../../content.dart';

class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  StreamSubscription? _subscription;

  TemplateBloc() : super(TemplateState()) {
    on<LoadTemplatesEvent>(_onLoadTemplates);
    on<AddTemplateEvent>(_onAdd);
    on<DeleteTemplateEvent>(_onDelete);
    on<SyncTemplatesUpdateEvent>(_onSyncUpdate);

    _subscription = TemplateService.streamTemplates().listen((list) {
      add(SyncTemplatesUpdateEvent(list));
    });
  }

  Future<void> _onLoadTemplates(LoadTemplatesEvent event, Emitter<TemplateState> emit) async {
    emit(state.copyWith(status: TemplateStatus.loading));
  }

  Future<void> _onAdd(AddTemplateEvent event, Emitter<TemplateState> emit) async {
    try {
      await TemplateService.saveTemplate(event.template);
    } catch (e) {
      emit(state.copyWith(status: TemplateStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onDelete(DeleteTemplateEvent event, Emitter<TemplateState> emit) async {
    try {
      await TemplateService.deleteTemplate(event.id);
    } catch (e) {
      emit(state.copyWith(status: TemplateStatus.error, errorMessage: e.toString()));
    }
  }

  void _onSyncUpdate(SyncTemplatesUpdateEvent event, Emitter<TemplateState> emit) {
    emit(state.copyWith(
      status: TemplateStatus.success,
      customTemplates: event.templates,
      allTemplates: [...baseTemplates, ...event.templates],
    ));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}