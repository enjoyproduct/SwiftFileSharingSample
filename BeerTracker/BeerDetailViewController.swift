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

final class BeerDetailViewController: UIViewController {
  
  // MARK: - Outlets
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var nameField: UITextField!
  @IBOutlet var ratingView: STRatingControl!
  @IBOutlet var notesView: UITextView!
  @IBOutlet var tapToAddMessage: UILabel!
  
  // MARK: - Properties
  var detailBeer: Beer?
  var pickedImage: UIImage?
  
  // MARK: - View Setup
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imageView.layer.cornerRadius = imageView.bounds.width / 2
    imageView.layer.borderColor = UIColor.black.cgColor
    imageView.layer.borderWidth = 1
    
    if let detailBeer = detailBeer {
      title = detailBeer.name
      nameField.text = detailBeer.name
      ratingView.rating = detailBeer.rating
      notesView.text = detailBeer.note
      if let image = detailBeer.beerImage() {
        imageView.image = image
        imageView.backgroundColor = .white
        tapToAddMessage.isHidden = true
      }
    } else {
      detailBeer = Beer()
      title = "New Beer"
      ratingView.rating = 1
      navigationItem.rightBarButtonItem = nil
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    saveBeer()
  }
}

// MARK: - IBActions
extension BeerDetailViewController {
  
  @IBAction func share(_ sender: AnyObject) {
    guard let detailBeer = detailBeer,
      let url = detailBeer.exportToFileURL() else {
        return
    }
    
    let activityViewController = UIActivityViewController(
      activityItems: ["Check out this beer I liked using Beer Tracker.", url],
      applicationActivities: nil)
    if let popoverPresentationController = activityViewController.popoverPresentationController {
      popoverPresentationController.barButtonItem = (sender as! UIBarButtonItem)
    }
    present(activityViewController, animated: true, completion: nil)
  }
  
  @IBAction func pickPhoto(_ sender: AnyObject) {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let takePhotoAction = UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""), style: .default, handler: { [unowned self] _ in
        self.showImagePicker(withSourceType: .camera)
        })
      alertController.addAction(takePhotoAction)
    }
    
    let chooseFromLibraryAction = UIAlertAction(title: NSLocalizedString("Choose From Library", comment: ""), style: .default, handler: { [unowned self] _ in
      self.showImagePicker(withSourceType: .photoLibrary)
      })
    alertController.addAction(chooseFromLibraryAction)
    
    if let popoverPresentationController = alertController.popoverPresentationController {
      popoverPresentationController.sourceView = imageView
    }
    present(alertController, animated: true, completion: nil)
  }
}

// MARK: - Private
private extension BeerDetailViewController {
  
  func saveBeer() {
    guard let detailBeer = detailBeer,
      let name = nameField.text , !name.isEmpty else {
        return
    }
    
    detailBeer.name = name
    detailBeer.rating = ratingView.rating
    detailBeer.note = notesView.text
    
    if let pickedImage = pickedImage {
      detailBeer.saveImage(pickedImage)
    }
    
    if !BeerManager.sharedInstance.beers.contains(detailBeer) {
      BeerManager.sharedInstance.beers.append(detailBeer)
    }
    
    BeerManager.sharedInstance.saveBeers()
  }
}

// MARK: - UIImagePickerControllerDelegate
extension BeerDetailViewController: UIImagePickerControllerDelegate {
  
  func showImagePicker(withSourceType source: UIImagePickerControllerSourceType) {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = source
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    imagePicker.view.tintColor = view.tintColor
    present(imagePicker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
      dismiss(animated: true, completion: nil)
      return
    }
    
    pickedImage = image
    if let subView = imageView.subviews.first {
      subView.removeFromSuperview()
    }
    
    imageView.image = pickedImage
    tapToAddMessage.isHidden = true
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - UINavigationControllerDelegate
extension BeerDetailViewController: UINavigationControllerDelegate {
}
