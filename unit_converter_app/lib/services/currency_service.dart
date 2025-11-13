import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency.dart';

class CurrencyService {
  static const String _apiKey = 'f186da11b83174d245ffa3b69326e1ec';
  static const String _baseUrl = 'http://api.exchangerate.host/live';
  
  // Fallback rates for offline use or API errors
  static final Map<String, Map<String, double>> _fallbackRates = {
    'USD': {
      'EUR': 0.85,
      'GBP': 0.73,
      'JPY': 110.0,
      'INR': 73.0,
    },
    'EUR': {
      'USD': 1.18,
      'GBP': 0.86,
      'JPY': 129.0,
      'INR': 85.0,
    },
    'GBP': {
      'USD': 1.37,
      'EUR': 1.16,
      'JPY': 150.0,
      'INR': 99.0,
    },
    'JPY': {
      'USD': 0.0091,
      'EUR': 0.0078,
      'GBP': 0.0067,
      'INR': 0.66,
    },
    'INR': {
      'USD': 0.014,
      'EUR': 0.012,
      'GBP': 0.010,
      'JPY': 1.5,
    },
  };

  // Predefined currencies
  static List<Currency> getCurrencies() {
    return [
      Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
      Currency(code: 'EUR', name: 'Euro', symbol: '€'),
      Currency(code: 'GBP', name: 'British Pound', symbol: '£'),
      Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
      Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
    ];
  }

  // Fetch exchange rates from the API
  static Future<Map<String, double>> getExchangeRates(String baseCurrency) async {
    try {
      // Format the currencies parameter
      final currencies = getCurrencies().map((c) => c.code).join(',');
      
      final response = await http.get(
        Uri.parse('$_baseUrl?access_key=$_apiKey&source=$baseCurrency&currencies=$currencies&format=1'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Map<String, double>.from(data['quotes']);
        } else {
          // Use fallback rates if API returns an error
          return _fallbackRates[baseCurrency] ?? {};
        }
      } else {
        // Use fallback rates if HTTP request fails
        return _fallbackRates[baseCurrency] ?? {};
      }
    } catch (e) {
      // Use fallback rates if network request fails
      return _fallbackRates[baseCurrency] ?? {};
    }
  }

  // Convert currency
  static Future<double> convertCurrency(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async {
    if (fromCurrency == toCurrency) return amount;

    try {
      final rates = await getExchangeRates(fromCurrency);
      
      // The API returns rates in the format "FROMTO" (e.g., "USDGBP")
      final rateKey = '$fromCurrency$toCurrency';
      double? rate = rates[rateKey];
      
      // If direct rate not found, try to get reverse rate
      if (rate == null) {
        final reverseRates = await getExchangeRates(toCurrency);
        final reverseRateKey = '$toCurrency$fromCurrency';
        final reverseRate = reverseRates[reverseRateKey];
        
        if (reverseRate != null) {
          return amount / reverseRate;
        }
        
        // Use fallback rate
        final fallbackRate = _fallbackRates[fromCurrency]?[toCurrency];
        if (fallbackRate != null) {
          return amount * fallbackRate;
        }
        
        throw Exception('Exchange rate not found for $fromCurrency to $toCurrency');
      }
      
      return amount * rate;
    } catch (e) {
      // Try one more fallback approach
      final fallbackRate = _fallbackRates[fromCurrency]?[toCurrency];
      if (fallbackRate != null) {
        return amount * fallbackRate;
      }
      
      throw Exception('Conversion failed: $e');
    }
  }
}