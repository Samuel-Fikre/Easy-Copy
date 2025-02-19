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

class BankAccount {
  String bankName;
  String accountNumber;

  BankAccount({required this.bankName, required this.accountNumber});

  Map<String, dynamic> toJson() => {
        'bankName': bankName,
        'accountNumber': accountNumber,
      };

  factory BankAccount.fromJson(Map<String, dynamic> json) => BankAccount(
        bankName: json['bankName'],
        accountNumber: json['accountNumber'],
      );
}

class AccountNumberScreen extends StatefulWidget {
  const AccountNumberScreen({super.key});

  @override
  State<AccountNumberScreen> createState() => _AccountNumberScreenState();
}

class _AccountNumberScreenState extends State<AccountNumberScreen> {
  final TextEditingController _accountController = TextEditingController();
  TextEditingController _bankNameController = TextEditingController();
  bool _isLoading = true;
  List<BankAccount> _bankAccounts = [];
  static const String keyBankAccounts = 'flutter.bankAccounts';
  bool _isEditing = false;
  int? _editingIndex;

  // Default suggested banks
  final List<String> _suggestedBanks = [
    'Commercial Bank of Ethiopia',
    'Abyssinia Bank',
    'Dashen Bank',
    'Birhan Bank',
    'Awash Bank',
    'Nib Bank',
    'United Bank',
    'Wegagen Bank',
    'Oromia Bank',
    'Zemen Bank',
  ];

  @override
  void initState() {
    super.initState();
    _loadBankAccounts();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  Future<void> _loadBankAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsList = prefs.getStringList(keyBankAccounts) ?? [];

      // Debug logging
      print('Loading accounts from SharedPreferences:');
      print('Key: $keyBankAccounts');
      print('Raw data: $accountsList');

      setState(() {
        _bankAccounts = accountsList
            .map((json) => BankAccount.fromJson(
                Map<String, dynamic>.from(Uri.splitQueryString(json))))
            .toList();
        _isLoading = false;
      });

      // Log loaded accounts
      print('Loaded accounts: $_bankAccounts');
    } catch (e) {
      print('Error loading bank accounts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startEditing(BankAccount account, int index) {
    setState(() {
      _isEditing = true;
      _editingIndex = index;
      _bankNameController.text = account.bankName;
      _accountController.text = account.accountNumber;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editingIndex = null;
      _bankNameController.clear();
      _accountController.clear();
    });
  }

  Future<void> _saveBankAccount() async {
    if (_accountController.text.trim().isEmpty ||
        _bankNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both bank name and account number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final newAccount = BankAccount(
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountController.text.trim(),
      );

      setState(() {
        if (_isEditing && _editingIndex != null) {
          _bankAccounts[_editingIndex!] = newAccount;
          _isEditing = false;
          _editingIndex = null;
        } else {
          _bankAccounts.add(newAccount);
        }
      });

      final prefs = await SharedPreferences.getInstance();
      final accountsList = _bankAccounts
          .map((account) => Uri(queryParameters: account.toJson()).query)
          .toList();

      // Debug logging
      print('Saving accounts to SharedPreferences:');
      print('Key: $keyBankAccounts');
      print('Data: $accountsList');

      await prefs.setStringList(keyBankAccounts, accountsList);

      // Verify the save
      final savedData = prefs.getStringList(keyBankAccounts);
      print('Verification - Read back data: $savedData');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isEditing ? 'Bank account updated!' : 'Bank account saved!'),
            backgroundColor: Colors.green,
          ),
        );
        _accountController.clear();
        _bankNameController.clear();
      }
    } catch (e) {
      print('Error saving bank account: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save bank account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAccount(int index) async {
    try {
      setState(() {
        _bankAccounts.removeAt(index);
      });

      final prefs = await SharedPreferences.getInstance();
      final accountsList = _bankAccounts
          .map((account) => Uri(queryParameters: account.toJson()).query)
          .toList();
      await prefs.setStringList(keyBankAccounts, accountsList);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bank account deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete bank account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelEditing,
              tooltip: 'Cancel Editing',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? 'Edit Bank Account' : 'Add Bank Account',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return _suggestedBanks;
                }
                return [
                  ..._suggestedBanks,
                  ..._bankAccounts
                      .map((account) => account.bankName)
                      .where((bank) => !_suggestedBanks.contains(bank))
                ].where((bank) => bank
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) {
                _bankNameController.text = selection;
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                _bankNameController = controller;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Bank Name',
                    border: OutlineInputBorder(),
                    hintText: 'Enter or select bank name',
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _accountController,
              decoration: const InputDecoration(
                labelText: 'Account Number',
                border: OutlineInputBorder(),
                hintText: '1000123456789',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveBankAccount,
              icon: Icon(_isEditing ? Icons.save : Icons.add),
              label:
                  Text(_isEditing ? 'Update Bank Account' : 'Add Bank Account'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Saved Bank Accounts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _bankAccounts.length,
                itemBuilder: (context, index) {
                  final account = _bankAccounts[index];
                  return Card(
                    child: ListTile(
                      title: Text(account.bankName),
                      subtitle: Text('Account: ${account.accountNumber}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _startEditing(account, index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteAccount(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            const Text(
              'Quick Settings Tile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'To use Quick Settings:\n'
              '1. Swipe down to open Quick Settings\n'
              '2. Tap the edit (pencil) icon\n'
              '3. Find "Copy Account" and drag it to active tiles\n'
              '4. Tap the tile to see your saved accounts\n'
              '5. Select an account to copy its number',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
