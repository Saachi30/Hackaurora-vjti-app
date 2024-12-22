class Product {
  final String id;
  final String name;
  final String category;
  final DateTime? manufacturingDate;
  final String? manufacturer;
  final List<String>? certifications;

  Product({
    required this.id,
    required this.name,
    required this.category,
    this.manufacturingDate,
    this.manufacturer,
    this.certifications,
  });
}