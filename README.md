# Astawash - Ethiopian Bank Account Quick Copy

A Flutter app that provides a convenient way to store and quickly copy Ethiopian bank account numbers through Android Quick Settings. Perfect for merchants, freelancers, or anyone who frequently needs to share their bank account numbers.

## Features

✨ **Smart Account Management**
- Store multiple bank accounts
- Edit or delete saved accounts
- Supports all Ethiopian banks
- Smart account number format hints for major banks
- Autocomplete bank name selection

🔄 **Quick Settings Integration**
- One-tap account number copy from Quick Settings
- Automatic copy for single accounts
- Selection dialog for multiple accounts
- Works even when the app is closed

🎨 **Modern Material Design**
- Clean and intuitive interface
- Material You theming
- Smooth animations
- Responsive layout

🔒 **Privacy & Security**
- Works completely offline
- No internet permission required
- Secure local storage
- No sensitive data transmission

## Supported Banks

The app includes smart account number format hints for:
- Commercial Bank of Ethiopia (CBE)
- Dashen Bank
- Awash Bank

And supports all other Ethiopian banks including:
- Abyssinia Bank
- Birhan Bank
- Nib Bank
- United Bank
- Wegagen Bank
- Oromia Bank
- Zemen Bank
- And any custom bank entry

## Installation

1. Download the latest APK from the [releases](https://github.com/Samuel-Fikre/Astawash/releases) section
2. Install on your Android device (Android 5.0 or later)
3. Grant permission to display over other apps when prompted
4. Add the Quick Settings tile:
   - Swipe down twice to open Quick Settings
   - Tap the edit (pencil) icon
   - Find "Copy Account" and drag it to your active tiles

## Usage

### Adding Bank Accounts
1. Open the app
2. Select or type your bank name
3. Enter your account number
4. Tap "Add Bank Account"

### Quick Copying
- **Single Account**: Just tap the Quick Settings tile to copy
- **Multiple Accounts**: Tap the tile and select the account to copy

### Managing Accounts
- **Edit**: Tap the edit icon on any account to modify it
- **Delete**: Tap the delete icon to remove an account
- **Add More**: You can add multiple accounts from the same or different banks

## Development

### Prerequisites
- Flutter 3.0 or higher
- Android Studio / VS Code
- Android SDK

### Setup
1. Clone the repository:
```bash
git clone https://github.com/Samuel-Fikre/Astawash.git
```

2. Install dependencies:
```bash
cd Astawash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building
To create a release APK:
```bash
flutter build apk --release
```

## Contributing

Contributions are welcome! Here are some ways you can contribute:
- Report bugs and suggest features
- Add support for more bank account number formats
- Improve the UI/UX
- Add new features
- Write documentation

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to all Ethiopian banks for their services
- Flutter team for the amazing framework
- Material Design team for the beautiful design system

## Contact

Samuel Fikre - [@SamuelFikre](https://twitter.com/SamuelFikre)

Project Link: [https://github.com/Samuel-Fikre/Astawash](https://github.com/Samuel-Fikre/Astawash)
