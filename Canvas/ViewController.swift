//
//  ViewController.swift
//  Canvas
//
//  Created by Chau Vo on 7/14/16.
//  Copyright © 2016 Chau Vo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var trayView: UIView!
  @IBOutlet weak var arrowImageView: UIImageView!

  var trayOriginalCenter: CGPoint!
  var trayCenterWhenOpen: CGPoint!
  var trayCenterWhenClosed: CGPoint!

  var newlyCreatedFace: UIImageView!
  var initialNewFaceCenter: CGPoint!

  var initialCurrentFaceCenter: CGPoint!
  var originalFaceCenter: CGPoint!

  var isArrowDown = true

  override func viewDidLoad() {
    super.viewDidLoad()
    print(trayView.center)
    trayCenterWhenOpen = CGPoint(x: 160, y: 481)
    trayCenterWhenClosed = CGPoint(x: 160, y: 617)
  }

  @IBAction func onTrayPanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
    let state = panGestureRecognizer.state
    var translation: CGPoint!

    switch state {
    case .Began:
      trayOriginalCenter = trayView.center

    case .Changed:
      translation = panGestureRecognizer.translationInView(view)
      trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)

      let velocity = panGestureRecognizer.velocityInView(view)
      if velocity.y < 0 {
        if isArrowDown {
          arrowImageView.transform = CGAffineTransformRotate(arrowImageView.transform, CGFloat(M_PI))
          isArrowDown = false
        }
      } else {
        if !isArrowDown {
          arrowImageView.transform = CGAffineTransformRotate(arrowImageView.transform, CGFloat(M_PI))
          isArrowDown = true
        }
      }

    case .Ended:
      let velocity = panGestureRecognizer.velocityInView(view)
      if velocity.y > 0 {
        // Close the tray
        trayView.center = trayCenterWhenClosed

        if isArrowDown {
          arrowImageView.transform = CGAffineTransformRotate(arrowImageView.transform, CGFloat(M_PI))
          isArrowDown = false
        }
      } else {
        // Open the tray
        UIView.animateWithDuration(2, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 2, options: [], animations: { () -> Void in
          self.trayView.center = self.trayCenterWhenOpen

          if !self.isArrowDown {
            self.arrowImageView.transform = CGAffineTransformRotate(self.arrowImageView.transform, CGFloat(M_PI))
            self.isArrowDown = true
          }
          }, completion: { (bool) -> Void in
        })
      }

    default:
      break
    }
  }

  @IBAction func onFacePanGesture(sender: UIPanGestureRecognizer) {
    let state = sender.state
    var translation: CGPoint!

    switch state {
    case .Began:
      // Gesture recognizers know the view they are attached to
      let imageView = sender.view as! UIImageView

      // Save the center of original face
      originalFaceCenter = trayView.convertPoint(imageView.center, toView: view)

      // Create a new image view that has the same image as the one currently panning
      newlyCreatedFace = UIImageView(image: imageView.image)

      // Add the new face to the tray's parent view.
      view.addSubview(newlyCreatedFace)

      // Initialize the position of the new face.
      newlyCreatedFace.center = imageView.center

      // Make the face bigger
      newlyCreatedFace.transform = CGAffineTransformMakeScale(2, 2)

      // Since the original face is in the tray, but the new face is in the
      // main view, you have to offset the coordinates
      newlyCreatedFace.center.y += trayView.frame.origin.y
      initialNewFaceCenter = newlyCreatedFace.center

      // Add pan gesture for this new face
      newlyCreatedFace.userInteractionEnabled = true
      let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.onNewFacePanGesture(_:)))
      newlyCreatedFace.addGestureRecognizer(panGesture)

      // Add pinch gesture for this new face
      let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.onNewFacePinchGesture(_:)))
      newlyCreatedFace.addGestureRecognizer(pinchGesture)

      // Add rotation gesture for this new face
      let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(ViewController.onNewFaceRotationGesture(_:)))
      rotationGesture.delegate = self
      newlyCreatedFace.addGestureRecognizer(rotationGesture)

    case .Changed:
      translation = sender.translationInView(view)
      newlyCreatedFace.center = CGPoint(x: initialNewFaceCenter.x + translation.x, y: initialNewFaceCenter.y + translation.y)

    case .Ended:
      if newlyCreatedFace.center.y < trayView.frame.origin.y {
        newlyCreatedFace.transform = CGAffineTransformIdentity
      } else {
        UIView.animateWithDuration(0.5, animations: {
          self.newlyCreatedFace.transform = CGAffineTransformIdentity
          self.newlyCreatedFace.center = self.originalFaceCenter
          }, completion: { finished in
            self.newlyCreatedFace.removeFromSuperview()
        })
      }

    default:
      break
    }
  }

  func onNewFacePanGesture(sender: UIPanGestureRecognizer) {
    if let currentFace = sender.view {
      let state = sender.state
      var translation: CGPoint!

      switch state {
      case .Began:
        initialCurrentFaceCenter = currentFace.center
      case .Changed:
        translation = sender.translationInView(view)
        currentFace.center = CGPoint(x: initialCurrentFaceCenter.x + translation.x, y: initialCurrentFaceCenter.y + translation.y)
      default:
        break
      }
    }
  }

  func onNewFacePinchGesture(sender: UIPinchGestureRecognizer) {
    if let currentFace = sender.view {
      currentFace.transform = CGAffineTransformScale(currentFace.transform, sender.scale, sender.scale)
      sender.scale = 1
    }
  }

  func onNewFaceRotationGesture(sender: UIRotationGestureRecognizer) {
    if let currentFace = sender.view {
      currentFace.transform = CGAffineTransformRotate(currentFace.transform, sender.rotation)
      sender.rotation = 0
    }
  }
  
}

extension ViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
