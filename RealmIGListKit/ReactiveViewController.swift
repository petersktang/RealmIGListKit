//
//  ReactiveViewController.swift
//  RealmIGListKit
//
//  Created by Peter Tang on 25/8/2019.
//  Copyright © 2019 Peter Tang. All rights reserved.
//

import UIKit
import IGListKit
import RxSwift
import RealmSwift

final class ReactiveViewController: UICollectionViewController, ListAdapterDataSource {
    
    private var grid = Grid(columns: 9, margin: UIEdgeInsets(all: 24), padding: UIEdgeInsets(all: 12))
    private let bag = DisposeBag()
    
    private lazy var adapter: ListAdapter = {
        ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    private lazy var announcerNew = RxRealmAnnouncer(adapter: adapter)

    private lazy var data = DataRandomizer()
    private lazy var realm = try! Realm(configuration: data.config)
    private lazy var rxlaps: RxRealmAccouncerHandler<Lap,String>.RealmObservable<Lap> = {
        Observable.changeset(from: realm.objects(Timer.self).first!.laps).share()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupIGListKit()
        data.start()
    }
    
    private func setupIGListKit() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        layout.sectionInsetReference = .fromContentInset
        collectionView.collectionViewLayout = layout
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        // disable prefetching so cells are configured as they come on screen
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        }
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    private func setupBehaviour() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, // .action
                                                            target: self,
                                                            action: #selector(ReactiveViewController.onChange))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    @objc func onChange() {
        //announcer.change()
        print("Change Button Pressed")
    }
    
    // MARK: ListAdapterDataSource
    
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
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        //return ListeningRealmSectionController(grid: grid, collectionView, announcer: announcer)
        return RxRealmSectionController(grid: grid, announcer: announcerNew)
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
}
