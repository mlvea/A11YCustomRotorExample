//
//  POIListViewControllerTests.swift
//  CustomRotorTableViewNavigationTests
//
//  Created by Madushan on 15/6/18.
//  Copyright © 2018 ICE. All rights reserved.
//

import XCTest
@testable import CustomRotorTableViewNavigation

class POIListViewControllerTests: XCTestCase {


  var viewController: POIListViewController!

  override func setUp() {
    let bundle = Bundle(for: POIListViewController.self)
    viewController = UIStoryboard(name: "Main", bundle: bundle).instantiateViewController(withIdentifier: "POIListViewController") as? POIListViewController
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.endAppearanceTransition()
  }

  override func tearDown() {
  }

  func testThatFavoriteCustomRotorNavigatesAccuratelyInNextDirection() {

    guard
      let cell = viewController.tableView.visibleCells.first(where: { (cell) -> Bool in
        cell.accessibilityLabel == "Marina One"
      }) else {
        XCTFail("No visisble Favourite cell found")
        return
      }

    let searchPredicate = UIAccessibilityCustomRotorSearchPredicate()
    searchPredicate.currentItem = UIAccessibilityCustomRotorItemResult(targetElement: cell, targetRange: nil)
    searchPredicate.searchDirection = .next

    let rotor = viewController.accessibilityCustomRotors?.filter({ (rotor) -> Bool in
      rotor.name == "Favourite POIs"
    }).first

    let searchBlock = rotor?.itemSearchBlock
    let item = searchBlock?(searchPredicate)?.targetElement as? UITableViewCell

    XCTAssertTrue(item?.accessibilityLabel == "Marina View" , "Custom predicate navigation order doen's give expected results.")
  }

}
