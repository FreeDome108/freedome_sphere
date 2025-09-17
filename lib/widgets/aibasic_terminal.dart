import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AIBasicTerminal extends StatefulWidget {
  final Function(String) onCommand;
  final List<String> history;

  const AIBasicTerminal({
    super.key,
    required this.onCommand,
    required this.history,
  });

  @override
  State<AIBasicTerminal> createState() => _AIBasicTerminalState();
}

class _AIBasicTerminalState extends State<AIBasicTerminal> {
  final TextEditingController _commandController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  List<TerminalLine> _output = [];
  int _historyIndex = -1;
  String _currentPrompt = 'AIBASIC> ';
  bool _isExecuting = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _commandController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _output.add(TerminalLine(
      text: 'AIBASIC Terminal v1.0.0',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: 'Type "help" for available commands',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: '',
      type: TerminalLineType.empty,
    ));
  }

  void _executeCommand(String command) {
    if (command.trim().isEmpty) return;
    
    // Добавляем команду в вывод
    _output.add(TerminalLine(
      text: '$_currentPrompt$command',
      type: TerminalLineType.input,
    ));
    
    // Очищаем поле ввода
    _commandController.clear();
    
    // Обрабатываем команду
    _processCommand(command.trim());
    
    // Прокручиваем вниз
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _processCommand(String command) {
    setState(() {
      _isExecuting = true;
    });
    
    // Добавляем команду в историю
    if (widget.history.isEmpty || widget.history.last != command) {
      widget.onCommand(command);
    }
    
    // Обрабатываем специальные команды
    if (command.toLowerCase() == 'help') {
      _showHelp();
    } else if (command.toLowerCase() == 'clear') {
      _clearTerminal();
    } else if (command.toLowerCase() == 'history') {
      _showHistory();
    } else if (command.toLowerCase() == 'version') {
      _showVersion();
    } else if (command.toLowerCase() == 'exit' || command.toLowerCase() == 'quit') {
      _exitTerminal();
    } else if (command.startsWith('run ')) {
      _runFile(command.substring(4));
    } else if (command.startsWith('load ')) {
      _loadFile(command.substring(5));
    } else if (command.startsWith('save ')) {
      _saveFile(command.substring(5));
    } else {
      // Попытка выполнить как AIBASIC код
      _executeAIBasicCode(command);
    }
    
    setState(() {
      _isExecuting = false;
    });
  }

  void _showHelp() {
    _output.add(TerminalLine(
      text: 'Available commands:',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: '  help          - Show this help message',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: '  clear         - Clear terminal',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: '  history       - Show command history',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: '  version       - Show version information',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: '  exit/quit     - Exit terminal',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: '  run <file>    - Run AIBASIC file',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: '  load <file>   - Load AIBASIC file',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: '  save <file>   - Save current program',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: '',
      type: TerminalLineType.empty,
    ));
    _output.add(TerminalLine(
      text: 'You can also type AIBASIC commands directly:',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: '  PRINT "Hello, World!"',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: '  LET x = 10',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: '  FOR i = 1 TO 5: PRINT i: NEXT i',
      type: TerminalLineType.info,
    ));
  }

  void _clearTerminal() {
    _output.clear();
    _addWelcomeMessage();
  }

  void _showHistory() {
    if (widget.history.isEmpty) {
      _output.add(TerminalLine(
        text: 'No commands in history',
        type: TerminalLineType.info,
      ));
    } else {
      _output.add(TerminalLine(
        text: 'Command history:',
        type: TerminalLineType.info,
      ));
      for (int i = 0; i < widget.history.length; i++) {
        _output.add(TerminalLine(
          text: '  ${i + 1}. ${widget.history[i]}',
          type: TerminalLineType.info,
        ));
      }
    }
  }

  void _showVersion() {
    _output.add(TerminalLine(
      text: 'AIBASIC Terminal v1.0.0',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: 'Built with Flutter',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: 'FreeDome Sphere IDE',
      type: TerminalLineType.info,
    ));
  }

  void _exitTerminal() {
    _output.add(TerminalLine(
      text: 'Goodbye!',
      type: TerminalLineType.info,
    ));
    // Здесь можно добавить логику закрытия терминала
  }

  void _runFile(String filename) {
    _output.add(TerminalLine(
      text: 'Running file: $filename',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: 'File execution not implemented yet',
      type: TerminalLineType.error,
    ));
  }

  void _loadFile(String filename) {
    _output.add(TerminalLine(
      text: 'Loading file: $filename',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: 'File loading not implemented yet',
      type: TerminalLineType.error,
    ));
  }

  void _saveFile(String filename) {
    _output.add(TerminalLine(
      text: 'Saving to file: $filename',
      type: TerminalLineType.info,
    ));
    _output.add(TerminalLine(
      text: 'File saving not implemented yet',
      type: TerminalLineType.error,
    ));
  }

  void _executeAIBasicCode(String code) {
    // Простая интерпретация AIBASIC команд
    try {
      if (code.toUpperCase().startsWith('PRINT')) {
        _handlePrintCommand(code);
      } else if (code.toUpperCase().startsWith('LET')) {
        _handleLetCommand(code);
      } else if (code.toUpperCase().startsWith('FOR')) {
        _handleForCommand(code);
      } else if (code.toUpperCase().startsWith('IF')) {
        _handleIfCommand(code);
      } else {
        _output.add(TerminalLine(
          text: 'Unknown command: $code',
          type: TerminalLineType.error,
        ));
      }
    } catch (e) {
      _output.add(TerminalLine(
        text: 'Error: $e',
        type: TerminalLineType.error,
      ));
    }
  }

  void _handlePrintCommand(String code) {
    // Простая обработка PRINT команды
    final match = RegExp(r'PRINT\s+(.+)', caseSensitive: false).firstMatch(code);
    if (match != null) {
      String output = match.group(1)!;
      // Убираем кавычки если есть
      if (output.startsWith('"') && output.endsWith('"')) {
        output = output.substring(1, output.length - 1);
      }
      _output.add(TerminalLine(
        text: output,
        type: TerminalLineType.output,
      ));
    } else {
      _output.add(TerminalLine(
        text: 'Syntax error in PRINT command',
        type: TerminalLineType.error,
      ));
    }
  }

  void _handleLetCommand(String code) {
    // Простая обработка LET команды
    final match = RegExp(r'LET\s+(\w+)\s*=\s*(.+)', caseSensitive: false).firstMatch(code);
    if (match != null) {
      final variable = match.group(1)!;
      final value = match.group(2)!;
      _output.add(TerminalLine(
        text: 'Variable $variable set to $value',
        type: TerminalLineType.info,
      ));
    } else {
      _output.add(TerminalLine(
        text: 'Syntax error in LET command',
        type: TerminalLineType.error,
      ));
    }
  }

  void _handleForCommand(String code) {
    _output.add(TerminalLine(
      text: 'FOR loops not implemented in terminal mode',
      type: TerminalLineType.error,
    ));
  }

  void _handleIfCommand(String code) {
    _output.add(TerminalLine(
      text: 'IF statements not implemented in terminal mode',
      type: TerminalLineType.error,
    ));
  }

  void _navigateHistory(int direction) {
    if (widget.history.isEmpty) return;
    
    if (direction > 0) {
      // Вверх по истории
      if (_historyIndex < widget.history.length - 1) {
        _historyIndex++;
        _commandController.text = widget.history[_historyIndex];
      }
    } else {
      // Вниз по истории
      if (_historyIndex > 0) {
        _historyIndex--;
        _commandController.text = widget.history[_historyIndex];
      } else if (_historyIndex == 0) {
        _historyIndex = -1;
        _commandController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          // Заголовок терминала
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF2D2D30),
              border: Border(
                bottom: BorderSide(color: Color(0xFF3E3E42)),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.terminal,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                const Text(
                  'AIBASIC Terminal',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (_isExecuting)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
              ],
            ),
          ),
          // Вывод терминала
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: _output.length,
              itemBuilder: (context, index) {
                final line = _output[index];
                return _buildTerminalLine(line);
              },
            ),
          ),
          // Поле ввода
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF2D2D30),
              border: Border(
                top: BorderSide(color: Color(0xFF3E3E42)),
              ),
            ),
            child: Row(
              children: [
                Text(
                  _currentPrompt,
                  style: const TextStyle(
                    color: Colors.green,
                    fontFamily: 'monospace',
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _commandController,
                    focusNode: _focusNode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter AIBASIC command...',
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontFamily: 'monospace',
                      ),
                    ),
                    onSubmitted: _executeCommand,
                    onChanged: (value) {
                      _historyIndex = -1;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalLine(TerminalLine line) {
    Color textColor;
    switch (line.type) {
      case TerminalLineType.input:
        textColor = Colors.green;
        break;
      case TerminalLineType.output:
        textColor = Colors.white;
        break;
      case TerminalLineType.error:
        textColor = Colors.red;
        break;
      case TerminalLineType.info:
        textColor = Colors.cyan;
        break;
      case TerminalLineType.empty:
        return const SizedBox(height: 4);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        line.text,
        style: TextStyle(
          color: textColor,
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }
}

class TerminalLine {
  final String text;
  final TerminalLineType type;

  TerminalLine({
    required this.text,
    required this.type,
  });
}

enum TerminalLineType {
  input,
  output,
  error,
  info,
  empty,
}
