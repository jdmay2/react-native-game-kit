//
//  RNGameServices.swift
//  react-native-game-kit
//
//  Created by jdmay2 on 12/22/2024.
//

import Foundation
import GameKit

@objc(RNGameServices)
class RNGameServices: NSObject {

  // Holds a reference to a current real-time match for iOS
  private var currentMatch: GKMatch?
  private var currentTurnBasedMatch: GKTurnBasedMatch?

  // MARK: - Authentication (Game Center)

  @objc
  func authenticatePlayer(_ resolve: @escaping RCTPromiseResolveBlock,
                          rejecter reject: @escaping RCTPromiseRejectBlock) {
    let localPlayer = GKLocalPlayer.local
    localPlayer.authenticateHandler = { [weak self] viewController, error in
      guard let _ = self else { return }

      if let error = error {
        reject("GAMEKIT_ERROR", error.localizedDescription, error)
        return
      }
      if let vc = viewController {
        DispatchQueue.main.async {
          if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(vc, animated: true, completion: nil)
          } else {
            reject("NO_ROOT_VIEW_CONTROLLER", "No root to present Game Center login", nil)
          }
        }
      } else if localPlayer.isAuthenticated {
        resolve([
          "authenticated": true,
          "playerID": localPlayer.playerID,
          "alias": localPlayer.alias
        ])
      } else {
        resolve(["authenticated": false])
      }
    }
  }

  // MARK: - Leaderboards

  @objc
  func showLeaderboard(_ leaderboardID: NSString,
                       resolve: @escaping RCTPromiseResolveBlock,
                       rejecter reject: @escaping RCTPromiseRejectBlock) {
    guard GKLocalPlayer.local.isAuthenticated else {
      reject("GAMEKIT_ERROR", "Player not authenticated.", nil)
      return
    }
    let gcVC = GKGameCenterViewController()
    gcVC.viewState = .leaderboards
    gcVC.leaderboardIdentifier = leaderboardID as String
    gcVC.gameCenterDelegate = self

    presentGameCenterController(gcVC, resolve: resolve, reject: reject)
  }

  @objc
  func submitScore(_ leaderboardID: NSString,
                   score: NSInteger,
                   resolve: @escaping RCTPromiseResolveBlock,
                   rejecter reject: @escaping RCTPromiseRejectBlock) {
    guard GKLocalPlayer.local.isAuthenticated else {
      reject("GAMEKIT_ERROR", "Player not authenticated.", nil)
      return
    }

    let gkScore = GKScore(leaderboardIdentifier: leaderboardID as String)
    gkScore.value = Int64(score)

    GKScore.report([gkScore]) { error in
      if let error = error {
        reject("GAMEKIT_ERROR", error.localizedDescription, error)
      } else {
        resolve(["status": "Score submitted"])
      }
    }
  }

  // MARK: - Achievements

  @objc
  func showAchievements(_ resolve: @escaping RCTPromiseResolveBlock,
                        rejecter reject: @escaping RCTPromiseRejectBlock) {
    guard GKLocalPlayer.local.isAuthenticated else {
      reject("GAMEKIT_ERROR", "Player not authenticated.", nil)
      return
    }
    let gcVC = GKGameCenterViewController()
    gcVC.viewState = .achievements
    gcVC.gameCenterDelegate = self

    presentGameCenterController(gcVC, resolve: resolve, reject: reject)
  }

  @objc
  func reportAchievement(_ achievementID: NSString,
                         percent: Double,
                         resolve: @escaping RCTPromiseResolveBlock,
                         rejecter reject: @escaping RCTPromiseRejectBlock) {
    guard GKLocalPlayer.local.isAuthenticated else {
      reject("GAMEKIT_ERROR", "Player not authenticated.", nil)
      return
    }

    let achievement = GKAchievement(identifier: achievementID as String)
    achievement.percentComplete = percent
    achievement.showsCompletionBanner = true

    GKAchievement.report([achievement]) { error in
      if let error = error {
        reject("GAMEKIT_ERROR", error.localizedDescription, error)
      } else {
        resolve(["status": "Achievement reported"])
      }
    }
  }

  // MARK: - Real-time Multiplayer (Optional)

  @objc
  func presentMatchmaker(_ minPlayers: NSNumber,
                         maxPlayers: NSNumber,
                         resolve: @escaping RCTPromiseResolveBlock,
                         rejecter reject: @escaping RCTPromiseRejectBlock) {
    guard GKLocalPlayer.local.isAuthenticated else {
      reject("GAMEKIT_ERROR", "Player not authenticated.", nil)
      return
    }

    let request = GKMatchRequest()
    request.minPlayers = minPlayers.intValue
    request.maxPlayers = maxPlayers.intValue

    let mmVC = GKMatchmakerViewController(matchRequest: request)
    mmVC?.matchmakerDelegate = self

    DispatchQueue.main.async {
      if let rootVC = UIApplication.shared.keyWindow?.rootViewController,
         let mmVC = mmVC {
        rootVC.present(mmVC, animated: true, completion: nil)
        resolve(nil)
      } else {
        reject("NO_ROOT_VIEW_CONTROLLER", "No root to present matchmaker.", nil)
      }
    }
  }

  // etc. (sendData, GKMatchDelegate stubs)...

  // MARK: - Turn-based Multiplayer (Optional)

  @objc
  func presentTurnBasedMatchmaker(_ minPlayers: NSNumber,
                                  maxPlayers: NSNumber,
                                  resolve: @escaping RCTPromiseResolveBlock,
                                  rejecter reject: @escaping RCTPromiseRejectBlock) {
    guard GKLocalPlayer.local.isAuthenticated else {
      reject("GAMEKIT_ERROR", "Player not authenticated.", nil)
      return
    }

    let request = GKMatchRequest()
    request.minPlayers = minPlayers.intValue
    request.maxPlayers = maxPlayers.intValue

    let tbmmVC = GKTurnBasedMatchmakerViewController(matchRequest: request)
    tbmmVC.turnBasedMatchmakerDelegate = self

    DispatchQueue.main.async {
      if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
        rootVC.present(tbmmVC, animated: true, completion: nil)
        resolve(nil)
      } else {
        reject("NO_ROOT_VIEW_CONTROLLER", "No root to present TB matchmaker.", nil)
      }
    }
  }

  // and so forth...

  // MARK: - Helper

  private func presentGameCenterController(_ gcVC: GKGameCenterViewController,
                                           resolve: @escaping RCTPromiseResolveBlock,
                                           reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async {
      if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
        rootVC.present(gcVC, animated: true, completion: nil)
        resolve(nil)
      } else {
        reject("NO_ROOT_VIEW_CONTROLLER", "No root to present GC interface.", nil)
      }
    }
  }
}

// MARK: - Delegates
extension RNGameServices: GKGameCenterControllerDelegate {
  func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
    gameCenterViewController.dismiss(animated: true, completion: nil)
  }
}

extension RNGameServices: GKMatchmakerViewControllerDelegate {
  func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
    viewController.dismiss(animated: true, completion: nil)
    self.currentMatch = match
    // etc.
  }

  func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
    viewController.dismiss(animated: true, completion: nil)
  }

  func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
    viewController.dismiss(animated: true, completion: nil)
  }
}

extension RNGameServices: GKMatchDelegate {
  func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
    // handle data
  }
  // etc.
}

extension RNGameServices: GKTurnBasedMatchmakerViewControllerDelegate {
  func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
    viewController.dismiss(animated: true, completion: nil)
  }

  func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController,
                                         didFailWithError error: Error) {
    viewController.dismiss(animated: true, completion: nil)
  }

  func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController,
                                         didFind match: GKTurnBasedMatch) {
    viewController.dismiss(animated: true, completion: nil)
    self.currentTurnBasedMatch = match
    // etc.
  }
}

// MARK: - React Native Bridge
@objc(RNGameServices)
extension RNGameServices: RCTBridgeModule {
  static func moduleName() -> String! {
    return "RNGameServices"
  }
}