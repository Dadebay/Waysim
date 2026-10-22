import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';

class NotificationPrefs extends Equatable {
  const NotificationPrefs({this.esim = true, this.news = true, this.failure});
  final Failure? failure;

  /// eSIM status, balance and data-usage notifications.
  final bool esim;

  /// News and offers.
  final bool news;

  NotificationPrefs copyWith({bool? esim, bool? news}) =>
      NotificationPrefs(esim: esim ?? this.esim, news: news ?? this.news);

  @override
  List<Object?> get props => [esim, news, failure];
}

/// The two switches in Settings. Persisted here; once push is wired
/// (docs/06-roadmap.md T5.4) a change is also sent to the server and turns
/// the FCM topics on or off.
class NotificationPrefsCubit extends HydratedCubit<NotificationPrefs> {
  NotificationPrefsCubit({this.save}) : super(const NotificationPrefs());
  final Future<Result<void>> Function(bool esim, bool marketing)? save;
  Future<void> _pending = Future.value();
  int _generation = 0;

  void applyServerPreferences(NotificationPrefs prefs) => emit(prefs);

  void setEsim(bool value) => _update(state.copyWith(esim: value));
  void setNews(bool value) => _update(state.copyWith(news: value));
  void _update(NotificationPrefs next) {
    final before = state;
    final generation = ++_generation;
    emit(next);
    final persist = save;
    if (persist == null) return;
    _pending = _pending.then((_) async {
      final result = await persist(next.esim, next.news);
      if (isClosed || generation != _generation) return;
      if (result case Error(:final failure)) {
        emit(
          NotificationPrefs(
            esim: before.esim,
            news: before.news,
            failure: failure,
          ),
        );
      }
    });
  }

  @override
  NotificationPrefs? fromJson(Map<String, dynamic> json) => NotificationPrefs(
    esim: json['esim'] as bool? ?? true,
    news: json['news'] as bool? ?? true,
  );

  @override
  Map<String, dynamic>? toJson(NotificationPrefs state) => {
    'esim': state.esim,
    'news': state.news,
  };
}
