//
//  POIListViewController.swift
//  CustomRotorTableViewNavigation
//
//  Created by Madushan on 15/6/18.
//  Copyright © 2018 ICE. All rights reserved.
//

import UIKit

class POIListViewController: UITableViewController {

  lazy fileprivate var objects: [POI] = {
    let dataSource = DataSource()
    return dataSource.data
  }()

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table View

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return objects.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

    let object = objects[indexPath.row]
    cell.textLabel!.text = object.name
    cell.detailTextLabel?.text = object.isFavourite ? "💛" : nil
    cell.accessibilityLabel = object.name
    cell.accessibilityValue = object.isFavourite ? "Favourite" : nil
    return cell
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }

  override var accessibilityCustomRotors: [UIAccessibilityCustomRotor]? {
    get {
      return rotors
    }
    set {}
  }

  private lazy var rotors: [UIAccessibilityCustomRotor]? = {
    let favoritesRotor = UIAccessibilityCustomRotor(name: "Favourite POIs") { predicate in
      guard
        // UITableViewCell is set as TargetElement. However `predicate.currentItem.targetElement` cannot be accessed as an UITableViewCell?
        let accessibilityElement = predicate.currentItem.targetElement as? NSObject,
        let label = accessibilityElement.accessibilityLabel,
        let cell = self.tableView.visibleCells.filter({
          return $0.accessibilityLabel == label
        }).first,
        let indexPath = self.tableView.indexPath(for: cell)
        else {
          let index = self.objects.index { $0.isFavourite == true }
          let cell = self.tableView.cellForRow(at: IndexPath(row: index!, section: 0))

          defer {
            // Post Notification 01
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: cell)
          }

          return UIAccessibilityCustomRotorItemResult(targetElement: cell!, targetRange: nil)
      }

      let nextIndex: Int?

      switch (predicate.searchDirection, indexPath.row) {
      case let (.previous, index):
        if let i = self.objects[0..<index].reversed().firstIndex(where: { $0.isFavourite }) {
          nextIndex = self.objects.index(before: i.base)
        } else {
          nextIndex = nil
        }
      case let (.next, index):
        let lowerBound = index + 1
        nextIndex = self.objects[lowerBound...].firstIndex { $0.isFavourite }
      }

      guard
        let next = nextIndex
        else { return nil }

      /*
       Scrolling is required to ensure navigation even if the next element is off-screen
       */
      self.tableView.scrollToRow(at: IndexPath(row: next, section: 0),
                                 at: .middle,
                                 animated: false)
      guard
        let cellToBeFocused = self.tableView.cellForRow(at: IndexPath(row: next, section: 0))
        else { return nil }

      defer {
        // Post Notification 02
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: cellToBeFocused)
      }
      return UIAccessibilityCustomRotorItemResult(targetElement: cellToBeFocused, targetRange: nil)
    }
    return [favoritesRotor]
  }()
}


private struct DataSource {
  var data: [POI] = {
    let data: [POI] = [
      POI(name: "MConvention Center"),
      POI(name: "Marina One", isFavourite: true),
      POI(name: "Marina View", isFavourite: true),
      POI(name: "Four Season Hotel"),
      POI(name: "Station One"),
      POI(name: "Bay View Center"),
      POI(name: "City Center"),
      POI(name: "City Center 2"),
      POI(name: "City Center 3"),
      POI(name: "City Center 4"),
      POI(name: "City Center 6", isFavourite: true),
      POI(name: "City Center 7")
    ]
    return data
  }()
}

private struct POI {
  let name: String
  let isFavourite: Bool

  init(name: String, isFavourite: Bool = false) {
    self.name = name
    self.isFavourite = isFavourite
  }
}

