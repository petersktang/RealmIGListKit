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
import RxSwift
import RxCocoa

public class SectionController: ListSectionController {
    private weak var collectionView: UICollectionView!
    private let grid: Grid
    private let bag = DisposeBag()
    
    private var realmSection: RealmSection?
    private var count = 0
    
    init(grid: Grid, _ collectionView: UICollectionView) {
        self.grid = grid
        self.collectionView = collectionView
    }
}
extension SectionController {
    public override func didUpdate(to object: Any) {
        precondition(object is RealmSection)
        guard let object = object as? RealmSection else {return}
        realmSection = object
        realmSection?.lapsObservable.subscribe(onNext:  { event in
            let (_, realmchangeset) = event
            let deletes:IndexSet = IndexSet(Array(realmchangeset?.deleted ?? []))
            let inserts:IndexSet = IndexSet(Array(realmchangeset?.inserted ?? []))
            let updates:IndexSet = IndexSet(Array(realmchangeset?.updated ?? []))
            self.collectionContext?.performBatch(animated: true, updates: { batchContext in
                print("lapsObservable pumping data .. \(Int.random(in: 0...10))")
                self.count = self.count - deletes.count + inserts.count
                batchContext.delete(in: self, at: deletes)
                batchContext.insert(in: self, at: inserts)
                batchContext.reload(in: self, at: updates)
            })
        }).disposed(by: bag)
    }
    
    override public func canMoveItem(at index: Int) -> Bool {
        return true
    }
    override public func numberOfItems() -> Int {
        return count
    }
    override public func sizeForItem(at index: Int) -> CGSize {
        return grid.size(for: collectionView, ratio: 1)
    }
    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: LapCollectionCell.self, for: self, at: index) as? LapCollectionCell else { fatalError("dequeue LapCollectionCell failure") }
        cell.customLabel.text = "> \(index)"
        print("cellForItem() \(section):\(index)")
        return cell
    }
    
}
