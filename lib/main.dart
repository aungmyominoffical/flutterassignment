import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/fibonacci_provider.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};

  // In _showBottomSheet method
  void _showBottomSheet(BuildContext context, int selectedNumber, int selectedIndex) {
    final fibProvider = Provider.of<FibonacciProvider>(context, listen: false);
    fibProvider.setSelectedNumber(selectedNumber);
    final numbersWithIndices = fibProvider.getNumbersWithIndices(selectedNumber);
    final sameTypeNumbers = numbersWithIndices.keys.toList();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Numbers of Same Type',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Flexible(
                child: Consumer<FibonacciProvider>(
                  builder: (context, provider, child) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: sameTypeNumbers.length,
                      itemBuilder: (context, index) {
                        final number = sameTypeNumbers[index];
                        final originalIndex = numbersWithIndices[number]!;
                        final isSelected = number == provider.selectedNumber;
                        
                        return Card(
                          color: isSelected ? Colors.greenAccent.shade100 : null,
                          child: ListTile(
                            title: Text(
                              number.toString(),
                              style: TextStyle(fontSize: 16),
                            ),
                            onTap: () {
                              provider.setHighlightedNumber(number);
                              provider.setSelectedNumber(number);
                              Navigator.pop(context);

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final keyContext = _itemKeys[number]?.currentContext;
                                if (keyContext != null) {
                                  Scrollable.ensureVisible(
                                    keyContext,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    alignment: 0.5,
                                  );
                                }
                              });
                            },
                            leading: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${originalIndex + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                              trailing: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  shape: number % 2 == 0
                                      ? BoxShape.rectangle
                                      : BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    _getIconForNumber(number),
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              )
                          ),
                        );
                    },
                    );
                  }
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForNumber(int number) {
    if (number == 0) return Icons.radio_button_unchecked;
    if (number == 1) return Icons.looks_one;
    if (number % 2 == 0) return Icons.square_outlined;
    return Icons.circle_outlined;
  }

  String _getNumberDescription(int number) {
    if (number == 0) return "Zero - Starting point";
    if (number == 1) return "One - Base number";
    if (number % 2 == 0) return "Even Fibonacci number";
    return "Odd Fibonacci number";
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FibonacciProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fibonacci Scroll',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Scaffold(
            appBar: AppBar(
              title: Text('Fibonacci Scroll'),
            ),
            body: Consumer<FibonacciProvider>(
              builder: (context, fibProvider, child) {
                return SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: fibProvider.fibonacciNumbers.asMap().map((index, number) {
                      _itemKeys[number] = GlobalKey();
                      bool isHighlighted = fibProvider.isNumberHighlighted(number);

                      // In the main list view
                      return MapEntry(
                        index,
                        GestureDetector(
                          key: _itemKeys[number],
                          onTap: () {
                            fibProvider.setSelectedNumber(number);
                            _showBottomSheet(context, number, index);
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: (isHighlighted || number == fibProvider.selectedNumber) 
                                ? Colors.greenAccent.shade100 
                                : null,
                            child: ListTile(
                              leading: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              trailing: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  shape: number % 2 == 0
                                      ? BoxShape.rectangle
                                      : BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    _getIconForNumber(number),
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ),
                              title: Text(
                                number.toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                _getNumberDescription(number),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).values.toList(),
                  ),
                );
              },
            ),
          ),
        )
    );
  }
}

