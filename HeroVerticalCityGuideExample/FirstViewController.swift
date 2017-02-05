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

class FirstViewController: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  var cities = City.cities
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let currentCell = sender as? CityCell,
      let vc = segue.destination as? SecondViewController {
      vc.city = currentCell.city
    }
  }

  var panGR: UIPanGestureRecognizer!
  var slidingCell: CityCell?
  override func viewDidLoad() {
    super.viewDidLoad()

    panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
    view.addGestureRecognizer(panGR)
  }

  func handlePan(gestureRecognizer:UIPanGestureRecognizer) {
    // calculate the progress based on how far the user moved
    let translation = panGR.translation(in: nil)
    let progress = -translation.x / view.bounds.width

    switch panGR.state {
    case .began:
      // begin the transition when sliding left
      if panGR.velocity(in: nil).x < 0,
        let indexPath = collectionView.indexPathForItem(at: panGR.location(in: collectionView)) {
        let toVC = self.storyboard!.instantiateViewController(withIdentifier: "second") as! SecondViewController
        toVC.city = cities[indexPath.item]

        slidingCell = collectionView.cellForItem(at: indexPath) as! CityCell?
        slidingCell!.imageView.heroID = nil
        slidingCell!.nameLabel.heroID = nil
        slidingCell!.descriptionLabel.heroID = nil
        slidingCell!.heroModifiers = [.translate(x: -100)]
        view.heroModifiers = [.translate(x:-view.bounds.width)]
        toVC.view.heroModifiers = [.translate(x:view.bounds.width)]

        // begin the transition as normal
        present(toVC, animated: true, completion: nil)
      }
    case .changed:
      if let slidingCell = slidingCell, let toVC = Hero.shared.toViewController as? SecondViewController {
        Hero.shared.update(progress: Double(progress))

        // update views' position (limited to only vertical scroll)
        let cellTranslationX = translation.x < -100 ? -100 : translation.x
        let wholeViewTranslationX = translation.x < -100 ? translation.x + 100 : 0
        Hero.shared.apply(modifiers: [.translate(x:cellTranslationX)], to: slidingCell)
        Hero.shared.apply(modifiers: [.translate(x:wholeViewTranslationX)], to: view)
        Hero.shared.apply(modifiers: [.translate(x:wholeViewTranslationX + view.bounds.width)], to: toVC.view)
      }
    default:
      if let slidingCell = slidingCell, let toVC = Hero.shared.toViewController as? SecondViewController {
        slidingCell.reset() // reset heroModifers for the slidingCell
        toVC.view.heroModifiers = nil
        view.heroModifiers = nil

        // end or cancel the transition based on the progress and user's touch velocity
        if progress + -panGR.velocity(in: nil).x / view.bounds.width > 0.3 {
          Hero.shared.end()
        } else {
          Hero.shared.cancel()
        }
      }
    }
  }
}

extension FirstViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return cities.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as? CityCell)!
    cell.city = cities[indexPath.item]
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.bounds.width, height: view.bounds.height / CGFloat(cities.count))
  }
}
