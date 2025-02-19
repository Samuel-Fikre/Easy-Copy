import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quick Account Copy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AccountNumberScreen(),
    );
  }
}

class AccountNumberScreen extends StatefulWidget {
  const AccountNumberScreen({super.key});

  @override
  State<AccountNumberScreen> createState() => _AccountNumberScreenState();
}

class _AccountNumberScreenState extends State<AccountNumberScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;
  static const String keyAccountNumber = 'bankAccount';

  @override
  void initState() {
    super.initState();
    _loadAccountNumber();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAccountNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _controller.text = prefs.getString(keyAccountNumber) ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAccountNumber() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an account number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyAccountNumber, _controller.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account number saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save account number'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyToClipboard() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No account number saved'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: _controller.text.trim()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account number copied!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Account Copy'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'CBE Account Number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Account Number',
                border: OutlineInputBorder(),
                hintText: '1000123456789',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveAccountNumber,
              icon: const Icon(Icons.save),
              label: const Text('Save Account Number'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.copy),
              label: const Text('Copy to Clipboard'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const Spacer(),
            const Text(
              'Quick Settings Tile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'To enable the Quick Settings Tile:\n'
              '1. Swipe down to open Quick Settings\n'
              '2. Tap the edit (pencil) icon\n'
              '3. Find "Copy Account" and drag it to active tiles\n'
              '4. Tap the tile anytime to copy your account number',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
