import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:screen_protector/models/screen_protector_event.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the screen protector
  await ScreenProtector.protectDataLeakageOn();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screenshot Blur Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Screenshot Protection Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isBlurred = false;

  @override
  void initState() {
    super.initState();
    _setupScreenshotProtection();
  }

  // Set up screenshot protection and detection
  Future<void> _setupScreenshotProtection() async {
    try {
      // Enable screenshot protection
      await ScreenProtector.preventScreenshotOn();
      
      // Listen for screenshot events
      ScreenProtector.addListener(ScreenProtectorEvent.onScreenshot, () {
        // Blur the content when screenshot is detected
        setState(() {
          _isBlurred = true;
        });
        
        // Unblur after a delay
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _isBlurred = false;
            });
          }
        });
      });
    } catch (e) {
      debugPrint('Failed to enable screenshot protection: $e');
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main app content
        Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'This is sensitive content that will be blurred when screenshots are taken',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 40),
                const Text(
                  '⚠️ Try taking a screenshot to see the blur effect',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isBlurred = !_isBlurred;
                    });
                  },
                  child: Text(_isBlurred ? 'Remove Blur' : 'Test Blur Effect'),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ),
        
        // Blur overlay that appears when screenshot is detected
        if (_isBlurred)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Text(
                    'Content hidden for security',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    // Clean up resources
    ScreenProtector.preventScreenshotOff();
    ScreenProtector.removeListener(ScreenProtectorEvent.onScreenshot);
    super.dispose();
  }
}
