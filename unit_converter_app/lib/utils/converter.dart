import '../models/unit_category.dart';

class Converter {
  static double convert(double value, Unit fromUnit, Unit toUnit) {
    // Convert to base unit first
    double baseValue = value * fromUnit.baseValue;
    
    // Convert from base unit to target unit
    double result = baseValue / toUnit.baseValue;
    
    return result;
  }
  
  // Predefined unit categories with their units
  static List<UnitCategory> getCategories() {
    return [
      UnitCategory(
        name: 'Length',
        icon: '📏',
        units: [
          Unit(name: 'Millimeter', symbol: 'mm', baseValue: 0.001),
          Unit(name: 'Centimeter', symbol: 'cm', baseValue: 0.01),
          Unit(name: 'Meter', symbol: 'm', baseValue: 1.0),
          Unit(name: 'Kilometer', symbol: 'km', baseValue: 1000.0),
          Unit(name: 'Inch', symbol: 'in', baseValue: 0.0254),
          Unit(name: 'Foot', symbol: 'ft', baseValue: 0.3048),
          Unit(name: 'Yard', symbol: 'yd', baseValue: 0.9144),
          Unit(name: 'Mile', symbol: 'mi', baseValue: 1609.344),
        ],
      ),
      UnitCategory(
        name: 'Weight',
        icon: '⚖️',
        units: [
          Unit(name: 'Milligram', symbol: 'mg', baseValue: 0.000001),
          Unit(name: 'Gram', symbol: 'g', baseValue: 0.001),
          Unit(name: 'Kilogram', symbol: 'kg', baseValue: 1.0),
          Unit(name: 'Metric Ton', symbol: 't', baseValue: 1000.0),
          Unit(name: 'Ounce', symbol: 'oz', baseValue: 0.0283495),
          Unit(name: 'Pound', symbol: 'lb', baseValue: 0.453592),
          Unit(name: 'Stone', symbol: 'st', baseValue: 6.35029),
        ],
      ),
      UnitCategory(
        name: 'Temperature',
        icon: '🌡️',
        units: [
          Unit(name: 'Celsius', symbol: '°C', baseValue: 1.0),
          Unit(name: 'Fahrenheit', symbol: '°F', baseValue: 1.0),
          Unit(name: 'Kelvin', symbol: 'K', baseValue: 1.0),
        ],
      ),
      UnitCategory(
        name: 'Area',
        icon: '📐',
        units: [
          Unit(name: 'Square Millimeter', symbol: 'mm²', baseValue: 0.000001),
          Unit(name: 'Square Centimeter', symbol: 'cm²', baseValue: 0.0001),
          Unit(name: 'Square Meter', symbol: 'm²', baseValue: 1.0),
          Unit(name: 'Hectare', symbol: 'ha', baseValue: 10000.0),
          Unit(name: 'Square Kilometer', symbol: 'km²', baseValue: 1000000.0),
          Unit(name: 'Square Inch', symbol: 'in²', baseValue: 0.00064516),
          Unit(name: 'Square Foot', symbol: 'ft²', baseValue: 0.092903),
          Unit(name: 'Square Yard', symbol: 'yd²', baseValue: 0.836127),
          Unit(name: 'Acre', symbol: 'ac', baseValue: 4046.86),
          Unit(name: 'Square Mile', symbol: 'mi²', baseValue: 2589988.11),
        ],
      ),
      UnitCategory(
        name: 'Volume',
        icon: '💧',
        units: [
          Unit(name: 'Milliliter', symbol: 'mL', baseValue: 0.001),
          Unit(name: 'Liter', symbol: 'L', baseValue: 1.0),
          Unit(name: 'Cubic Meter', symbol: 'm³', baseValue: 1000.0),
          Unit(name: 'Teaspoon', symbol: 'tsp', baseValue: 0.00492892),
          Unit(name: 'Tablespoon', symbol: 'tbsp', baseValue: 0.0147868),
          Unit(name: 'Fluid Ounce', symbol: 'fl oz', baseValue: 0.0295735),
          Unit(name: 'Cup', symbol: 'cup', baseValue: 0.24),
          Unit(name: 'Pint', symbol: 'pt', baseValue: 0.473176),
          Unit(name: 'Quart', symbol: 'qt', baseValue: 0.946353),
          Unit(name: 'Gallon', symbol: 'gal', baseValue: 3.78541),
        ],
      ),
      UnitCategory(
        name: 'Time',
        icon: '⏱️',
        units: [
          Unit(name: 'Millisecond', symbol: 'ms', baseValue: 0.001),
          Unit(name: 'Second', symbol: 's', baseValue: 1.0),
          Unit(name: 'Minute', symbol: 'min', baseValue: 60.0),
          Unit(name: 'Hour', symbol: 'hr', baseValue: 3600.0),
          Unit(name: 'Day', symbol: 'd', baseValue: 86400.0),
          Unit(name: 'Week', symbol: 'wk', baseValue: 604800.0),
          Unit(name: 'Month', symbol: 'mo', baseValue: 2628000.0),
          Unit(name: 'Year', symbol: 'yr', baseValue: 31536000.0),
        ],
      ),
    ];
  }
  
  // Special conversion for temperature
  static double convertTemperature(double value, Unit fromUnit, Unit toUnit) {
    if (fromUnit.name == toUnit.name) return value;
    
    // Convert to Celsius first
    double celsius;
    if (fromUnit.name == 'Celsius') {
      celsius = value;
    } else if (fromUnit.name == 'Fahrenheit') {
      celsius = (value - 32) * 5/9;
    } else { // Kelvin
      celsius = value - 273.15;
    }
    
    // Convert from Celsius to target unit
    if (toUnit.name == 'Celsius') {
      return celsius;
    } else if (toUnit.name == 'Fahrenheit') {
      return (celsius * 9/5) + 32;
    } else { // Kelvin
      return celsius + 273.15;
    }
  }
}
