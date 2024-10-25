

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Основной класс приложения.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child:  Dock<IconData>( // Указан конкретный тип данных для Dock
            items: [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: _buildIconContainer,
          ),
        ),
      ),
    );
  }

  static Widget _buildIconContainer(IconData iconData) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      height: 48,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[iconData.hashCode % Colors.primaries.length],
      ),
      child: Center(child: Icon(iconData, color: Colors.white)),
    );
  }
}

/// Виджет Dock для перемещения элементов.
class Dock<T extends Object> extends StatefulWidget { // Ограничиваем T от Object
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T extends Object> extends State<Dock<T>> { // Ограничиваем T от Object
  late final List<T> _items = List<T>.from(widget.items);
  int? _draggedIndex;

  final Map<int, Offset> _offsets = {}; // Для хранения смещений иконок

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      constraints: const BoxConstraints(minWidth: 80),
      height: 80,
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, _buildDraggableIcon),
      ),
    );
  }

  Widget _buildDraggableIcon(int index) {
    final item = _items[index];

    return Draggable<T>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.7,
          child: widget.builder(item),
        ),
      ),
      childWhenDragging: Container(), // Пустое место, когда элемент перетаскивается
      onDragStarted: () => _onDragStarted(index),
      onDragCompleted: _onDragCompleted,
      child: GestureDetector(
        key: ValueKey(item),
        onPanStart: (_) => _onPanStart(index),
        onPanUpdate: (details) => _onPanUpdate(index, details),
        onPanEnd: (details) => _onPanEnd(index, details),
        child: _buildAnimatedContainer(index, item),
      ),
    );
  }

  void _onDragStarted(int index) {
    setState(() {
      _draggedIndex = index;
    });
  }

  void _onDragCompleted() {
    setState(() {
      _draggedIndex = null;
    });
  }

  void _onPanStart(int index) {
    setState(() {
      _draggedIndex = index; // Устанавливаем индекс перетаскиваемой иконки
    });
  }

  void _onPanUpdate(int index, DragUpdateDetails details) {
    setState(() {
      _offsets[index] = (_offsets[index] ?? Offset.zero) + details.delta;
    });
  }

  void _onPanEnd(int index, DragEndDetails details) {
    setState(() {
      // Сбрасываем смещение при отпускании
      _offsets[index] = (_offsets[index]?.distance ?? 0) > 50 ? Offset.zero : Offset.zero;
      _draggedIndex = null; // Сбрасываем индекс перетаскиваемой иконки
    });
  }

  Widget _buildAnimatedContainer(int index, T item) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Длительность анимации
      transform: Matrix4.translationValues(
        _offsets[index]?.dx ?? 0,
        _offsets[index]?.dy ?? 0,
        0,
      ),
      child: DragTarget<T>(
       onAcceptWithDetails: (details) => _onAccept(details.data, index), 
      onWillAcceptWithDetails: (details) => _onWillAccept(details.data),
        builder: (context, candidateData, rejectedData) {
          return widget.builder(item);
        },
      ),
    );
  }

  void _onAccept(T data, int index) {
    setState(() {
      final draggedItem = _items.removeAt(_draggedIndex!);
      _items.insert(index, draggedItem);
      _draggedIndex = null;
    });
  }
  bool _onWillAccept(T data) {
    return _draggedIndex != null && _draggedIndex != _items.indexOf(data);
  }
}
