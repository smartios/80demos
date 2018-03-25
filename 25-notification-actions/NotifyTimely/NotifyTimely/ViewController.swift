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

class ViewController: UIViewController, TimerConfigurationDelegate, TimerNotificationManagerDelegate {
  
  var timerNotificationManager: TimerNotificationManager? {
    didSet {
      timerNotificationManager?.delegate = self
    }
  }
  
  @IBOutlet weak var timerStatusLabel: PaddedLabel!
  @IBOutlet weak var restartButton: UIButton!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  @IBOutlet weak var editButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureTimerUI()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "configureTimer" {
      if let configVC = segue.destination as? ConfigureTimerViewController {
        configVC.timerConfigDelegate = self
      }
    }
  }
  
  @IBAction func handleTimerButtonPress(_ sender: UIButton) {
    switch sender {
    case restartButton:
      timerNotificationManager?.restartTimer()
    case startButton:
      timerNotificationManager?.startTimer()
    case stopButton:
      timerNotificationManager?.stopTimer()
    default:
      print("Unknown Sender")
    }
  }
  
  fileprivate func configureTimerUI() {
    if let timerRunning = timerNotificationManager?.timerRunning {
      setButton(restartButton, enabled: timerRunning)
      setButton(startButton, enabled: !timerRunning)
      setButton(stopButton, enabled: timerRunning)
      setButton(editButton, enabled: !timerRunning)
      
      timerStatusLabel.text = "\(timerNotificationManager!)"
    }
  }
  
  fileprivate func setButton(_ button: UIButton, enabled: Bool) {
    button.isEnabled = enabled
    button.alpha = enabled ? 1.0 : 0.3
  }
  
  // MARK: - TimerConfigurationDelegate Methods
  func configurationDidCancel() {
    dismiss(animated: true, completion: nil)
  }
  
  func configurationDidSetDuration(_ duration: Float) {
    timerNotificationManager?.timerDuration = duration
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: - TimerNotificationManagerDelegate methods
  func timerStatusChanged() {
    configureTimerUI()
  }
  
  func presentEditOptions() {
    performSegue(withIdentifier: "configureTimer", sender: self)
  }

}

