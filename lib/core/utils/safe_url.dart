/// Links that arrive from the server (checkout page, store page, eSIM
/// installer) are data, not code. They are opened only when they are plain
/// `https` URLs with a host — never `javascript:`, `intent:`, `file:` or a
/// custom scheme that would hand the customer to another app.
Uri? safeHttpsUri(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
  if (uri.userInfo.isNotEmpty) return null;
  return uri;
}

/// Same as [safeHttpsUri], and the host must be [host] (or a subdomain of it).
Uri? safeHttpsUriOn(String? raw, String host) {
  final uri = safeHttpsUri(raw);
  if (uri == null) return null;
  final h = uri.host.toLowerCase();
  return h == host || h.endsWith('.$host') ? uri : null;
}
