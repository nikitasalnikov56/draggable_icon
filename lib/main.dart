import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Основной класс приложения.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],

            /// Метод для построения виджета иконки.
            builder: (iconData) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors
                      .primaries[iconData.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(iconData, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Виджет Dock для перемещения элементов.
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Список элементов для отображения.
  final List<T> items;

  /// Функция для построения виджета на основе элемента.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T extends Object> extends State<Dock<T>> {
  /// Список элементов, которые будут отображаться.
  late List<T> _items = widget.items.toList();

  /// Индекс перетаскиваемого элемента.
  int? _draggedIndex;

  /// Хранит смещения иконок.
  final Map<int, Offset> _offsets = {};

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
          children: List.generate(_items.length, (index) {
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
              // Пустое место, когда элемент перетаскивается
              childWhenDragging: Container(),
              onDragStarted: () {
                setState(() {
                  _draggedIndex = index;
                });
              },
              onDragCompleted: () {
                setState(() {
                  _draggedIndex = null;
                });
              },
              child: GestureDetector(
                key: ValueKey(item),
                // Устанавливаем индекс перетаскиваемой иконки
                onPanStart: (_) {
                  setState(() {
                    _draggedIndex = index;
                  });
                },
                // Обновляем положение иконки по вертикали и горизонтали
                onPanUpdate: (details) {
                  setState(() {
                    _offsets[index] =
                        (_offsets[index] ?? Offset.zero) + details.delta;
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    if ((_offsets[index]?.distance ?? 0) > 50) {
                      // Сбрасываем смещение при отпускании
                      _offsets[index] = Offset.zero;
                    } else {
                      // Сбрасываем смещение при возврате на место
                      _offsets[index] = Offset.zero;
                    }
                    // Сбрасываем индекс перетаскиваемой иконки
                    _draggedIndex = null;
                  });
                },
                child: AnimatedContainer(
                  // Длительность анимации
                  duration: const Duration(milliseconds: 300),
                  transform: Matrix4.translationValues(
                      _offsets[index]?.dx ?? 0, _offsets[index]?.dy ?? 0, 0),
                  child: DragTarget<T>(
                    onAcceptWithDetails: (details) {
                      setState(() {
                        final draggedItem = _items.removeAt(_draggedIndex!);
                        _items.insert(index, draggedItem);
                        _draggedIndex = null;
                      });
                    },
                    onWillAcceptWithDetails: (details) =>
                        _draggedIndex != index,
                    builder: (context, candidateData, rejectedData) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        // Применяем смещение
                        transform: Matrix4.translationValues(
                          _offsets[index]?.dx ?? 0,
                          _offsets[index]?.dy ?? 0,
                          0,
                        ),
                        child: widget.builder(item),
                      );
                    },
                  ),
                ),
              ),
            );
          })),
    );
  }
}
