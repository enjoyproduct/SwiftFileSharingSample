/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

final class BeerCell: UITableViewCell {
  
  // MARK: - Properties
  var beer: Beer? {
    didSet {
      guard let beer = beer else {
        nameLabel.text = nil
        ratingView.rating = 0
        beerImageView.image = nil
        return
      }
      
      nameLabel.text = beer.name
      ratingView.rating = beer.rating
      beerImageView.image = beer.beerImage()
      beerImageView.isHidden = beer.beerImage() == nil
    }
  }
  
  // MARK: - IBOutlets
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var ratingView: STRatingControl!
  @IBOutlet var beerImageView: UIImageView!
}
