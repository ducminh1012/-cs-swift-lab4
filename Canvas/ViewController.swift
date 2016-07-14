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

  override func viewDidLoad() {
    super.viewDidLoad()
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
    }
  }

}
