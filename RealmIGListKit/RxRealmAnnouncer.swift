//
//  ReactiveController.swift
//  TakeNotesOverviewPage
//
//  Created by Peter Tang on 28/8/2019.
//  Copyright © 2019 Peter Tang. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift
import IGListKit

public class RxRealmAnnouncer {
    private(set) weak var bag: DisposeBag!
    private(set) var handlers = [RxRealmHandler]()
    private(set) weak var adapter: ListAdapter!
    
    var collectionView: UICollectionView? {
        return adapter.collectionView
    }
    init(adapter: ListAdapter, bag: DisposeBag) {
        self.adapter = adapter
        self.bag = bag
    }
    func add(handler: RxRealmHandler) {
        handlers.append(handler)
    }
    func search(realm: Object.Type, snapshot: Any.Type) -> RxRealmHandler? {
        return handlers.filter({ (handler) -> Bool in
            handler.realmObject == realm && handler.snapshotObject == snapshot
        }).first
    }
}

public protocol RxRealmHandler{
    var uuid: UUID { get }
    var realmObject: RealmSwift.Object.Type { get }
    var snapshotObject: Any.Type { get }
    
    func add<Listener: ListSectionController & RxListSectionController> (listener: Listener)
    func remove<Listener: ListSectionController & RxListSectionController> (listener: Listener)
    func count() -> Int
    func sections() -> [Int]
}

public class RxRealmAccouncerHandler<O:Object,E>: RxRealmHandler {

    public typealias RealmObservable<O> =  Observable<(AnyRealmCollection<O>, RealmChangeset?)> where O: RealmSwift.Object
    
    public var realmObject: Object.Type = O.self
    public var snapshotObject: Any.Type = E.self
    public let uuid = UUID()

    private var listeners = NSPointerArray.weakObjects()
    private(set) var realmResult: AnyRealmCollection<O>?
    private let deepCopy: (O) -> (E)
    
    private(set) var snapshot = [E]()
    init(deepCopy: @escaping (O) -> (E)){
        self.deepCopy = deepCopy
    }
    
    public func add<Listener: ListSectionController & RxListSectionController>(listener: Listener) {
        let pointer = Unmanaged.passUnretained(listener).toOpaque()
        listeners.addPointer(pointer)
    }
    public func remove<Listener>(listener: Listener) where Listener : ListSectionController, Listener : RxListSectionController {
        for i in 0 ..< listeners.count {
            if let pointer = listeners.pointer(at: i), pointer == Unmanaged.passUnretained(listener).toOpaque() {
                listeners.replacePointer(at: i, withPointer: nil)
            }
        }
        self.listeners.compact()
    }
    public func sections() -> [Int] {
        var sections = [Int]()
        for i in 0 ..< listeners.count {
            if let pointer = listeners.pointer(at: i) {
                let listener = Unmanaged<ListSectionController>.fromOpaque(pointer).takeUnretainedValue()
                sections.append(listener.section)
            }
        }
        return sections.unique
    }
    public func count() -> Int {
        return self.snapshot.count
    }
    private func refresh(robjs: AnyRealmCollection<O>, realmchangset: RealmChangeset?) {
        if self.realmResult == nil {
            self.realmResult = robjs
        }
        snapshot = robjs.toArray().map{ deepCopy($0) }
    }
    public func handle(announcer: RxRealmAnnouncer, realm: Results<O>) -> Disposable {
        return Observable.changeset(from: realm).subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] (robjs, rchangeset) in
            guard let collectionView = announcer.collectionView else { fatalError("collectionView not found in RxRealmAnnouncer") }
            self?.refresh(robjs: robjs, realmchangset: rchangeset)
            
            guard let rchangeset = rchangeset, let sections = self?.sections() else {
                debugPrint("collectionView.reloadData()")
                announcer.adapter.performUpdates(animated: false, completion: nil)
                //collectionView.reloadData()
                return
            }
            RxRealmAccouncerHandler._handle1(collectionView, sections: sections, robjs: robjs, rchangeset: rchangeset)
        })
    }
    public func handle(announcer: RxRealmAnnouncer, query: RealmObservable<O>) -> Disposable {
        return query.subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] (robjs, rchangeset) in
            guard let collectionView = announcer.collectionView else { fatalError("collectionView not found in RxRealmAnnouncer") }
            self?.refresh(robjs: robjs, realmchangset: rchangeset)
            
            guard let rchangeset = rchangeset, let sections = self?.sections() else {
                debugPrint("collectionView.reloadData()")
                announcer.adapter.performUpdates(animated: false, completion: nil)
                //collectionView.reloadData()
                return
            }
            RxRealmAccouncerHandler._handle1(collectionView, sections: sections, robjs: robjs, rchangeset: rchangeset)
        })
    }
    private static func _handle1(_ collectionView: UICollectionView, sections: [Int], robjs: AnyRealmCollection<O>, rchangeset: RealmChangeset) {
        let d = rchangeset.deleted
        let i = rchangeset.inserted
        let u = rchangeset.updated
        
        collectionView.performBatchUpdates({
            sections.forEach { section in
                let deletes = d.map{ r in IndexPath(row: r, section: section) }
                let inserts = i.map{ r in IndexPath(row: r, section: section) }
                let updates = u.map{ r in IndexPath(row: r, section: section) }
                if deletes.count > 0 {
                    collectionView.deleteItems(at: deletes)
                }
                if inserts.count > 0 {
                    collectionView.insertItems(at: inserts)
                }
                if updates.count > 0 {
                    collectionView.reloadItems(at: updates)
                }
            }
        })
    }
}

public protocol RxListSectionController: class {
    var section: Int { get }
    var viewController: UIViewController? { get }
    var collectionContext: ListCollectionContext? { get }
    var handler: RxRealmHandler? { get }
}

extension Array where Element : Hashable {
    var unique: [Element] {
        return Array(Set(self))
    }
}
