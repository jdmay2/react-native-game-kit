package com.qwady.rngameservices;

import androidx.annotation.NonNull;
import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import com.facebook.react.bridge.*;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.games.*;
import com.google.android.gms.games.leaderboard.*;
import com.google.android.gms.games.achievement.*;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;

public class RNGameServicesModule extends ReactContextBaseJavaModule {

    private final String TAG = "RNGameServices";
    private ReactApplicationContext reactContext;
    private boolean isSigningIn = false;
    private static final int RC_SIGN_IN = 9001;
    private static final int RC_LEADERBOARD_UI = 9002;
    private static final int RC_ACHIEVEMENT_UI = 9003;

    private GamesSignInClient signInClient;
    private LeaderboardsClient leaderboardsClient;
    private AchievementsClient achievementsClient;
    // for real-time: RealTimeMultiplayerClient, InvitationsClient, etc.

    public RNGameServicesModule(ReactApplicationContext context) {
        super(context);
        this.reactContext = context;
    }

    @NonNull
    @Override
    public String getName() {
        return "RNGameServices";
    }

    @ReactMethod
    public void initClient(Promise promise) {
        Activity activity = getCurrentActivity();
        if (activity == null) {
            promise.reject("NO_ACTIVITY", "No current activity to init Google Play Games");
            return;
        }
        // Check if Google Play services is available
        int status = GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(activity);
        if (status != ConnectionResult.SUCCESS) {
            promise.reject("PLAY_SERVICES_ERROR", "Google Play Services not available (status: " + status + ")");
            return;
        }

        signInClient = PlayGames.getGamesSignInClient(activity);
        leaderboardsClient = PlayGames.getLeaderboardsClient(activity);
        achievementsClient = PlayGames.getAchievementsClient(activity);
        // etc. for real-time, turn-based:
        // realTimeMultiplayerClient = PlayGames.getRealTimeMultiplayerClient(activity);
        // turnBasedMultiplayerClient =
        // PlayGames.getTurnBasedMultiplayerClient(activity);

        promise.resolve(true);
    }

    @ReactMethod
    public void signIn(Promise promise) {
        Activity activity = getCurrentActivity();
        if (activity == null) {
            promise.reject("NO_ACTIVITY", "No current activity for sign-in");
            return;
        }
        if (signInClient == null) {
            promise.reject("CLIENT_NOT_INITIALIZED", "Call initClient() first.");
            return;
        }

        isSigningIn = true;
        signInClient.signIn().addOnCompleteListener(task -> {
            isSigningIn = false;
            if (task.isSuccessful()) {
                // The user is signed in
                promise.resolve("Signed in to Google Play Games");
            } else {
                // Sign-in failed
                Exception e = task.getException();
                if (e != null) {
                    promise.reject("SIGN_IN_FAILED", e.getMessage(), e);
                } else {
                    promise.reject("SIGN_IN_FAILED", "Unknown error");
                }
            }
        });
    }

    @ReactMethod
    public void showLeaderboard(String leaderboardId, Promise promise) {
        if (leaderboardsClient == null) {
            promise.reject("CLIENT_NOT_INITIALIZED", "Call initClient() first.");
            return;
        }
        leaderboardsClient.getLeaderboardIntent(leaderboardId)
                .addOnSuccessListener(intent -> {
                    Activity activity = getCurrentActivity();
                    if (activity != null) {
                        activity.startActivityForResult(intent, RC_LEADERBOARD_UI);
                        promise.resolve(null);
                    } else {
                        promise.reject("NO_ACTIVITY", "No current activity to show leaderboard");
                    }
                })
                .addOnFailureListener(e -> {
                    promise.reject("LEADERBOARD_ERROR", e.getMessage(), e);
                });
    }

    @ReactMethod
    public void submitScore(String leaderboardId, int score, Promise promise) {
        if (leaderboardsClient == null) {
            promise.reject("CLIENT_NOT_INITIALIZED", "Call initClient() first.");
            return;
        }
        leaderboardsClient.submitScore(leaderboardId, score);
        promise.resolve(true);
    }

    @ReactMethod
    public void showAchievements(Promise promise) {
        if (achievementsClient == null) {
            promise.reject("CLIENT_NOT_INITIALIZED", "Call initClient() first.");
            return;
        }
        achievementsClient.getAchievementsIntent()
                .addOnSuccessListener(intent -> {
                    Activity activity = getCurrentActivity();
                    if (activity != null) {
                        activity.startActivityForResult(intent, RC_ACHIEVEMENT_UI);
                        promise.resolve(null);
                    } else {
                        promise.reject("NO_ACTIVITY", "No current activity to show achievements");
                    }
                })
                .addOnFailureListener(e -> {
                    promise.reject("ACHIEVEMENT_ERROR", e.getMessage(), e);
                });
    }

    @ReactMethod
    public void unlockAchievement(String achievementId, Promise promise) {
        if (achievementsClient == null) {
            promise.reject("CLIENT_NOT_INITIALIZED", "Call initClient() first.");
            return;
        }
        achievementsClient.unlock(achievementId);
        promise.resolve(true);
    }

    // For incremental achievements:
    @ReactMethod
    public void incrementAchievement(String achievementId, int steps, Promise promise) {
        if (achievementsClient == null) {
            promise.reject("CLIENT_NOT_INITIALIZED", "Call initClient() first.");
            return;
        }
        achievementsClient.increment(achievementId, steps);
        promise.resolve(true);
    }

    // Additional Real-time or Turn-based methods would go here...
    // e.g. createMatch, joinMatch, sendReliableMessage, handle invites, etc.
}