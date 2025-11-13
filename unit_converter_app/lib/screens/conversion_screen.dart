import 'package:flutter/material.dart';
import '../models/unit_category.dart';
import '../utils/converter.dart';
import '../widgets/unit_dropdown.dart';
import '../widgets/conversion_input.dart';

class ConversionScreen extends StatefulWidget {
  final UnitCategory category;

  const ConversionScreen({super.key, required this.category});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  late Unit _fromUnit;
  late Unit _toUnit;
  String _inputValue = '';
  String _outputValue = '';

  @override
  void initState() {
    super.initState();
    _fromUnit = widget.category.units.first;
    _toUnit = widget.category.units[1];
    _convert();
  }

  void _convert() {
    if (_inputValue.isEmpty) {
      setState(() {
        _outputValue = '';
      });
      return;
    }

    double inputValue = double.tryParse(_inputValue) ?? 0.0;
    double result;

    // Special handling for temperature
    if (widget.category.name == 'Temperature') {
      result = Converter.convertTemperature(inputValue, _fromUnit, _toUnit);
    } else {
      result = Converter.convert(inputValue, _fromUnit, _toUnit);
    }

    setState(() {
      _outputValue = result.toStringAsPrecision(10);
      // Remove trailing zeros
      if (_outputValue.contains('.')) {
        _outputValue = _outputValue.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  widget.category.icon,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // From unit input
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
            
            // From unit dropdown
            UnitDropdown(
              label: 'Unit',
              selectedUnit: _fromUnit,
              units: widget.category.units,
              onChanged: (unit) {
                setState(() {
                  _fromUnit = unit;
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
                    final temp = _fromUnit;
                    _fromUnit = _toUnit;
                    _toUnit = temp;
                    final tempValue = _inputValue;
                    _inputValue = _outputValue;
                    _outputValue = tempValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 30),
            
            // To unit input (read-only)
            ConversionInput(
              label: 'To',
              value: _outputValue,
              onChanged: (_) {},
              enabled: false,
            ),
            const SizedBox(height: 20),
            
            // To unit dropdown
            UnitDropdown(
              label: 'Unit',
              selectedUnit: _toUnit,
              units: widget.category.units,
              onChanged: (unit) {
                setState(() {
                  _toUnit = unit;
                });
                _convert();
              },
            ),
          ],
        ),
      ),
    );
  }
}