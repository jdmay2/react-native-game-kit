# react-native-game-kit

A **React Native** (Expo or Bare Workflow) library that integrates:

- **iOS**: [Apple GameKit (Game Center)](https://developer.apple.com/game-center/)
- **Android**: [Google Play Games Services (GPGS)](https://developers.google.com/games/services)

This allows you to **authenticate players**, **show leaderboards**, **submit scores**, **show/unlock achievements**, and optionally **support multiplayer**—all using a single JavaScript API.

---

## Contents

1. [Features](#features)
2. [Installation](#installation)
3. [Expo Configuration](#expo-configuration)
4. [iOS Setup](#ios-setup)
5. [Android Setup](#android-setup)
6. [Usage Example](#usage-example)
7. [Advanced: Multiplayer (Optional)](#advanced-multiplayer-optional)
8. [Contributing](#contributing)
9. [License](#license)

---

## Features

- **Cross-Platform** sign-in:
  - **iOS** uses **Game Center**
  - **Android** uses **Google Play Games**
- Leaderboards (show UI, submit scores)
- Achievements (show UI, report/unlock achievements, increment)
- (Optional) Real-time & Turn-based multiplayer stubs for advanced usage
- **Expo Config Plugin** for easy setup in Managed Workflow

---

## Installation

### 1. Install the Library

Using npm:

```bash
npm install react-native-cross-platform-game-services
```

Or using yarn:

```bash
yarn add react-native-cross-platform-game-services
```

### 2. If Using Expo Managed Workflow

Add the plugin to your app.json or app.config.js:

```json
{
  "expo": {
    // ...
    "plugins": ["react-native-cross-platform-game-services"]
  }
}
```

Then rebuild with EAS or prebuild:

```bash
npx expo prebuild
npx expo run:ios
```

or

```bash
eas build -p ios
eas build -p android
```

### 3. If Using Bare React Native

- <b>iOS:</b> Ensure ios/Podfile has the necessary pods installed (e.g. pod install), and confirm com.apple.developer.game-center is enabled in your entitlements.
- <b>Android:</b> Autolinking should add the library, or you can manually configure settings.gradle and app/build.gradle. Also verify com.google.android.gms:play-services-games is included in dependencies (the config plugin should handle it).

## Expo Configuration

This library includes a config plugin (app.plugin.js) that:

1. <b>iOS:</b> Sets com.apple.developer.game-center to true in your entitlements.
2. <b>Android:</b> Inserts com.google.android.gms:play-services-games dependency into your Gradle file.

If you’re in the Expo Managed Workflow, be sure to run prebuild or an EAS build so these changes are applied to the native iOS/Android projects.

### iOS Setup

1. Enable Game Center in your Apple Developer Portal.
2. Make sure your app ID has Game Center entitlement.
3. If you want real-time or turn-based multiplayer, also enable the appropriate capabilities in Xcode or via entitlements.

### Android Setup

1. In the Google Play Console, create or open your Google Play Games project.
2. Register your app with the correct package name and (optionally) SHA-1 certificate fingerprints.
3. Create Leaderboards, Achievements, etc. in the console if you plan to use them.
4. The library’s config plugin automatically adds com.google.android.gms:play-services-games to your Gradle dependencies.

### Usage Example

In your React Native or Expo app:

```js
import React, { useEffect } from "react";
import { View, Button, Text } from "react-native";
import { GameServices } from "react-native-cross-platform-game-services";

export default function App() {
  useEffect(() => {
    // Cross-platform sign-in on mount
    // iOS -> Game Center
    // Android -> Google Play Games
    GameServices.signInOrAuthenticate()
      .then((res) => {
        console.log("Sign-in success:", res);
      })
      .catch((err) => {
        console.error("Sign-in error:", err);
      });
  }, []);

  const handleShowLeaderboard = () => {
    GameServices.showLeaderboard("YOUR_LEADERBOARD_ID").catch((err) =>
      console.error("Leaderboard error:", err)
    );
  };

  const handleSubmitScore = () => {
    GameServices.submitScore("YOUR_LEADERBOARD_ID", 12345)
      .then(() => console.log("Score submitted"))
      .catch((err) => console.error("Submit score error:", err));
  };

  const handleShowAchievements = () => {
    GameServices.showAchievements().catch((err) =>
      console.error("Show achievements error:", err)
    );
  };

  const handleUnlockAchievement = () => {
    // iOS -> reportAchievement(achievementID, percent)
    // Android -> unlockAchievement(achievementID)
    GameServices.unlockAchievement("YOUR_ACHIEVEMENT_ID").catch((err) =>
      console.error("Achievement error:", err)
    );
  };

  return (
    <View style={{ marginTop: 50, padding: 20 }}>
      <Text style={{ fontSize: 18, marginBottom: 10 }}>
        Cross-Platform Game Services Demo
      </Text>
      <Button title="Show Leaderboard" onPress={handleShowLeaderboard} />
      <Button title="Submit Score" onPress={handleSubmitScore} />
      <Button title="Show Achievements" onPress={handleShowAchievements} />
      <Button title="Unlock Achievement" onPress={handleUnlockAchievement} />
    </View>
  );
}
```

### Advanced: Multiplayer (Optional)

#### iOS: GameKit

- Real-time matches: implement GKMatchmakerViewControllerDelegate, GKMatchDelegate.
- Turn-based matches: implement GKTurnBasedMatchmakerViewControllerDelegate.

#### Android: Play Games

- Real-time multiplayer: Use RealTimeMultiplayerClient.
- Turn-based multiplayer: Use TurnBasedMultiplayerClient.

The included iOS/Android code can be expanded with event emitters for full real-time or turn-based support.

## Contributing

Contributions are welcome! Please:

1. Fork the repository on GitHub.
2. Create a feature branch (git checkout -b feature/new-stuff).
3. Commit your changes.
4. Open a Pull Request describing your work.

If you encounter any issues, please open a GitHub Issue with:

- Steps to reproduce
- Your environment (RN version, device info, etc.)

## License

MIT License

Copyright (c) 2024 Joseph May

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```

```
