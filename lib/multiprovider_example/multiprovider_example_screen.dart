import 'package:camera_app/multiprovider_example/multiprovider_example.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiproviderExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('build MultiproviderExampleScreen');
    return Scaffold(
      appBar: AppBar(
        title: Text('Multiprovider Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Selector<CounterProvider, int>(
              selector: (context, value) => value.count1,
              builder: (context, count1, child) {
                print('build Text 1');
                return Text(
                  'Number 1: $count1',
                  style: TextStyle(fontSize: 24),
                );
              },
            ),
            SizedBox(height: 16),
            Selector<CounterProvider, int>(
              selector: (context, value) => value.count2,
              builder: (context, count2, child) {
                print('build Text 2');
                return Text(
                  'Number 2: $count2',
                  style: TextStyle(fontSize: 24),
                );
              },
            ),
            SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Selector<CounterProvider, VoidCallback>(
                selector: (context, value) => value.incrementCount1,
                builder: (context, incrementCount1, child) {
                  print('build ElevatedButton 1');
                  return ElevatedButton(
                    onPressed: incrementCount1,
                    child: Text('Increment Number 1'),
                  );
                },
              ),
              SizedBox(width: 16),
              Selector<CounterProvider, VoidCallback>(
                selector: (context, value) => value.incrementCount2,
                builder: (context, incrementCount2, child) {
                  print('build ElevatedButton 2');
                  return ElevatedButton(
                    onPressed: incrementCount2,
                    child: Text('Increment Number 2'),
                  );
                },
              ),
            ])
          ],
        ),
      ),
    );
  }
}
