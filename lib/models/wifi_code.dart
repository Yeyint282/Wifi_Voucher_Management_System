class WifiCode {
  final String id;
  final String code;
  final String duration;
  final String wifiName;
  final String fontColor;
  final String createdAt;
  int usageCount;

  WifiCode({
    required this.id,
    required this.code,
    required this.duration,
    required this.wifiName,
    required this.fontColor,
    required this.createdAt,
    this.usageCount = 0,
  });

  factory WifiCode.fromJson(Map<String, dynamic> json) {
    return WifiCode(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      code: json['code'] ?? '',
      duration: json['duration'] ?? '',
      wifiName: json['wifiName'] ?? 'Ko Htet WIFI',
      fontColor: json['fontColor'] ?? '#ff0000',
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      usageCount: json['usageCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'duration': duration,
      'wifiName': wifiName,
      'fontColor': fontColor,
      'createdAt': createdAt,
      'usageCount': usageCount,
    };
  }

  WifiCode copyWith({
    String? id,
    String? code,
    String? duration,
    String? wifiName,
    String? fontColor,
    String? createdAt,
    int? usageCount,
  }) {
    return WifiCode(
      id: id ?? this.id,
      code: code ?? this.code,
      duration: duration ?? this.duration,
      wifiName: wifiName ?? this.wifiName,
      fontColor: fontColor ?? this.fontColor,
      createdAt: createdAt ?? this.createdAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}
