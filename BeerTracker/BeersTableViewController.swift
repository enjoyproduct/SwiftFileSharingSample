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

final class BeersTableViewController: UITableViewController {
  
  // MARK: - SegueIdentifiers
  fileprivate enum SegueIdentifier: String {
    case ViewBeer
  }
  
  // MARK: - Outlets
  @IBOutlet var emptyView: UIView!
  
  // MARK: - View Setup
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    tableView.reloadData()
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == SegueIdentifier.ViewBeer.rawValue {
      let cell = sender as! BeerCell
      let indexPath = tableView.indexPath(for: cell)!
      let upcoming = segue.destination as! BeerDetailViewController
      upcoming.detailBeer = BeerManager.sharedInstance.beers[(indexPath as NSIndexPath).row]
    }
  }
}

// MARK: - Table view data source
extension BeersTableViewController {
  
  // MARK: - CellIdentifiers
  fileprivate enum CellIdentifier: String {
    case Cell
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = BeerManager.sharedInstance.beers.count
    if count == 0 {
      tableView.backgroundView = emptyView
    } else {
      tableView.backgroundView = nil
    }
    return count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.Cell.rawValue, for: indexPath) as! BeerCell
    cell.beer = BeerManager.sharedInstance.beers[(indexPath as NSIndexPath).row]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    guard case(.delete) = editingStyle else { return }
    
    tableView.beginUpdates()
    BeerManager.sharedInstance.beers.remove(at: (indexPath as NSIndexPath).row)
    BeerManager.sharedInstance.saveBeers()
    tableView.deleteRows(at: [indexPath], with: .automatic)
    tableView.endUpdates()
  }
}
