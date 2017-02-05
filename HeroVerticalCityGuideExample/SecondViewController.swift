// The MIT License (MIT)
//
// Copyright (c) 2016 Luke Zhao <me@lkzhao.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Hero

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

class SecondViewController: UIViewController {
  var city:City?

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!

  var panGR: UIPanGestureRecognizer!
  override func viewDidLoad() {
    super.viewDidLoad()

    if let city = city {
      let name = city.name
      nameLabel.text = name
      nameLabel.heroID = "\(name)_name"
      nameLabel.heroModifiers = [.zPosition(4)]
      imageView.image = city.image
      imageView.heroID = "\(name)_image"
      imageView.heroModifiers = [.zPosition(2)]
      descriptionLabel.heroID = "\(name)_description"
      descriptionLabel.heroModifiers = [.zPosition(4)]
      descriptionLabel.text = city.description
    }

    panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
    view.addGestureRecognizer(panGR)
  }

  func handlePan(gestureRecognizer:UIPanGestureRecognizer) {
    // calculate the progress based on how far the user moved
    let translation = panGR.translation(in: nil)
    let progress = translation.y / 2 / view.bounds.height

    switch panGR.state {
    case .began:
      // begin the transition as normal
      dismiss(animated: true, completion: nil)
    case .changed:
      Hero.shared.update(progress: Double(progress))

      // update views' position (limited to only vertical scroll)
      Hero.shared.apply(modifiers: [.position(CGPoint(x:imageView.center.x, y:translation.y + imageView.center.y))], to: imageView)
      Hero.shared.apply(modifiers: [.position(CGPoint(x:nameLabel.center.x, y:translation.y + nameLabel.center.y))], to: nameLabel)
      Hero.shared.apply(modifiers: [.position(CGPoint(x:descriptionLabel.center.x, y:translation.y + descriptionLabel.center.y))], to: descriptionLabel)
    default:
      // end or cancel the transition based on the progress and user's touch velocity
      if progress + panGR.velocity(in: nil).y / view.bounds.height > 0.3 {
        Hero.shared.end()
      } else {
        Hero.shared.cancel()
      }
    }
  }
}
