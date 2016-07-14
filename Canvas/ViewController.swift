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

  var trayOriginalCenter: CGPoint!
  var trayCenterWhenOpen: CGPoint!
  var trayCenterWhenClosed: CGPoint!

  var newlyCreatedFace: UIImageView!
  var initialNewFaceCenter: CGPoint!

  var initialCurrentFaceCenter: CGPoint!

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
    case .Ended:
      let velocity = panGestureRecognizer.velocityInView(view)
      if velocity.y > 0 {
        // Close the tray
        trayView.center = trayCenterWhenClosed
      } else {
        // Open the tray
        UIView.animateWithDuration(2, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 2, options: [], animations: { () -> Void in
          self.trayView.center = self.trayCenterWhenOpen
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
    case .Changed:
      translation = sender.translationInView(view)
      newlyCreatedFace.center = CGPoint(x: initialNewFaceCenter.x + translation.x, y: initialNewFaceCenter.y + translation.y)
    case .Ended:
      newlyCreatedFace.transform = CGAffineTransformMakeScale(1, 1)
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
  
}
