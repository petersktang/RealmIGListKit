//
//  RxRealmSectionController.swift
//  RealmIGListKit
//
//  Created by Peter Tang on 29/8/2019.
//  Copyright © 2019 Peter Tang. All rights reserved.
//

import UIKit
import IGListKit
import RealmSwift

class RxRealmSectionController: ListSectionController, RxListSectionController {
    private let grid: Grid
    private let announcer: RxRealmAnnouncer
    private(set) var handler: RxRealmHandler?
    
    private var realmSection: RealmSection?

    init(grid:Grid, announcer:RxRealmAnnouncer){
        self.grid = grid
        self.announcer = announcer
        super.init()
        
        //supplementaryViewSource = self
        
        self.minimumLineSpacing = grid.verticalPadding
        self.minimumInteritemSpacing = grid.horizontalPadding
        self.inset = grid.margin
    }
    func configureCell(cell: LapCollectionCell, data: String) {
        cell.customLabel.text = ":\(data)"
    }
    
    // MARK: ListSectionController Overrides
    override func didUpdate(to object: Any) {
        precondition(object is RealmSection)
        guard let object = object as? RealmSection else {return}
        realmSection = object
        if let handler = announcer.search(realm: Lap.self, snapshot: String.self) {
            handler.add(listener: self)
            print("handler \(section) registered")
            self.handler = handler
        } else {
            let handler = RxRealmAccouncerHandler<Lap,String>(deepCopy: { $0.text })
            announcer.add(handler: handler)
            handler.add(listener: self)
            handler.handle(announcer: announcer, query: object.lapsObservable).disposed(by: announcer.bag)
            print("handler \(section) created \(handler.realmObject) \(handler.snapshotObject)")
            self.handler = handler
        }
    }
    
    override func numberOfItems() -> Int {
        return handler?.count() ?? 0
    }
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionView = announcer.collectionView else { fatalError("RxRealmSectionController unable to locate collectionView!") }
        return grid.size(for: collectionView, ratio: 1)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: LapCollectionCell.self, for: self, at: index) as? LapCollectionCell else {
            fatalError()
        }
        configureCell(cell: cell, data: "\(index)")
        return cell
    }
    
}
