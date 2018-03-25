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

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
  var window: UIWindow?
  let timerNotificationManager = TimerNotificationManager()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    if let vc = window?.rootViewController as? ViewController {
      vc.timerNotificationManager = timerNotificationManager
    }
    
    return true
  }
  
  func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
    // Pass the "firing" event onto the notification manager
    timerNotificationManager.timerFired()
    if application.applicationState == .active {
      let alert = UIAlertController(title: "NotifyTimely", message: "Your time is up", preferredStyle: .alert)
      // Handler for each of the actions
      let actionAndDismiss = {
        (action: String?) -> ((UIAlertAction!) -> ()) in
        return {
          _ in
          self.timerNotificationManager.handleActionWithIdentifier(action)
          self.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
      }
      
      alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: actionAndDismiss(nil)))
      alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: actionAndDismiss(restartTimerActionString)))
      alert.addAction(UIAlertAction(title: "Snooze", style: .destructive, handler: actionAndDismiss(snoozeTimerActionString)))
      window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
  }
  
  func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
    // Pass the action name onto the manager
    timerNotificationManager.handleActionWithIdentifier(identifier)
    completionHandler()
  }

}

