import 'package:flutter/material.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';
import '../widgets/conversion_input.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  late Currency _fromCurrency;
  late Currency _toCurrency;
  String _inputValue = '';
  String _outputValue = '';
  bool _isLoading = false;
  String _errorMessage = '';
  bool _usingFallbackRates = false;

  @override
  void initState() {
    super.initState();
    final currencies = CurrencyService.getCurrencies();
    _fromCurrency = currencies.first;
    _toCurrency = currencies[1];
  }

  Future<void> _convert() async {
    if (_inputValue.isEmpty) {
      setState(() {
        _outputValue = '';
        _errorMessage = '';
        _usingFallbackRates = false;
      });
      return;
    }

    final amount = double.tryParse(_inputValue);
    if (amount == null) {
      setState(() {
        _errorMessage = 'Please enter a valid number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _usingFallbackRates = false;
    });

    try {
      final result = await CurrencyService.convertCurrency(
        amount,
        _fromCurrency.code,
        _toCurrency.code,
      );

      setState(() {
        _outputValue = result.toStringAsFixed(2);
        _isLoading = false;
        _usingFallbackRates = false;
      });
    } catch (e) {
      // Try with fallback rates
      try {
        final result = await CurrencyService.convertCurrency(
          amount,
          _fromCurrency.code,
          _toCurrency.code,
        );

        setState(() {
          _outputValue = result.toStringAsFixed(2);
          _isLoading = false;
          _usingFallbackRates = true;
          _errorMessage = 'Using estimated rates (API unavailable)';
        });
      } catch (fallbackError) {
        setState(() {
          _errorMessage = 'Conversion failed. Please check your connection and try again.';
          _isLoading = false;
          _outputValue = '';
          _usingFallbackRates = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencies = CurrencyService.getCurrencies();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Currency icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '💱',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // From currency input
            ConversionInput(
              label: 'From',
              value: _inputValue,
              onChanged: (value) {
                setState(() {
                  _inputValue = value;
                });
                _convert();
              },
            ),
            const SizedBox(height: 20),
            
            // From currency dropdown
            _buildCurrencyDropdown(
              label: 'Currency',
              selectedCurrency: _fromCurrency,
              currencies: currencies,
              onChanged: (currency) {
                setState(() {
                  _fromCurrency = currency;
                });
                _convert();
              },
            ),
            const SizedBox(height: 30),
            
            // Swap button
            Center(
              child: IconButton(
                icon: const Icon(Icons.swap_vert, size: 30, color: Colors.blue),
                onPressed: () {
                  setState(() {
                    final temp = _fromCurrency;
                    _fromCurrency = _toCurrency;
                    _toCurrency = temp;
                    final tempValue = _inputValue;
                    _inputValue = _outputValue;
                    _outputValue = tempValue;
                  });
                  _convert();
                },
              ),
            ),
            const SizedBox(height: 30),
            
            // To currency input (read-only)
            ConversionInput(
              label: 'To',
              value: _outputValue,
              onChanged: (_) {},
              enabled: false,
            ),
            const SizedBox(height: 20),
            
            // To currency dropdown
            _buildCurrencyDropdown(
              label: 'Currency',
              selectedCurrency: _toCurrency,
              currencies: currencies,
              onChanged: (currency) {
                setState(() {
                  _toCurrency = currency;
                });
                _convert();
              },
            ),
            const SizedBox(height: 20),
            
            // Loading indicator
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Fetching latest rates...'),
                  ],
                ),
              ),
            
            // Fallback rates notice
            if (_usingFallbackRates)
              const Center(
                child: Text(
                  'Using estimated rates (API unavailable)',
                  style: TextStyle(color: Colors.orange, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            
            // Error message
            if (_errorMessage.isNotEmpty && !_usingFallbackRates)
              Center(
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Information text
            const Center(
              child: Text(
                'Rates update daily',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required String label,
    required Currency selectedCurrency,
    required List<Currency> currencies,
    required Function(Currency) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Currency>(
              value: selectedCurrency,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
              items: currencies.map((Currency currency) {
                return DropdownMenuItem<Currency>(
                  value: currency,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currency.name,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        currency.code,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Currency? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}