class TicketModel {
  final String id;
  final String orderId;
  final String status;
  final String qrCode;
  final String pdfUrl;

  TicketModel({
    required this.id,
    required this.orderId,
    required this.status,
    required this.qrCode,
    required this.pdfUrl,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? '',
      qrCode: json['qrCode'] ?? '',
      pdfUrl: json['pdfUrl'] ?? '',
    );
  }
}
