//
//  SectionController.swift
//  RealmIGListKit
//
//  Created by Peter Tang on 22/8/2019.
//  Copyright © 2019 Peter Tang. All rights reserved.
//

import UIKit
import IGListKit
import RxSwift

public class SectionController: ListSectionController {
    private weak var collectionView: UICollectionView!
    private let grid: Grid
    private let store:ReactiveHandlerStore
    private let bag : DisposeBag

    private var realmSection: RealmSection?
    private var handler: ReactiveDataSourceHandler<Lap>?
    
    init(grid: Grid, _ collectionView: UICollectionView, store: ReactiveHandlerStore, bag: DisposeBag) {
        self.grid = grid
        self.collectionView = collectionView
        self.store = store
        self.bag = bag
    }
}
extension SectionController {
    public override func didUpdate(to object: Any) {
        precondition(object is RealmSection)
        guard let object = object as? RealmSection else {return}
        realmSection = object
        
        if let groupController = store.join(group: object.group, controller: self) as? SectionController {
            self.handler = groupController.handler
            self.handler?.joinHandler(section: section)
        } else {
            handler = ReactiveDataSourceHandler(collectionView: collectionView, section: section, obs: object.lapsObservable)
            handler?.handle().disposed(by: bag)
        }
    }
    
    override public func canMoveItem(at index: Int) -> Bool {
        return true
    }
    override public func numberOfItems() -> Int {
        return handler?.count() ?? 0
    }
    override public func sizeForItem(at index: Int) -> CGSize {
        return grid.size(for: collectionView, ratio: 1)
    }
    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: LapCollectionCell.self, for: self, at: index) as? LapCollectionCell else { fatalError("dequeue LapCollectionCell failure") }
        cell.customLabel.text = "> \(index)"
        return cell
    }
    
}
