//
//  ListeningRealmSectionController.swift
//  RealmIGListKit
//
//  Created by Peter Tang on 25/8/2019.
//  Copyright © 2019 Peter Tang. All rights reserved.
//

import IGListKit
import RealmSwift
import RxRealm
import RxSwift

final class ListeningRealmSectionController: ListSectionController, ReactiveRealmChangeListener {

    private let grid : Grid
    private weak var collectionView: UICollectionView!
    private let announcer: RealmChangeAnnouncer<Lap>
    private var realmSection: RealmSection?
    private(set) var handler: ReactiveDataSourceHandler<Lap>?

    init(grid: Grid, _ collectionView: UICollectionView, announcer: RealmChangeAnnouncer<Lap>) {
        self.grid = grid
        self.collectionView = collectionView
        self.announcer = announcer
        super.init()
        announcer.add(listener: self)
        inset = UIEdgeInsets(top: 0, left: 40, bottom:0, right: 40)
    }
    
    func configureCell(cell: LapCollectionCell, data: Int) {
        cell.customLabel.text = ":\(data)"
    }
    
    // MARK: ListSectionController Overrides
    override func didUpdate(to object: Any) {
        precondition(object is RealmSection)
        guard let object = object as? RealmSection else {return}
        realmSection = object
        if let handler = announcer.handler(ListeningRealmSectionController.self) {
            self.handler = handler
        } else {
            self.handler = ReactiveDataSourceHandler(collectionView: collectionView, section: section, obs: object.lapsObservable, announcer: announcer)
            self.handler?.handle().disposed(by: announcer.bag)
        }
   }

    override func numberOfItems() -> Int {
        return handler?.count() ?? 0
    }
    override func sizeForItem(at index: Int) -> CGSize {
        return grid.size(for: collectionView, ratio: 1)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: LapCollectionCell.self, for: self, at: index) as? LapCollectionCell else {
            fatalError()
        }
        configureCell(cell: cell, data: index)
        return cell
    }
    
    // MARK: ReactiveRealmChangeListener
    func didChange<Announcer>(announcer: Announcer) where Announcer : RealmChangeAnnouncer<Lap> {
        guard let cell = collectionContext?.cellForItem(at: 0, sectionController: self) as? LapCollectionCell else { return }
        configureCell(cell: cell, data: 0)
    }
    
}

final class RealmSection {
    let sectionId : Int
    let lapsObservable : RealmChangesetObservable<Lap>
    let group: String
    init(id sectionId:Int, laps lapsObservable: RealmChangesetObservable<Lap>, group: String) {
        self.sectionId = sectionId
        self.lapsObservable = lapsObservable
        self.group = group
    }
}

extension RealmSection: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return sectionId as NSObjectProtocol
    }
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? RealmSection else {
            return false
        }
        return self.sectionId == object.sectionId
    }
}
