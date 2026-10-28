String deviceModelName(String rawModel) {
  final model = rawModel.trim();
  switch (model.toLowerCase()) {
    case 'iphone11,2':
      return 'iPhone XS';
    case 'iphone11,4':
    case 'iphone11,6':
      return 'iPhone XS Max';
    case 'iphone11,8':
      return 'iPhone XR';
  }
  final samsungModel = model
      .replaceFirst(RegExp(r'^samsung\s+', caseSensitive: false), '')
      .toUpperCase();
  if (RegExp(r'^SM-A346[BE](?:/DSN?|/N)?$').hasMatch(samsungModel)) {
    return 'Galaxy A34';
  }
  return model;
}
