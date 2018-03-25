//
// Copyright 2014 Scott Logic
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import UIKit

let restartTimerActionString = "RestartTimer"
let editTimerActionString = "EditTimer"
let snoozeTimerActionString = "SnoozeTimer"
let timerFiredCategoryString = "TimerFiredCategory"


protocol TimerNotificationManagerDelegate {
  func timerStatusChanged()
  func presentEditOptions()
}

class TimerNotificationManager: CustomStringConvertible {
  let snoozeDuration: Float = 5.0
  var delegate: TimerNotificationManagerDelegate?
  
  var timerRunning: Bool {
    didSet {
      delegate?.timerStatusChanged()
    }
  }
  
  var timerDuration: Float {
    didSet {
      delegate?.timerStatusChanged()
    }
  }
  
  var description: String {
    if timerRunning {
      return "\(timerDuration)s timer, running"
    } else {
      return "\(timerDuration)s timer, stopped"
    }
  }

  init() {
    timerRunning = false
    timerDuration = 30.0
    registerForNotifications()
    checkForPreExistingTimer()
  }
  
  func startTimer() {
    if !timerRunning {
      // Create the notification...
      scheduleTimerWithOffset(timerDuration)
    }
  }
  
  func stopTimer() {
    if timerRunning {
      // Kill all local notifications
      UIApplication.shared.cancelAllLocalNotifications()
      timerRunning = false
    }
  }
  
  func restartTimer() {
    stopTimer()
    startTimer()
  }
  
  func timerFired() {
    timerRunning = false
  }
  
  func handleActionWithIdentifier(_ identifier: String?) {
    timerRunning = false
    if let identifier = identifier {
      switch identifier {
      case restartTimerActionString:
        restartTimer()
      case snoozeTimerActionString:
        scheduleTimerWithOffset(snoozeDuration)
      case editTimerActionString:
        delegate?.presentEditOptions()
      default:
        print("Unrecognised Identifier")
      }
    }
  }
  
  // MARK: - Utility methods
  fileprivate func checkForPreExistingTimer() {
    if (UIApplication.shared.scheduledLocalNotifications?.count)! > 0 {
      timerRunning = true
    }
  }
  
  fileprivate func scheduleTimerWithOffset(_ fireOffset: Float) {
    let timer = createTimer(fireOffset)
    UIApplication.shared.scheduleLocalNotification(timer)
    timerRunning = true
  }

  fileprivate func createTimer(_ fireOffset: Float) -> UILocalNotification {
    let notification = UILocalNotification()
    notification.category = timerFiredCategoryString
    notification.fireDate = Date(timeIntervalSinceNow: TimeInterval(fireOffset))
    notification.alertBody = "Your time is up!"
    return notification
  }
  
  fileprivate func registerForNotifications() {
    
    let categories = Set(arrayLiteral: timerFiredNotificationCategory())
    
    
    let settingsRequest = UIUserNotificationSettings(types: [.alert,.sound], categories: categories)
    UIApplication.shared.registerUserNotificationSettings(settingsRequest)
  }
  
  fileprivate func timerFiredNotificationCategory() -> UIUserNotificationCategory {
    let restartAction = UIMutableUserNotificationAction()
    restartAction.identifier = restartTimerActionString
    restartAction.isDestructive = false
    restartAction.title = "Restart"
    restartAction.activationMode = .background
    restartAction.isAuthenticationRequired = false
    
    let editAction = UIMutableUserNotificationAction()
    editAction.identifier = editTimerActionString
    editAction.isDestructive = true
    editAction.title = "Edit"
    editAction.activationMode = .foreground
    editAction.isAuthenticationRequired = true
    
    let snoozeAction = UIMutableUserNotificationAction()
    snoozeAction.identifier = snoozeTimerActionString
    snoozeAction.isDestructive = false
    snoozeAction.title = "Snooze"
    snoozeAction.activationMode = .background
    snoozeAction.isAuthenticationRequired = false
    
    let category = UIMutableUserNotificationCategory()
    category.identifier = timerFiredCategoryString
    category.setActions([restartAction, snoozeAction], for: .minimal)
    category.setActions([restartAction, snoozeAction, editAction], for: .default)
    
    return category
  }
}
