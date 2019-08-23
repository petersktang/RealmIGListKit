//
//  ViewController.swift
//  RealmIGListKit
//
//  Created by Peter Tang on 22/8/2019.
//  Copyright © 2019 Peter Tang. All rights reserved.
//

import UIKit
import SwifterSwift
import RealmSwift
import RxRealm
import RxSwift
import IGListKit


class ViewController: UICollectionViewController {
    static let inMemoryIdentifier = "My In-Memory Realm"

    private(set) var adapter: ListAdapter?
    
    private var grid = Grid(columns: 9, margin: UIEdgeInsets(all: 24), padding: UIEdgeInsets(all: 12))
    
    private lazy var data = DataRandomizer()
    private lazy var realm = try! Realm(configuration: data.config)
    private lazy var rxlaps: RealmChangesetObservable<Lap> = {
        Observable.changeset(from: realm.objects(Timer.self).first!.laps).share()
    }()
    
    private(set) var sectionControlers : [SectionController] = []
    
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
    public func locate(section: Int) -> SectionController? {
        return sectionControlers.filter{ $0.section == section}.first
    }

}

extension ViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [RealmSection(id: 0, laps: rxlaps, shareWith: 0) ]
            //, RealmSection(id: 1, laps: rxlaps, shareWith: 0),
            //, RealmSection(id: 2, laps: rxlaps, shareWith: 0)]
    }
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let s = SectionController(grid: grid, collectionView)
        sectionControlers.append(s)
        return s
    }
}

final class RealmSection {
    let sectionId : Int
    let lapsObservable : RealmChangesetObservable<Lap>
    let shareSection: Int
    init(id sectionId:Int, laps lapsObservable: RealmChangesetObservable<Lap>, shareWith shareSection: Int) {
        self.sectionId = sectionId
        self.lapsObservable = lapsObservable
        self.shareSection = shareSection
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
