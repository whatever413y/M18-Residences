class Reading {
  final int id;
  final int prevReading;
  final int currReading;
  final int consumption;
  final DateTime createdAt;

  Reading({
    required this.id,
    required this.prevReading,
    required this.currReading,
    required this.consumption,
    required this.createdAt,
  });
}
