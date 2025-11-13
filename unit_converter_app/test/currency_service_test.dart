import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter_app/services/currency_service.dart';

void main() {
  test('Currency service returns predefined currencies', () {
    final currencies = CurrencyService.getCurrencies();
    
    expect(currencies.length, 5);
    expect(currencies[0].code, 'USD');
    expect(currencies[1].code, 'EUR');
    expect(currencies[2].code, 'GBP');
    expect(currencies[3].code, 'JPY');
    expect(currencies[4].code, 'INR');
  });
  
  test('Currency conversion works with fallback rates', () async {
    // Test USD to EUR conversion using fallback rates
    final result = await CurrencyService.convertCurrency(100, 'USD', 'EUR');
    
    // Should be around 85 with our fallback rates
    expect(result, greaterThan(80));
    expect(result, lessThan(90));
  });
  
  test('Currency conversion handles same currency', () async {
    final result = await CurrencyService.convertCurrency(100, 'USD', 'USD');
    expect(result, 100);
  });
}