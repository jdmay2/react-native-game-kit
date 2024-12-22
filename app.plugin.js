const {
  withInfoPlist,
  withEntitlementsPlist,
  withAppBuildGradle,
  createRunOncePlugin,
} = require("@expo/config-plugins");

function setGameCenterEntitlements(config) {
  return withEntitlementsPlist(config, (configProps) => {
    configProps.modResults["com.apple.developer.game-center"] = true;
    return configProps;
  });
}

function setAndroidGradle(config) {
  return withAppBuildGradle(config, (configProps) => {
    if (
      !configProps.modResults.contents.includes(
        "com.google.android.gms:play-services-games"
      )
    ) {
      // Insert the Play Games dependency
      configProps.modResults.contents = configProps.modResults.contents.replace(
        /dependencies\s?{/,
        `dependencies {
      implementation 'com.google.android.gms:play-services-games:23.1.0' // or latest version`
      );
    }
    return configProps;
  });
}

function withCrossPlatformGameServices(config) {
  config = setGameCenterEntitlements(config);
  config = setAndroidGradle(config);
  // Possibly also withInfoPlist if you want to add any iOS usage descriptions
  return config;
}

module.exports = createRunOncePlugin(
  withCrossPlatformGameServices,
  "react-native-cross-platform-game-services",
  "1.0.0"
);
