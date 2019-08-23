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
import RxRealm
import RxSwift
import RxCocoa

public class SectionController: ListSectionController {
    private weak var collectionView: UICollectionView!
    private let grid: Grid
    private let bag = DisposeBag()
    
    private var realmSection: RealmSection?
    fileprivate var handler: ReactiveDataSourceHandler<Lap>?
    
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

        if realmSection?.shareSection == realmSection?.sectionId {
            handler = ReactiveDataSourceHandler(collectionView: collectionView, section: section, obs: object.lapsObservable)
            handler?.handle().disposed(by: bag)
        } else if let viewController = (viewController as? ViewController),
            let controller = viewController.locate(section: realmSection?.shareSection ?? section),
            let handler = controller.handler {
            handler.joinHandler(section: section)
            self.handler = handler
            print(#function, "handler set \(section) -----> \(controller.section)")
        }
    }
    
    override public func canMoveItem(at index: Int) -> Bool {
        return true
    }
    override public func numberOfItems() -> Int {
        return handler?.count() ?? 0
    }
    override public func sizeForItem(at index: Int) -> CGSize {
        //print(#function, collectionView.collectionViewLayout, section, index)
        return grid.size(for: collectionView, ratio: 1)
    }
    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: LapCollectionCell.self, for: self, at: index) as? LapCollectionCell else { fatalError("dequeue LapCollectionCell failure") }
        cell.customLabel.text = "> \(index)"
        return cell
    }
    
}

typealias RealmChangesetObservable<O> =  Observable<(AnyRealmCollection<O>, RealmChangeset?)> where O: RealmSwift.Object

fileprivate class ReactiveDataSourceHandler<O> where O: RealmSwift.Object {
    private var sections : Set<Int> = []
    private let collectionView: UICollectionView
    var realmObjects: AnyRealmCollection<O>?
    let obs : RealmChangesetObservable<O>
    init(collectionView: UICollectionView, section: Int, obs: RealmChangesetObservable<O>) {
        self.collectionView = collectionView
        self.sections.insert(section)
        self.obs = obs
    }
    
    func joinHandler(section: Int) {
        self.sections.insert(section)
        print(#function, section, "joining", self.sections)
    }
    
    func count() -> Int {
        return self.realmObjects?.count ?? 0
    }
    
    func handle() -> Disposable {
        return obs.subscribeOn(MainScheduler.instance).subscribe(onNext: { event in
            let (robjs, realmchangeset) = event

            if self.realmObjects == nil {
                self.realmObjects = robjs
            }
            if realmchangeset == nil {
                self.collectionView.reloadData()
                return
            }

            let d = realmchangeset?.deleted ?? []
            let i = realmchangeset?.inserted ?? []
            let u = realmchangeset?.updated ?? []
            
            let deletes = d.map{ r in self.sections.map{s in IndexPath(row: r, section: s)} }.flatMap{ $0 }
            let inserts = i.map{ r in self.sections.map{s in IndexPath(row: r, section: s)} }.flatMap{ $0 }
            let updates = u.map{ r in self.sections.map{s in IndexPath(row: r, section: s)} }.flatMap{ $0 }
            self.collectionView.performBatchUpdates({
                if deletes.count > 0 {
                    self.collectionView.deleteItems(at: deletes)
                }
                if inserts.count > 0 {
                    self.collectionView.insertItems(at: inserts)
                }
                if updates.count > 0 {
                    self.collectionView.reloadItems(at: updates)
                }
            })
        })
    }
}
