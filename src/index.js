import { NativeModules, Platform } from "react-native";

const { RNGameServices } = NativeModules;

// iOS-only methods (Game Center)
async function gc_authenticatePlayer() {
  return RNGameServices.authenticatePlayer();
}
async function gc_showLeaderboard(leaderboardID) {
  return RNGameServices.showLeaderboard(leaderboardID);
}
async function gc_submitScore(leaderboardID, score) {
  return RNGameServices.submitScore(leaderboardID, score);
}
// etc. for achievements, matchmaking, etc.

// Android-only methods (Play Games)
async function pg_initClient() {
  return RNGameServices.initClient();
}
async function pg_signIn() {
  return RNGameServices.signIn();
}
async function pg_showLeaderboard(leaderboardId) {
  return RNGameServices.showLeaderboard(leaderboardId);
}
async function pg_submitScore(leaderboardId, score) {
  return RNGameServices.submitScore(leaderboardId, score);
}
// etc. for achievements, etc.

// Cross-platform facade
export const GameServices = {
  /**
   * Cross-platform authenticate / sign-in.
   */
  async signInOrAuthenticate(params = {}) {
    if (Platform.OS === "ios") {
      // iOS: GameKit
      return gc_authenticatePlayer();
    } else if (Platform.OS === "android") {
      // Android: Play Games
      await pg_initClient();
      return pg_signIn();
    } else {
      throw new Error("Unsupported platform for GameServices");
    }
  },

  /**
   * Show leaderboard
   */
  async showLeaderboard(leaderboardID) {
    if (Platform.OS === "ios") {
      return gc_showLeaderboard(leaderboardID);
    } else if (Platform.OS === "android") {
      return pg_showLeaderboard(leaderboardID);
    } else {
      throw new Error("Unsupported platform");
    }
  },

  /**
   * Submit a score
   */
  async submitScore(leaderboardID, score) {
    if (Platform.OS === "ios") {
      return gc_submitScore(leaderboardID, score);
    } else if (Platform.OS === "android") {
      return pg_submitScore(leaderboardID, score);
    } else {
      throw new Error("Unsupported platform");
    }
  },

  /**
   * Show achievements
   */
  async showAchievements() {
    if (Platform.OS === "ios") {
      return RNGameServices.showAchievements();
    } else if (Platform.OS === "android") {
      return RNGameServices.showAchievements();
    } else {
      throw new Error("Unsupported platform");
    }
  },

  /**
   * Report/unlock an achievement
   */
  async unlockAchievement(achievementID, percent = 100) {
    if (Platform.OS === "ios") {
      // iOS uses 'reportAchievement' with a percent
      return RNGameServices.reportAchievement(achievementID, percent);
    } else if (Platform.OS === "android") {
      return RNGameServices.unlockAchievement(achievementID);
    } else {
      throw new Error("Unsupported platform");
    }
  },

  // etc. for real-time / turn-based, bridging iOS and Android calls
};
