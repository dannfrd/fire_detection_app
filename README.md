# 🔥 Fire Detection App

A Flutter-based mobile application for real-time fire detection and monitoring using ESP32 sensors.

## 📱 About

This mobile application is designed to work in conjunction with ESP32 hardware sensors to provide real-time fire detection capabilities. The app receives sensor data and provides immediate alerts and monitoring features for fire safety management.

## ✨ Features

- 🔥 Real-time fire detection monitoring
- 📊 Sensor data visualization
- 🚨 Instant alert notifications
- 📱 Cross-platform support (Android, iOS, Web)
- 🌐 ESP32 integration
- 📈 Historical data tracking
- ⚙️ Configurable alert thresholds

## 🛠️ Technology Stack

- **Framework**: Flutter
- **Language**: Dart
- **Hardware**: ESP32 sensors
- **Platforms**: Android, iOS, Web, Windows, macOS, Linux

## 📋 Prerequisites

Before running this application, make sure you have:

- Flutter SDK (>=2.0.0)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- ESP32 hardware setup
- Git

## 🚀 Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd fire_detections_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For development
   flutter run

   # For specific platform
   flutter run -d android
   flutter run -d ios
   flutter run -d web
   ```

## 🏗️ Build for Production

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

## 📁 Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
├── screens/                  # UI screens
├── widgets/                  # Reusable widgets
├── services/                 # API and business logic
├── utils/                    # Utility functions
└── constants/                # App constants
```

## 🔧 Configuration

1. **ESP32 Setup**: Configure your ESP32 device with the appropriate sensors
2. **Network Configuration**: Update connection settings in the app
3. **Alert Thresholds**: Customize fire detection sensitivity

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

## 📱 Supported Platforms

- ✅ Android

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Your Name** - *Initial work*

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- ESP32 community for hardware support
- Fire safety organizations for guidance

## 📞 Support

If you have any questions or need help, please:
- Open an issue on GitHub
- Contact: [your-email@example.com]

## 🔄 Version History

- **v1.0.0** - Initial release with basic fire detection features

---

**⚠️ Safety Notice**: This application is designed to assist in fire detection but should not be the sole safety measure. Always follow proper fire safety protocols and have professional fire detection systems in place.
