Uri? safeHttpsUri(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
  if (uri.userInfo.isNotEmpty) return null;
  return uri;
}

Uri? safeHttpsUriOn(String? raw, String host) {
  final uri = safeHttpsUri(raw);
  if (uri == null) return null;
  final h = uri.host.toLowerCase();
  return h == host || h.endsWith('.$host') ? uri : null;
}
