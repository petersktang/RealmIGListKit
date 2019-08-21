//
//  SectionController.swift
//  RealmIGListKit
//
//  Created by Peter Tang on 22/8/2019.
//  Copyright © 2019 Peter Tang. All rights reserved.
//

import UIKit
import IGListKit
import RealmSwift

class SectionController: ListSectionController {
    private weak var collectionView: UICollectionView!
    private let grid: Grid
    
    private var realmSection: RealmSection?
    
    init(grid: Grid, _ collectionView: UICollectionView) {
        self.grid = grid
        self.collectionView = collectionView
    }
    override func didUpdate(to object: Any) {
        precondition(object is RealmSection)
        guard let object = object as? RealmSection else {return}
        realmSection = object
    }
    override func canMoveItem(at index: Int) -> Bool {
        return true
    }
    override func numberOfItems() -> Int {
        return 0
    }
    override func sizeForItem(at index: Int) -> CGSize {
        return grid.size(for: collectionView, ratio: 1)
    }
}


