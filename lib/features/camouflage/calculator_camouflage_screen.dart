import 'package:flutter/material.dart';

import '../../core/security/pin_service.dart';
import '../auth/pin_lock_screen.dart';
import '../onboarding/onboarding_screen.dart';

class CalculatorCamouflageScreen extends StatefulWidget {
  const CalculatorCamouflageScreen({super.key});

  static const routeName = '/';

  @override
  State<CalculatorCamouflageScreen> createState() => _CalculatorCamouflageScreenState();
}

class _CalculatorCamouflageScreenState extends State<CalculatorCamouflageScreen> {
  final PinService _pinService = PinService();
  String _display = '0';
  String _operator = '';
  double? _left;
  bool _replace = true;

  Future<void> _tap(String value) async {
    if (value == 'C') {
      setState(() {
        _display = '0';
        _operator = '';
        _left = null;
        _replace = true;
      });
      return;
    }
    if (value == '=') {
      await _equals();
      return;
    }
    if ('+-x/'.contains(value)) {
      setState(() {
        _left = double.tryParse(_display) ?? 0;
        _operator = value;
        _replace = true;
      });
      return;
    }
    setState(() {
      if (_replace || _display == '0') {
        _display = value;
        _replace = false;
      } else {
        _display += value;
      }
    });
  }

  Future<void> _equals() async {
    final maybePin = RegExp(r'^\d{4,12}$').hasMatch(_display);
    if (maybePin && await _pinService.hasPin() && await _pinService.verifyPin(_display)) {
      if (!mounted) return;
      await Navigator.of(context).pushNamed(PinLockScreen.routeName);
      return;
    }
    if (maybePin && !await _pinService.hasPin()) {
      if (!mounted) return;
      await Navigator.of(context).pushNamed(OnboardingScreen.routeName);
      return;
    }
    final right = double.tryParse(_display) ?? 0;
    final left = _left ?? right;
    final result = switch (_operator) {
      '+' => left + right,
      '-' => left - right,
      'x' => left * right,
      '/' => right == 0 ? double.nan : left / right,
      _ => right,
    };
    setState(() {
      _display = result.isNaN ? 'Error' : _format(result);
      _operator = '';
      _left = null;
      _replace = true;
    });
  }

  String _format(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(8).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final keys = ['7', '8', '9', '/', '4', '5', '6', 'x', '1', '2', '3', '-', 'C', '0', '=', '+'];
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _display,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w300),
                  ),
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final key = keys[index];
                final isOperator = '+-x/='.contains(key);
                return FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: isOperator ? Colors.deepOrange : const Color(0xFF242424),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _tap(key),
                  child: Text(key, style: const TextStyle(fontSize: 28)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
