import 'package:flutter/foundation.dart';

class FibonacciProvider with ChangeNotifier {
  List<int> _fibonacciNumbers = [];
  int? _highlightedNumber;
  DateTime? _highlightTimestamp;
  int? _selectedNumber;
  
  int? get selectedNumber => _selectedNumber;

  List<int> get fibonacciNumbers => _fibonacciNumbers;

  FibonacciProvider() {
    generateFibonacci(40);
  }

  void setSelectedNumber(int number) {
    _selectedNumber = number;
    notifyListeners();
  }

  void generateFibonacci(int count) {
    _fibonacciNumbers = [0, 1];
    for (int i = 2; i < count; i++) {
      _fibonacciNumbers.add(_fibonacciNumbers[i - 1] + _fibonacciNumbers[i - 2]);
    }
    notifyListeners();
  }
  
  bool isNumberHighlighted(int number) {
    if (_highlightedNumber == null || _highlightTimestamp == null) return false;
    
    if (DateTime.now().difference(_highlightTimestamp!) > Duration(milliseconds: 100)) {
      // Instead of immediately updating state, schedule it for the next frame
      Future.microtask(() {
        _highlightedNumber = null;
        _highlightTimestamp = null;
        notifyListeners();
      });
      return false;
    }
    
    return number == _highlightedNumber;
  }

  void setHighlightedNumber(int? number) {
    _highlightedNumber = number;
    _highlightTimestamp = DateTime.now();
    notifyListeners();
  }

  List<int> getNumbersOfSameType(int selectedNumber) {
    if (selectedNumber == 0) {
      return _fibonacciNumbers.where((n) => n == 0).toList();
    }
    if (selectedNumber == 1) {
      return _fibonacciNumbers.where((n) => n == 1).toList();
    }
    
    bool isEven = selectedNumber % 2 == 0;
    return _fibonacciNumbers.where((number) {
      if (number == 0 || number == 1) return false; // Exclude special cases
      return (number % 2 == 0) == isEven;
    }).toList();
  }

  int getNumberIndex(int number) {
    return _fibonacciNumbers.indexOf(number);
  }

  Map<int, int> getNumbersWithIndices(int selectedNumber) {
    Map<int, int> numbersWithIndices = {};
    for (int i = 0; i < _fibonacciNumbers.length; i++) {
      if (_fibonacciNumbers[i] == selectedNumber || 
          (_fibonacciNumbers[i] % 2 == selectedNumber % 2 && 
           _fibonacciNumbers[i] != 0 && 
           _fibonacciNumbers[i] != 1)) {
        numbersWithIndices[_fibonacciNumbers[i]] = i;
      }
    }
    return numbersWithIndices;
  }
}