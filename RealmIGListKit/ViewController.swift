//
//  ViewController.swift
//  RealmIGListKit
//
//  Created by Peter Tang on 22/8/2019.
//  Copyright © 2019 Peter Tang. All rights reserved.
//

import UIKit
import SwifterSwift
import IGListKit
import RealmSwift
import RxSwift


class ViewController: UICollectionViewController {
    static let inMemoryIdentifier = "My In-Memory Realm"

    private(set) var adapter: ListAdapter?
    
    private var grid = Grid(columns: 9, margin: UIEdgeInsets(all: 24), padding: UIEdgeInsets(all: 12))
    private var store = ReactiveHandlerStore()
    private let bag = DisposeBag()
    
    private lazy var data = DataRandomizer()
    private lazy var realm = try! Realm(configuration: data.config)
    private lazy var rxlaps: RealmChangesetObservable<Lap> = {
        Observable.changeset(from: realm.objects(Timer.self).first!.laps).share()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupIGListKit()
        data.start()
    }
    
    private func setupIGListKit() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        layout.sectionInsetReference = .fromContentInset
        collectionView.collectionViewLayout = layout
        
        adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
        adapter?.collectionView = collectionView
        adapter?.dataSource = self
        
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }

}

extension ViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [RealmSection(id: 0, laps: rxlaps, group: "A"),
                RealmSection(id: 1, laps: rxlaps, group: "A"),
                RealmSection(id: 2, laps: rxlaps, group: "A"),
                RealmSection(id: 3, laps: rxlaps, group: "A"),
                RealmSection(id: 4, laps: rxlaps, group: "A"),
                RealmSection(id: 5, laps: rxlaps, group: "A"),
                RealmSection(id: 6, laps: rxlaps, group: "A"),
                RealmSection(id: 7, laps: rxlaps, group: "A"),
                RealmSection(id: 8, laps: rxlaps, group: "A"),
                RealmSection(id: 9, laps: rxlaps, group: "A")]
    }
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return SectionController(grid: grid, collectionView, store: store, bag: bag)
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
