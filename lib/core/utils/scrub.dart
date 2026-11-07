String scrubSensitive(String text) {
  var out = text;
  for (final rule in _rules) {
    out = out.replaceAllMapped(rule.pattern, (m) => rule.replace(m));
  }
  return out;
}

class _Rule {
  const _Rule(this.pattern, this.replace);

  final Pattern pattern;
  final String Function(Match match) replace;
}

final _rules = <_Rule>[
  _Rule(
    RegExp(
      r'[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(?:\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}',
    ),
    (_) => '[email]',
  ),
  _Rule(RegExp(r'Bearer\s+[A-Za-z0-9._~+/=\-]+'), (_) => 'Bearer [token]'),
  _Rule(
    RegExp(r'eyJ[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]*'),
    (_) => '[jwt]',
  ),
  _Rule(
    RegExp(
      r'LPA:1\$[^\s"'
      "'"
      r']+',
      caseSensitive: false,
    ),
    (_) => '[lpa]',
  ),
  _Rule(
    RegExp(
      r'(carddata|code|token|accessToken|refreshToken|activationCode|'
      r'deviceToken|password)=[^&\s"'
      "'"
      r']+',
      caseSensitive: false,
    ),
    (m) => '${m.group(1)}=[redacted]',
  ),
];
