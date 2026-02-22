import 'package:flutter/material.dart';

void main() => runApp(const CalculatorTemplateApp());

class CalculatorTemplateApp extends StatefulWidget {
  const CalculatorTemplateApp({super.key});

  @override
  State<CalculatorTemplateApp> createState() => _CalculatorTemplateAppState();
}

class _CalculatorTemplateAppState extends State<CalculatorTemplateApp> {
  bool _isDark = false;

  void _toggleTheme() => setState(() => _isDark = !_isDark);

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: CalculatorTemplatePage(
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class CalculatorTemplatePage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const CalculatorTemplatePage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<CalculatorTemplatePage> createState() => _CalculatorTemplatePageState();
}

class _CalculatorTemplatePageState extends State<CalculatorTemplatePage> {
  String display = "0";
  String? errorMessage;

  // NEW: shows what user clicked (expression / history line)
  String expression = "";

  double? _first;
  String? _op; // "+", "−", "×", "÷"
  bool _startNewNumber = true;

  void _setError(String msg) => errorMessage = msg;
  void _clearError() => errorMessage = null;

  void _clearAll() {
    display = "0";
    errorMessage = null;
    expression = "";
    _first = null;
    _op = null;
    _startNewNumber = true;
  }

  double _asNumber(String s) => double.tryParse(s) ?? 0.0;

  String _formatNumber(double n) {
    if (n.isNaN || n.isInfinite) return "Error";
    if (n % 1 == 0) return n.toInt().toString();
    final str = n.toString();
    return str.length > 14 ? n.toStringAsPrecision(12) : str;
  }

  void _backspace() {
    if (_startNewNumber) return;

    if (display.length <= 1) {
      display = "0";
      _startNewNumber = true;
      return;
    }

    display = display.substring(0, display.length - 1);

    if (display == "-" || display.isEmpty) {
      display = "0";
      _startNewNumber = true;
    }

    // Update expression preview while typing the 2nd number
    _syncExpressionPreview();
  }

  void _appendDigit(String digit) {
    if (_startNewNumber) {
      display = digit;
      _startNewNumber = false;
    } else if (display == "0") {
      display = digit;
    } else {
      display += digit;
    }

    _syncExpressionPreview();
  }

  void _appendDot() {
    if (_startNewNumber) {
      display = "0.";
      _startNewNumber = false;
      _syncExpressionPreview();
      return;
    }

    if (!display.contains('.')) {
      display += '.';
      _syncExpressionPreview();
    }
  }

  double _applyOp(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '−':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) return double.nan;
        return a / b;
      default:
        return b;
    }
  }

  // NEW: Keeps expression line in sync while user types
  void _syncExpressionPreview() {
    if (_first == null && _op == null) {
      // No operator yet -> just show the current typed number (optional)
      expression = display == "0" ? "" : display;
      return;
    }

    if (_first != null && _op != null) {
      if (_startNewNumber) {
        // Operator chosen, user hasn't started second number yet
        expression = "${_formatNumber(_first!)} $_op";
      } else {
        // User typing second number
        expression = "${_formatNumber(_first!)} $_op $display";
      }
    }
  }

  void _setOperator(String op) {
    // If user hits operator twice in a row, just replace operator
    if (_startNewNumber && _op != null) {
      _op = op;
      _syncExpressionPreview();
      return;
    }

    // If we have a pending operation and user has entered second number,
    // compute first (chain), then store result as new first.
    if (_first != null && _op != null && !_startNewNumber) {
      final second = _asNumber(display);

      if (_op == "÷" && second == 0) {
        display = "Error";
        _setError("Cannot divide by 0");
        expression = "${_formatNumber(_first!)} $_op $second =";
        _first = null;
        _op = null;
        _startNewNumber = true;
        return;
      }

      final result = _applyOp(_first!, second, _op!);
      display = _formatNumber(result);

      if (display == "Error") {
        _setError("Invalid operation");
        expression = "${_formatNumber(_first!)} $_op $second =";
        _first = null;
        _op = null;
        _startNewNumber = true;
        return;
      }

      _first = _asNumber(display);
      _op = op;
      _startNewNumber = true;
      _syncExpressionPreview();
      return;
    }

    // First time picking operator
    _first ??= _asNumber(display);
    _op = op;
    _startNewNumber = true;
    _syncExpressionPreview();
  }

  void _computeEquals() {
    if (_op == null) {
      _setError("Choose an operator first");
      // Show whatever they typed so far
      expression = display == "0" ? "" : display;
      return;
    }

    if (_startNewNumber) {
      _setError("Enter a second number");
      _syncExpressionPreview();
      return;
    }

    if (_first == null) {
      _setError("Missing first number");
      _syncExpressionPreview();
      return;
    }

    final second = _asNumber(display);

    if (_op == "÷" && second == 0) {
      display = "Error";
      _setError("Cannot divide by 0");
      expression = "${_formatNumber(_first!)} $_op $second =";
      _first = null;
      _op = null;
      _startNewNumber = true;
      return;
    }

    final result = _applyOp(_first!, second, _op!);

    // Show full expression, then result in display
    expression = "${_formatNumber(_first!)} $_op $second =";
    display = _formatNumber(result);

    if (display == "Error") {
      _setError("Invalid operation");
    }

    _first = null;
    _op = null;
    _startNewNumber = true;
  }

  void onKeyTap(String key) {
    setState(() {
      if (key != "=" && key != "C") _clearError();

      if (key == "C") {
        _clearAll();
        return;
      }

      if (key == "⌫") {
        _backspace();
        return;
      }

      if (key == "=") {
        _computeEquals();
        return;
      }

      if (key == ".") {
        _appendDot();
        return;
      }

      if (key == "+" || key == "−" || key == "×" || key == "÷") {
        _setOperator(key);
        return;
      }

      if (key == "%") {
        _setError("Percent not implemented yet");
        return;
      }

      if (RegExp(r'^[0-9]$').hasMatch(key)) {
        _appendDigit(key);
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const gap = 10.0;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: widget.isDark ? "Switch to Light" : "Switch to Dark",
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.dark_mode : Icons.light_mode),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // DISPLAY
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.surfaceContainerHighest.withOpacity(0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // NEW: expression/history line
                    Text(
                      expression,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: cs.onSurface.withOpacity(0.65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      display,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    if (errorMessage != null)
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          fontSize: 14,
                          color: cs.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
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
                          CalcButton(label: 'C', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          CalcButton(label: '⌫', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          CalcButton(label: '%', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          CalcButton(label: '÷', onTap: onKeyTap, isOp: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: gap),
                    Expanded(
                      child: Row(
                        children: [
                          CalcButton(label: '7', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          CalcButton(label: '8', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          CalcButton(label: '9', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          CalcButton(label: '×', onTap: onKeyTap, isOp: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: gap),
                    Expanded(
                      child: Row(
                        children: [
                          CalcButton(label: '4', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          CalcButton(label: '5', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          CalcButton(label: '6', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          CalcButton(label: '−', onTap: onKeyTap, isOp: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: gap),
                    Expanded(
                      child: Row(
                        children: [
                          CalcButton(label: '1', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          CalcButton(label: '2', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          CalcButton(label: '3', onTap: onKeyTap),
                          const SizedBox(width: gap),
                          CalcButton(label: '+', onTap: onKeyTap, isOp: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: gap),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CalcButton(label: '0', onTap: onKeyTap),
                          ),
                          const SizedBox(width: gap),
                          Expanded(
                            child: CalcButton(label: '.', onTap: onKeyTap),
                          ),
                          const SizedBox(width: gap),
                          Expanded(
                            child: CalcButton(
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

class CalcButton extends StatefulWidget {
  final String label;
  final void Function(String) onTap;
  final bool isOp;
  final bool isEquals;

  const CalcButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isOp = false,
    this.isEquals = false,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final Color bg = widget.isEquals
        ? cs.primary
        : widget.isOp
            ? cs.tertiary
            : cs.surfaceContainerHighest;

    final Color fg = widget.isEquals || widget.isOp ? cs.onPrimary : cs.onSurface;

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () => widget.onTap(widget.label),
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: _pressed ? bg.withOpacity(0.85) : bg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _pressed
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}