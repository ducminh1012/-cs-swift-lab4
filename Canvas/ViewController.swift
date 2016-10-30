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

  @IBAction func onTrayPanGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
    let state = panGestureRecognizer.state
    var translation: CGPoint!

    switch state {
    case .began:
      trayOriginalCenter = trayView.center

    case .changed:
      translation = panGestureRecognizer.translation(in: view)
      let velocity = panGestureRecognizer.velocity(in: view)

      if velocity.y < 0 {
        if trayView.center.y > trayCenterWhenOpen.y {
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
        } else {
          trayView.center = CGPoint(x: trayCenterWhenOpen.x, y: trayCenterWhenOpen.y + translation.y / 10)
        }
        if isArrowDown {
          arrowImageView.transform = arrowImageView.transform.rotated(by: CGFloat(M_PI))
          isArrowDown = false
        }
      } else {
        trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
        if !isArrowDown {
          arrowImageView.transform = arrowImageView.transform.rotated(by: CGFloat(M_PI))
          isArrowDown = true
        }
      }

    case .ended:
      let velocity = panGestureRecognizer.velocity(in: view)
      if velocity.y > 0 {
        // Close the tray
        trayView.center = trayCenterWhenClosed

        if isArrowDown {
          arrowImageView.transform = arrowImageView.transform.rotated(by: CGFloat(M_PI))
          isArrowDown = false
        }
      } else {
        // Open the tray
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 2, options: [], animations: { () -> Void in
          self.trayView.center = self.trayCenterWhenOpen

          if !self.isArrowDown {
            self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: CGFloat(M_PI))
            self.isArrowDown = true
          }
          }, completion: { (bool) -> Void in
        })
      }

    default:
      break
    }
  }

  @IBAction func onFacePanGesture(_ sender: UIPanGestureRecognizer) {
    let state = sender.state
    var translation: CGPoint!

    switch state {
    case .began:
      // Gesture recognizers know the view they are attached to
      let imageView = sender.view as! UIImageView

      // Save the center of original face
      originalFaceCenter = trayView.convert(imageView.center, to: view)

      // Create a new image view that has the same image as the one currently panning
      newlyCreatedFace = UIImageView(image: imageView.image)

      // Add the new face to the tray's parent view.
      view.addSubview(newlyCreatedFace)

      // Initialize the position of the new face.
      newlyCreatedFace.center = imageView.center

      // Make the face bigger
      newlyCreatedFace.transform = CGAffineTransform(scaleX: 2, y: 2)

      // Since the original face is in the tray, but the new face is in the
      // main view, you have to offset the coordinates
      newlyCreatedFace.center.y += trayView.frame.origin.y
      initialNewFaceCenter = newlyCreatedFace.center

      // Add pan gesture for this new face
      newlyCreatedFace.isUserInteractionEnabled = true
      let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.onNewFacePanGesture(_:)))
      newlyCreatedFace.addGestureRecognizer(panGesture)

      // Add pinch gesture for this new face
      let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.onNewFacePinchGesture(_:)))
      newlyCreatedFace.addGestureRecognizer(pinchGesture)

      // Add rotation gesture for this new face
      let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(ViewController.onNewFaceRotationGesture(_:)))
      rotationGesture.delegate = self
      newlyCreatedFace.addGestureRecognizer(rotationGesture)

      // Add double tap gesture for this new face
      let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.onNewFaceDoubleTapGesture(_:)))
      doubleTapGesture.numberOfTapsRequired = 2
      newlyCreatedFace.addGestureRecognizer(doubleTapGesture)

    case .changed:
      translation = sender.translation(in: view)
      newlyCreatedFace.center = CGPoint(x: initialNewFaceCenter.x + translation.x, y: initialNewFaceCenter.y + translation.y)

    case .ended:
      if newlyCreatedFace.center.y < trayView.frame.origin.y {
        newlyCreatedFace.transform = CGAffineTransform.identity
      } else {
        UIView.animate(withDuration: 0.5, animations: {
          self.newlyCreatedFace.transform = CGAffineTransform.identity
          self.newlyCreatedFace.center = self.originalFaceCenter
          }, completion: { finished in
            self.newlyCreatedFace.removeFromSuperview()
        })
      }

    default:
      break
    }
  }

  func onNewFacePanGesture(_ sender: UIPanGestureRecognizer) {
    if let currentFace = sender.view {
      let state = sender.state
      var translation: CGPoint!

      switch state {
      case .began:
        initialCurrentFaceCenter = currentFace.center
      case .changed:
        translation = sender.translation(in: view)
        currentFace.center = CGPoint(x: initialCurrentFaceCenter.x + translation.x, y: initialCurrentFaceCenter.y + translation.y)
      default:
        break
      }
    }
  }

  func onNewFacePinchGesture(_ sender: UIPinchGestureRecognizer) {
    if let currentFace = sender.view {
      currentFace.transform = currentFace.transform.scaledBy(x: sender.scale, y: sender.scale)
      sender.scale = 1
    }
  }

  func onNewFaceRotationGesture(_ sender: UIRotationGestureRecognizer) {
    if let currentFace = sender.view {
      currentFace.transform = currentFace.transform.rotated(by: sender.rotation)
      sender.rotation = 0
    }
  }

  func onNewFaceDoubleTapGesture(_ sender: UITapGestureRecognizer) {
    if let currentFace = sender.view {
      currentFace.removeFromSuperview()
    }
  }
  
}

extension ViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
