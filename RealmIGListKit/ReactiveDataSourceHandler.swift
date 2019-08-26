//
//  ReactiveDataSourceHandler.swift
//  RealmIGListKit
//
//  Created by Peter Tang on 24/8/2019.
//  Copyright © 2019 Peter Tang. All rights reserved.
//

import UIKit
import IGListKit
import RealmSwift
import RxSwift
import RxRealm

typealias RealmChangesetObservable<O> =  Observable<(AnyRealmCollection<O>, RealmChangeset?)> where O: RealmSwift.Object

final public class ReactiveDataSourceHandler<O> where O: RealmSwift.Object {
    private let collectionView: UICollectionView
    private let announcer: RealmChangeAnnouncer<O>
    private var realmObjects: AnyRealmCollection<O>?
    private let obs : RealmChangesetObservable<O>

    init(collectionView: UICollectionView, section: Int, obs: RealmChangesetObservable<O>, announcer: RealmChangeAnnouncer<O>) {
        self.collectionView = collectionView
        self.obs = obs
        self.announcer = announcer
    }
    
    func count() -> Int {
        return self.realmObjects?.count ?? 0
    }
    
    func handle() -> Disposable {
        return handle2()
    }
    
    func handle1() -> Disposable {
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
            
            let sections = self.announcer.sections()
            
            let deletes = d.map{ r in sections.map{s in IndexPath(row: r, section: s)} }.flatMap{ $0 }
            let inserts = i.map{ r in sections.map{s in IndexPath(row: r, section: s)} }.flatMap{ $0 }
            let updates = u.map{ r in sections.map{s in IndexPath(row: r, section: s)} }.flatMap{ $0 }
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
    func handle2() -> Disposable {
        return obs.subscribe(onNext: { event in
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
            
            let sections = self.announcer.sections()

            self.collectionView.performBatchUpdates({
                sections.forEach { section in
                    let deletes = d.map{ r in IndexPath(row: r, section: section) }
                    let inserts = i.map{ r in IndexPath(row: r, section: section) }
                    let updates = u.map{ r in IndexPath(row: r, section: section) }
                    if deletes.count > 0 {
                        self.collectionView.deleteItems(at: deletes)
                    }
                    if inserts.count > 0 {
                        self.collectionView.insertItems(at: inserts)
                    }
                    if updates.count > 0 {
                        self.collectionView.reloadItems(at: updates)
                    }
                }
            })
        })
    }
    
}

final public class ReactiveHandlerStore {
    private var store:[String: ListSectionController] = [:]
    
    public func join(group: String, controller: ListSectionController) -> ListSectionController? {
        let locatedController = store[group]
        if locatedController == nil {
            store[group] = controller
        }
        return locatedController
    }
}
