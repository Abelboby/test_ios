import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:screen_protector/models/screen_protector_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the screen protector
  await ScreenProtector.protectDataLeakageOn();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" //(save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Secure iOS App Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isSecured = false;
  String _securityStatus = "Screen protection initializing...";

  @override
  void initState() {
    super.initState();
    _enableScreenProtection();
    _detectScreenshots();
  }

  // Enable screenshot protection
  Future<void> _enableScreenProtection() async {
    try {
      await ScreenProtector.preventScreenshotOn(); // Enable screenshot prevention
      setState(() {
        _isSecured = true;
        _securityStatus = "Screenshot & recording protection enabled";
      });
    } catch (e) {
      setState(() {
        _securityStatus = "Failed to enable protection: $e";
      });
    }
  }

  // Detect screenshot attempts
  void _detectScreenshots() {
    // Listen for screenshot events
    ScreenProtector.addListener(ScreenProtectorEvent.onScreenshot, () {
      setState(() {
        _securityStatus = "⚠️ SCREENSHOT DETECTED! ⚠️";
      });
      
      // Reset status message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _securityStatus = "Screenshot & recording protection enabled";
          });
        }
      });
    });

    // Listen for screen recording events
    ScreenProtector.addListener(ScreenProtectorEvent.onScreenRecord, () {
      setState(() {
        _securityStatus = "⚠️ SCREEN RECORDING DETECTED! ⚠️";
      });
      
      // Reset status message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _securityStatus = "Screenshot & recording protection enabled";
          });
        }
      });
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _isSecured ? Colors.green.shade100 : Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isSecured ? Colors.green : Colors.amber,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSecured ? Icons.security : Icons.warning,
                    color: _isSecured ? Colors.green : Colors.amber,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      _securityStatus,
                      style: TextStyle(
                        color: _isSecured ? Colors.green.shade800 : Colors.amber.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This content is protected:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            const Text(
              '⚠️ Try taking a screenshot to see the detection in action',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    // Ensure we clean up resources
    ScreenProtector.preventScreenshotOff();
    // Remove both event listeners
    ScreenProtector.removeListener(ScreenProtectorEvent.onScreenshot);
    ScreenProtector.removeListener(ScreenProtectorEvent.onScreenRecord);
    super.dispose();
  }
}
