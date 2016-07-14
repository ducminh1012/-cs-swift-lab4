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

  override func viewDidLoad() {
    super.viewDidLoad()
    print(trayView.center)
    trayCenterWhenOpen = CGPoint(x: 160, y: 481)
    trayCenterWhenClosed = CGPoint(x: 160, y: 617)
  }

  @IBAction func onTrayPanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
    let state = panGestureRecognizer.state
    let point = panGestureRecognizer.locationInView(view)
    var translation: CGPoint!

    if state == UIGestureRecognizerState.Began {
      print("Gesture began at: \(point)")
      trayOriginalCenter = trayView.center
    } else if state == UIGestureRecognizerState.Changed {
      print("Gesture changed at: \(point)")
      translation = panGestureRecognizer.translationInView(view)
      trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
    } else if state == UIGestureRecognizerState.Ended {
      print("Gesture ended at: \(point)")
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
    }
  }

}
