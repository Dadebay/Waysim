import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class NotificationPrefs extends Equatable {
  const NotificationPrefs({this.esim = true, this.news = true});

  /// eSIM status, balance and data-usage notifications.
  final bool esim;

  /// News and offers.
  final bool news;

  NotificationPrefs copyWith({bool? esim, bool? news}) =>
      NotificationPrefs(esim: esim ?? this.esim, news: news ?? this.news);

  @override
  List<Object?> get props => [esim, news];
}

/// The two switches in Settings. Persisted here; once push is wired
/// (docs/06-roadmap.md T5.4) a change is also sent to the server and turns
/// the FCM topics on or off.
class NotificationPrefsCubit extends HydratedCubit<NotificationPrefs> {
  NotificationPrefsCubit() : super(const NotificationPrefs());

  void setEsim(bool value) => emit(state.copyWith(esim: value));
  void setNews(bool value) => emit(state.copyWith(news: value));

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
