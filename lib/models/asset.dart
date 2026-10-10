class MetroAsset {
  final String id; // e.g. "L-05"
  final String name; // e.g. "Lift L-05"
  final String type; // e.g. "Lift", "Escalator", "Gate", "TVM"
  final String station; // e.g. "Thaltej"
  final String location; // e.g. "Platform 1"
  final String icon; // emoji or icon code

  const MetroAsset({
    required this.id,
    required this.name,
    required this.type,
    required this.station,
    required this.location,
    required this.icon,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'station': station,
        'location': location,
        'icon': icon,
      };

  factory MetroAsset.fromMap(Map<String, dynamic> map) => MetroAsset(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        type: map['type'] ?? '',
        station: map['station'] ?? '',
        location: map['location'] ?? '',
        icon: map['icon'] ?? '⚙️',
      );
}
