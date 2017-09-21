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

final class Beer: NSObject, NSCoding {
  
  // MARK: Keys
  fileprivate enum Keys: String {
    case Name = "name"
    case Rating = "rating"
    case ImagePath = "image"
    case Note = "note"
  }
  
  // MARK: - Properties
  var name: String
  var rating: Int
  var imagePath: String?
  var note: String?
  
  // MARK: - Initializers
  override init() {
    name = ""
    rating = 1
    super.init()
  }
  
  init(name: String, imagePath: String? = nil, note: String?, rating: Int) {
    self.name = name
    self.imagePath = imagePath
    self.note = note
    self.rating = rating
    super.init()
  }
  
  // MARK: - NSCoding
  required init?(coder aDecoder: NSCoder) {
    name = aDecoder.decodeObject(forKey: Keys.Name.rawValue) as! String
    rating = (aDecoder.decodeObject(forKey: Keys.Rating.rawValue) as! NSNumber).intValue
    imagePath = aDecoder.decodeObject(forKey: Keys.ImagePath.rawValue) as? String
    note = aDecoder.decodeObject(forKey: Keys.Note.rawValue) as? String
  }
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(name, forKey: Keys.Name.rawValue)
    aCoder.encode(NSNumber(value: rating), forKey: Keys.Rating.rawValue)
    aCoder.encode(imagePath, forKey: Keys.ImagePath.rawValue)
    aCoder.encode(note, forKey: Keys.Note.rawValue)
  }
}

// MARK: - Image Saving
extension Beer {
  
  func saveImage(_ image: UIImage) {
    guard let imgData = UIImageJPEGRepresentation(image, 0.5),
      let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
        return
    }
    
    let fileName = "\(UUID().uuidString).jpg"
    let pathName = (path as NSString).appendingPathComponent(fileName)
    if (try? imgData.write(to: URL(fileURLWithPath: pathName), options: [.atomic])) != nil {
      imagePath = fileName
    }
  }
  
  func beerImage() -> UIImage? {
    guard let imagePath = imagePath,
      let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
        return nil
    }
    
    let pathName = (path as NSString).appendingPathComponent(imagePath)
    return UIImage(contentsOfFile: pathName)
  }
}

// MARK: - Exporting
extension Beer {
  
  func exportToFileURL() -> URL? {
    // 1
    var contents: [String : Any] = [Keys.Name.rawValue: name, Keys.Rating.rawValue: rating]
    
    // 2
    if let image = beerImage() {
      if let data = UIImageJPEGRepresentation(image, 1) {
        contents[Keys.ImagePath.rawValue] = data.base64EncodedString()
      }
    }
    
    // 3
    if let note = note {
      contents[Keys.Note.rawValue] = note
    }
    
    // 4
    guard let path = FileManager.default
      .urls(for: .documentDirectory, in: .userDomainMask).first else {
        return nil
    }
    
    // 5
    let saveFileURL = path.appendingPathComponent("/\(name).btkr")
    (contents as NSDictionary).write(to: saveFileURL, atomically: true)
    return saveFileURL
  }
}

// MARK: - Importing
extension Beer {
  
  static func importData(from url: URL) {
    // 1
    guard let dictionary = NSDictionary(contentsOf: url),
      let beerInfo = dictionary as? [String: AnyObject],
      let name = beerInfo[Keys.Name.rawValue] as? String,
      let rating = beerInfo[Keys.Rating.rawValue] as? NSNumber else {
        return
    }
    
    // 2
    let beer = Beer(name: name, note: beerInfo[Keys.Note.rawValue] as? String, rating: rating.intValue)
    
    // 3
    if let base64 = beerInfo[Keys.ImagePath.rawValue] as? String,
      let imageData = Data(base64Encoded: base64, options: .ignoreUnknownCharacters),
      let image = UIImage(data: imageData) {
      beer.saveImage(image)
    }
    
    // 4
    BeerManager.sharedInstance.beers.append(beer)
    BeerManager.sharedInstance.saveBeers()
    
    // 5
    do {
      try FileManager.default.removeItem(at: url)
    } catch {
      print("Failed to remove item from Inbox")
    }
  }
}
