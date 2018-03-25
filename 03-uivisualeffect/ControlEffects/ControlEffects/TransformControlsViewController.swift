//
// Copyright 2014 Scott Logic
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

protocol TransformControlsDelegate {
  func transformDidChange(_ transform: CGAffineTransform, sender: AnyObject)
}

struct Vect2D {
  var x: Float
  var y: Float
  
  var xCG: CGFloat {
    return CGFloat(x)
  }
  var yCG: CGFloat {
    return CGFloat(y)
  }
}

class TransformControlsViewController: UIViewController {
  
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var rotationSlider: UISlider!
  @IBOutlet weak var xScaleSlider: UISlider!
  @IBOutlet weak var yScaleSlider: UISlider!
  @IBOutlet weak var xTranslationSlider: UISlider!
  @IBOutlet weak var yTranslationSlider: UISlider!
  
  var transformDelegate: TransformControlsDelegate?
  var currentTransform: CGAffineTransform?
  
  var backgroundView: UIVisualEffectView?
  
  override func viewDidLoad() {
    if currentTransform != nil {
      applyTransformToSliders(currentTransform!)
    }
    
    backgroundView = prepareVisualEffectView()
    view.addSubview(backgroundView!)
    applyEqualSizeConstraints(view, v2: backgroundView!, includeTop: false)
    view.backgroundColor = UIColor.clear
  }
  
  
  func prepareVisualEffectView() -> UIVisualEffectView {
    // Create the blur effect
    let blurEffect = UIBlurEffect(style: .light)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.contentView.backgroundColor = UIColor.clear
    
    // Create the vibrancy effect - to be added to the blur
    let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
    let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
    
    // Add the content to the views appropriately
    vibrancyEffectView.contentView.addSubview(containerView)
    blurEffectView.contentView.addSubview(vibrancyEffectView)
    
    // Prepare autolayout
    containerView.translatesAutoresizingMaskIntoConstraints = false
    blurEffectView.translatesAutoresizingMaskIntoConstraints = false
    vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false
    
    applyEqualSizeConstraints(vibrancyEffectView.contentView, v2: containerView, includeTop: true)
    applyEqualSizeConstraints(blurEffectView.contentView, v2: vibrancyEffectView, includeTop: true)
    
    return blurEffectView
  }
  
  func applyEqualSizeConstraints(_ v1: UIView, v2: UIView, includeTop: Bool) {
    v1.addConstraint(NSLayoutConstraint(item: v1, attribute: .left, relatedBy: .equal, toItem: v2, attribute: .left, multiplier: 1, constant: 0))
    v1.addConstraint(NSLayoutConstraint(item: v1, attribute: .right, relatedBy: .equal, toItem: v2, attribute: .right, multiplier: 1, constant: 0))
    v1.addConstraint(NSLayoutConstraint(item: v1, attribute: .bottom, relatedBy: .equal, toItem: v2, attribute: .bottom, multiplier: 1, constant: 0))
    if(includeTop) {
      v1.addConstraint(NSLayoutConstraint(item: v1, attribute: .top, relatedBy: .equal, toItem: v2, attribute: .top, multiplier: 1, constant: 0))
    }
  }
  

  
  @IBAction func handleSliderValueChanged(_ sender: UISlider) {
    let transform = transformFromSliders()
    currentTransform = transform
    transformDelegate?.transformDidChange(transform, sender: self)
  }
  
  
  @IBAction func handleDismissButtonPressed(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  func transformFromSliders() -> CGAffineTransform
  {
    let scale = Vect2D(x: xScaleSlider.value, y: yScaleSlider.value)
    let translation = Vect2D(x: xTranslationSlider.value, y: yTranslationSlider.value)
    
    return constructTransform(rotationSlider.value, scale: scale, translation: translation)
  }
  
  func applyTransformToSliders(_ transform: CGAffineTransform) {
    let decomposition = decomposeAffineTransform(transform)
    rotationSlider.value = decomposition.rotation
    xScaleSlider.value = decomposition.scale.x
    yScaleSlider.value = decomposition.scale.y
    xTranslationSlider.value = decomposition.translation.x
    yTranslationSlider.value = decomposition.translation.y
  }
  
  func constructTransform(_ rotation: Float, scale: Vect2D, translation: Vect2D) -> CGAffineTransform {
    let rotnTransform = CGAffineTransform(rotationAngle: CGFloat(rotation))
    let scaleTransform = rotnTransform.scaledBy(x: scale.xCG, y: scale.yCG)
    let translationTransform = scaleTransform.translatedBy(x: translation.xCG, y: translation.yCG)
    return translationTransform
  }
  
  
  func decomposeAffineTransform(_ transform: CGAffineTransform) -> (rotation: Float, scale: Vect2D, translation: Vect2D) {
    // This requires a specific ordering (and no skewing). It matches the constructTransform method
    
    // Translation first
    let translation = Vect2D(x: Float(transform.tx), y: Float(transform.ty))
    
    // Then scale
    let scaleX = sqrt(Double(transform.a * transform.a + transform.c * transform.c))
    let scaleY = sqrt(Double(transform.b * transform.b + transform.d * transform.d))
    let scale = Vect2D(x: Float(scaleX), y: Float(scaleY))
    
    // And rotation
    let rotation = Float(atan2(Double(transform.b), Double(transform.a)))
    
    return (rotation, scale, translation)
  }
}

