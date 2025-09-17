import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AIBasicEditor extends StatefulWidget {
  final String content;
  final Function(String) onContentChanged;
  final String language;
  final String theme;
  final int fontSize;
  final String fontFamily;
  final bool syntaxHighlighting;
  final bool autoComplete;
  final bool lineNumbers;
  final bool wordWrap;

  const AIBasicEditor({
    super.key,
    required this.content,
    required this.onContentChanged,
    required this.language,
    required this.theme,
    required this.fontSize,
    required this.fontFamily,
    required this.syntaxHighlighting,
    required this.autoComplete,
    required this.lineNumbers,
    required this.wordWrap,
  });

  @override
  State<AIBasicEditor> createState() => _AIBasicEditorState();
}

class _AIBasicEditorState extends State<AIBasicEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  List<String> _lines = [];
  Map<int, String> _lineColors = {};
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  int _selectedSuggestion = 0;

  // Ключевые слова AIBASIC
  final Set<String> _keywords = {
    'LET', 'PRINT', 'GOTO', 'FOR', 'NEXT', 'IF', 'THEN', 'ELSE',
    'DIM', 'DATA', 'READ', 'RESTORE', 'RANDOMIZE', 'INPUT', 'REM',
    'CLS', 'BORDER', 'INK', 'PAPER', 'FLASH', 'BRIGHT', 'INVERSE', 'OVER',
    'PLOT', 'DRAW', 'CIRCLE', 'SOUND', 'BEEP', 'PEEK', 'POKE',
    'EXEC', 'RETURN', 'PARAM', 'END',
    'LONGINT108', 'FLOAT108', 'QUANTUMARRAY',
    'LOAD_AI_MODEL', 'PROCESS_QUANTUM_ARRAY', 'CREATE_QUANTUM_STATE',
    'APPLY_QUANTUM_GATE', 'MEASURE_QUANTUM_STATE', 'GET_MEMORY_108',
    'PUT_MEMORY_108', 'RENDER_HOLOGRAM',
    // Локализованные команды
    'ПУСТЬ', 'ПЕЧАТЬ', 'ПЕРЕЙТИ', 'ДЛЯ', 'ДАЛЕЕ', 'ЕСЛИ', 'ТО', 'ИНАЧЕ',
    'РАЗМЕР', 'ДАННЫЕ', 'ЧИТАТЬ', 'ВОССТАНОВИТЬ', 'СЛУЧАЙНО', 'ВВОД',
    'КОММЕНТАРИЙ', 'ОЧИСТИТЬ', 'РАМКА', 'ЧЕРНИЛА', 'БУМАГА', 'МИГАНИЕ',
    'ЯРКОСТЬ', 'ОБРАТНЫЙ', 'ПОВЕРХ', 'ТОЧКА', 'РИСОВАТЬ', 'КРУГ',
    'ЗВУК', 'СИГНАЛ', 'ПРОСМОТР', 'ЗАПИСАТЬ',
  };

  // Функции
  final Set<String> _functions = {
    'USR', 'CODE', 'VAL', 'STR\$', 'CHR\$', 'SCREEN\$', 'ATTR', 'POINT',
    'BIN', 'LEN', 'SGN', 'ABS', 'INT', 'PI', 'FN', 'DEF FN',
  };

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
    _focusNode = FocusNode();
    _lines = widget.content.split('\n');
    _updateSyntaxHighlighting();
  }

  @override
  void didUpdateWidget(AIBasicEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.content != oldWidget.content) {
      _controller.text = widget.content;
      _lines = widget.content.split('\n');
      _updateSyntaxHighlighting();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateSyntaxHighlighting() {
    if (!widget.syntaxHighlighting) return;
    
    _lineColors.clear();
    for (int i = 0; i < _lines.length; i++) {
      final line = _lines[i];
      if (line.trim().startsWith('REM') || line.trim().startsWith('КОММЕНТАРИЙ')) {
        _lineColors[i] = 'comment';
      } else if (line.trim().startsWith(RegExp(r'\d+'))) {
        _lineColors[i] = 'lineNumber';
      } else if (_keywords.any((keyword) => line.contains(keyword))) {
        _lineColors[i] = 'keyword';
      } else if (_functions.any((function) => line.contains(function))) {
        _lineColors[i] = 'function';
      } else if (line.contains('"') || line.contains("'")) {
        _lineColors[i] = 'string';
      } else {
        _lineColors[i] = 'normal';
      }
    }
  }


  void _onTextChanged() {
    final newContent = _controller.text;
    _lines = newContent.split('\n');
    _updateSyntaxHighlighting();
    widget.onContentChanged(newContent);
  }

  void _onCursorPositionChanged() {
    if (widget.autoComplete) {
      _updateSuggestions();
    }
  }

  void _updateSuggestions() {
    final text = _controller.text;
    final cursorPos = _controller.selection.baseOffset;
    
    // Найти текущее слово
    int start = cursorPos;
    while (start > 0 && _isWordChar(text[start - 1])) {
      start--;
    }
    
    int end = cursorPos;
    while (end < text.length && _isWordChar(text[end])) {
      end++;
    }
    
    final currentWord = text.substring(start, end).toUpperCase();
    
    if (currentWord.length >= 2) {
      _suggestions = _keywords
          .where((keyword) => keyword.startsWith(currentWord))
          .take(10)
          .toList();
      
      if (_suggestions.isNotEmpty) {
        setState(() {
          _showSuggestions = true;
          _selectedSuggestion = 0;
        });
      }
    } else {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  bool _isWordChar(String char) {
    return RegExp(r'[a-zA-Zа-яА-Я0-9_]').hasMatch(char);
  }

  void _insertSuggestion() {
    if (_suggestions.isNotEmpty && _selectedSuggestion < _suggestions.length) {
      final suggestion = _suggestions[_selectedSuggestion];
      final text = _controller.text;
      final cursorPos = _controller.selection.baseOffset;
      
      // Найти текущее слово
      int start = cursorPos;
      while (start > 0 && _isWordChar(text[start - 1])) {
        start--;
      }
      
      // Заменить текущее слово на предложение
      final newText = text.substring(0, start) + suggestion + text.substring(cursorPos);
      _controller.text = newText;
      _controller.selection = TextSelection.collapsed(offset: start + suggestion.length);
      
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Основной редактор
        Container(
          decoration: BoxDecoration(
            color: widget.theme == 'dark' 
              ? const Color(0xFF1E1E1E) 
              : Colors.white,
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: Column(
            children: [
              // Номера строк
              if (widget.lineNumbers) _buildLineNumbers(),
              // Текстовое поле
              Expanded(
                child: _buildTextField(),
              ),
            ],
          ),
        ),
        // Предложения автодополнения
        if (_showSuggestions && widget.autoComplete) _buildSuggestions(),
      ],
    );
  }

  Widget _buildLineNumbers() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: widget.theme == 'dark' 
          ? const Color(0xFF2D2D30) 
          : const Color(0xFFF3F3F3),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.code, size: 16),
          const SizedBox(width: 8),
          Text(
            'Lines: ${_lines.length}',
            style: TextStyle(
              fontSize: 12,
              color: widget.theme == 'dark' ? Colors.white70 : Colors.black54,
            ),
          ),
          const Spacer(),
          Text(
            'Col: ${_getCurrentColumn()}',
            style: TextStyle(
              fontSize: 12,
              color: widget.theme == 'dark' ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: (_) {
        _onTextChanged();
        _onCursorPositionChanged();
      },
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      style: TextStyle(
        fontSize: widget.fontSize.toDouble(),
        fontFamily: widget.fontFamily,
        color: widget.theme == 'dark' ? Colors.white : Colors.black,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(8),
      ),
      inputFormatters: [
        // Форматирование для AIBASIC
        _AIBasicInputFormatter(),
      ],
    );
  }

  Widget _buildSuggestions() {
    return Positioned(
      top: 100,
      left: 20,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: widget.theme == 'dark' 
              ? const Color(0xFF2D2D30) 
              : Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = _suggestions[index];
              final isSelected = index == _selectedSuggestion;
              
              return InkWell(
                onTap: () {
                  _selectedSuggestion = index;
                  _insertSuggestion();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.code,
                        size: 16,
                        color: widget.theme == 'dark' ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        suggestion,
                        style: TextStyle(
                          color: widget.theme == 'dark' ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  int _getCurrentColumn() {
    final text = _controller.text;
    final cursorPos = _controller.selection.baseOffset;
    final lines = text.substring(0, cursorPos).split('\n');
    return lines.last.length + 1;
  }
}

class _AIBasicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Автоматическое форматирование для AIBASIC
    String formattedText = newValue.text;
    
    // Автоматическое добавление пробелов после номеров строк
    formattedText = formattedText.replaceAllMapped(
      RegExp(r'^(\d+)([A-Za-z])', multiLine: true),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    
    // Автоматическое добавление пробелов после команд
    final commands = ['LET', 'PRINT', 'GOTO', 'FOR', 'NEXT', 'IF', 'THEN', 'ELSE'];
    for (final command in commands) {
      formattedText = formattedText.replaceAllMapped(
        RegExp('\\b$command([A-Za-z])', caseSensitive: false),
        (match) => '$command ${match.group(1)}',
      );
    }
    
    return TextEditingValue(
      text: formattedText,
      selection: newValue.selection,
    );
  }
}
