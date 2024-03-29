import 'package:flutter/material.dart';

class CounterProvider extends ChangeNotifier {
  int _count1 = 0;
  int _count2 = 0;

  int get count1 => _count1;
  int get count2 => _count2;

  void incrementCount1() {
    _count1++;
    notifyListeners();
  }

  void incrementCount2() {
    _count2++;
    notifyListeners();
  }
}
