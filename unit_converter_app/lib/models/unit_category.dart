class UnitCategory {
  final String name;
  final String icon;
  final List<Unit> units;

  UnitCategory({
    required this.name,
    required this.icon,
    required this.units,
  });
}

class Unit {
  final String name;
  final String symbol;
  final double baseValue; // Value in terms of the base unit

  Unit({
    required this.name,
    required this.symbol,
    required this.baseValue,
  });
}