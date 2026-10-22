class CatalogBanner {
  const CatalogBanner({
    required this.id,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.link,
  });
  final String id;
  final String imageUrl;
  final double width;
  final double height;
  final String? link;
}
