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
  // Placeholder display text (no real calculation yet)
  String display = "0";

  // Just a template handler so the buttons "do something" visually.
  // You can remove this body later when you add real functionality.
  void onKeyTap(String key) {
    setState(() {
      // Simple placeholder behavior:
      // - If display is "0", replace it
      // - Otherwise append the key
      if (display == "0") {
        display = key;
      } else {
        display += key;
      }
    });

    // Optional: print tap to console for debugging
    // debugPrint("Tapped: $key");
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
          margin: const EdgeInsets.all(0),
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