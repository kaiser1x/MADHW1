import 'package:flutter/material.dart';

void main() => runApp(const CalculatorTemplateApp());

class CalculatorTemplateApp extends StatelessWidget {
  const CalculatorTemplateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator Template',
      theme: ThemeData(useMaterial3: true),
      home: const CalculatorTemplatePage(),
    );
  }
}

class CalculatorTemplatePage extends StatefulWidget {
  const CalculatorTemplatePage({super.key});

  @override
  State<CalculatorTemplatePage> createState() => _CalculatorTemplatePageState();
}

class _CalculatorTemplatePageState extends State<CalculatorTemplatePage> {
  String display = "0";

  // For + and −
  double? _first;
  String? _op; // "+" or "−"
  bool _startNewNumber = true; // when true, next digit replaces display

  void _clearAll() {
    display = "0";
    _first = null;
    _op = null;
    _startNewNumber = true;
  }

  double _asNumber(String s) {
    // Safe parse for display text
    return double.tryParse(s) ?? 0.0;
  }

  String _formatNumber(double n) {
    // Remove trailing .0 (e.g., 8.0 -> "8")
    if (n % 1 == 0) return n.toInt().toString();
    return n.toString();
  }

  void _backspace() {
    if (_startNewNumber) return;

    if (display.length <= 1) {
      display = "0";
      _startNewNumber = true;
      return;
    }

    display = display.substring(0, display.length - 1);

    // If user deletes down to "-" or empty-ish, reset nicely
    if (display == "-" || display.isEmpty) {
      display = "0";
      _startNewNumber = true;
    }
  }

  void _appendDigit(String digit) {
    if (_startNewNumber) {
      display = digit;
      _startNewNumber = false;
      return;
    }

    if (display == "0") {
      display = digit;
    } else {
      display += digit;
    }
  }

  void _appendDot() {
    if (_startNewNumber) {
      display = "0.";
      _startNewNumber = false;
      return;
    }

    // Prevent multiple dots in the current number
    if (!display.contains('.')) {
      display += '.';
    }
  }

  void _setOperator(String op) {
    // Only implement + and − for now
    if (op != "+" && op != "−") return;

    // If we already have an operator and user presses another operator
    // (and they have typed a second number), compute first to chain operations.
    if (_first != null && _op != null && !_startNewNumber) {
      _computeEquals();
    }

    _first ??= _asNumber(display);
    _op = op;
    _startNewNumber = true;
  }

  void _computeEquals() {
    if (_first == null || _op == null) return;

    final second = _asNumber(display);
    double result = _first!;

    if (_op == "+") {
      result = _first! + second;
    } else if (_op == "−") {
      result = _first! - second;
    }

    display = _formatNumber(result);

    // Reset operator state after equals
    _first = null;
    _op = null;
    _startNewNumber = true;
  }

  void onKeyTap(String key) {
    setState(() {
      // Clear
      if (key == "C") {
        _clearAll();
        return;
      }

      // Backspace
      if (key == "⌫") {
        _backspace();
        return;
      }

      // Equals
      if (key == "=") {
        _computeEquals();
        return;
      }

      // Dot
      if (key == ".") {
        _appendDot();
        return;
      }

      // Operators (+ and − only)
      if (key == "+" || key == "−") {
        _setOperator(key);
        return;
      }

      // Ignore other operators for now (÷, ×, %, etc.)
      if (key == "÷" || key == "×" || key == "%") {
        return;
      }

      // Digits 0-9
      if (RegExp(r'^[0-9]$').hasMatch(key)) {
        _appendDigit(key);
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const gap = 10.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator (Template)'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // DISPLAY
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black12,
                ),
                child: Text(
                  display,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 16),

              // KEYPAD
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _CalcButton(label: 'C', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          _CalcButton(label: '⌫', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          _CalcButton(label: '%', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          _CalcButton(label: '÷', onTap: onKeyTap, isOp: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: gap),
                    Expanded(
                      child: Row(
                        children: [
                          _CalcButton(label: '7', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          _CalcButton(label: '8', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          _CalcButton(label: '9', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          _CalcButton(label: '×', onTap: onKeyTap, isOp: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: gap),
                    Expanded(
                      child: Row(
                        children: [
                          _CalcButton(label: '4', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          _CalcButton(label: '5', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          _CalcButton(label: '6', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          _CalcButton(label: '−', onTap: onKeyTap, isOp: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: gap),
                    Expanded(
                      child: Row(
                        children: [
                          _CalcButton(label: '1', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          _CalcButton(label: '2', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          _CalcButton(label: '3', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          _CalcButton(label: '+', onTap: onKeyTap, isOp: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: gap),
                    Expanded(
                      child: Row(
                        children: [
                          // Make "0" wider like a real calculator
                          Expanded(
                            flex: 2,
                            child: _CalcButton(label: '0', onTap: onKeyTap),
                          ),
                          const SizedBox(width: gap),
                          Expanded(
                            child: _CalcButton(label: '.', onTap: onKeyTap),
                          ),
                          const SizedBox(width: gap),
                          Expanded(
                            child: _CalcButton(
                              label: '=',
                              onTap: onKeyTap,
                              isEquals: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalcButton extends StatelessWidget {
  final String label;
  final void Function(String) onTap;
  final bool isOp;
  final bool isEquals;

  const _CalcButton({
    required this.label,
    required this.onTap,
    this.isOp = false,
    this.isEquals = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isEquals
        ? Colors.blue
        : isOp
            ? Colors.orange
            : Colors.black12;

    final fg = isEquals || isOp ? Colors.white : Colors.black;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(label),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}