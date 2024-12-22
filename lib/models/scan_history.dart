class ScanHistory {
  final String productName;
  final DateTime date;
  final String status;
  final String? location;
  final String? scanType;

  ScanHistory({
    required this.productName,
    required this.date,
    required this.status,
    this.location,
    this.scanType = 'QR Code',
  });

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }
}
