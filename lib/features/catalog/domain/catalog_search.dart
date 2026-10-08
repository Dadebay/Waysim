import 'entities/destination.dart';

/// Instant, offline search over the cached catalog.
///
/// Matches from the first letter, in every language the catalog carries, plus
/// aliases and country codes ("USA", "US", "США"). Prefix matches rank above
/// substring matches; countries rank above regions on a tie.
abstract final class CatalogSearch {
  static List<SearchHit> search(
    List<Destination> destinations,
    String query, {
    required String language,
  }) {
    final needle = normalize(query);
    if (needle.isEmpty) return const [];

    final hits = <SearchHit>[];
    for (final d in destinations) {
      final hit = _match(d, needle, language);
      if (hit != null) hits.add(hit);
    }
    hits.sort((a, b) {
      final byScore = a.score.compareTo(b.score);
      if (byScore != 0) return byScore;
      if (a.destination.isRegion != b.destination.isRegion) {
        return a.destination.isRegion ? 1 : -1;
      }
      return normalize(
        a.destination.nameFor(language),
      ).compareTo(normalize(b.destination.nameFor(language)));
    });
    return hits;
  }

  static SearchHit? _match(Destination d, String needle, String language) {
    final shown = normalize(d.nameFor(language));
    // Lower score = better. Name in the app language first.
    if (shown.startsWith(needle)) {
      return SearchHit(d, 0, highlight: needle.length);
    }
    for (final name in d.names.values) {
      if (normalize(name).startsWith(needle)) return SearchHit(d, 1);
    }
    if (normalize(d.code) == needle) return SearchHit(d, 1);
    for (final alias in d.aliases) {
      if (normalize(alias).startsWith(needle)) return SearchHit(d, 2);
    }
    for (final name in [d.nameFor(language), ...d.names.values]) {
      final n = normalize(name);
      // A word inside the name: "Emirates" finds "United Arab Emirates".
      if (n.split(' ').any((w) => w.startsWith(needle))) {
        return SearchHit(d, 3);
      }
    }
    return null;
  }

  /// Lowercase, no diacritics, `ё` as `е`, single spaces.
  static String normalize(String input) {
    final lower = input.toLowerCase().trim();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final ch = String.fromCharCode(rune);
      buffer.write(_fold[ch] ?? ch);
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
  }

  static const _fold = {
    'ё': 'е',
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'ã': 'a',
    'å': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'ö': 'o',
    'õ': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ñ': 'n',
    'ç': 'c',
    'ş': 's',
    'ğ': 'g',
    'ı': 'i',
  };
}

class SearchHit {
  const SearchHit(this.destination, this.score, {this.highlight});

  final Destination destination;

  /// 0 best … 3 weakest.
  final int score;

  /// Length of the typed prefix to emphasise in the displayed name, when the
  /// match was on that name.
  final int? highlight;
}
