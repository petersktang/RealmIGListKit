//
//  ChangeAnnouncer.swift
//  RealmIGListKit
//
//  Created by Peter Tang on 25/8/2019.
//  Copyright © 2019 Peter Tang. All rights reserved.
//

import UIKit
import IGListKit
import RealmSwift
import RxSwift

protocol ReactiveRealmChangeListener: class {
    var section: Int {get}
    var viewController: UIViewController? { get }
    var collectionContext: ListCollectionContext? { get }
    
    associatedtype O : Object
    var handler: ReactiveDataSourceHandler<O>? { get }
    func didChange<Announcer: RealmChangeAnnouncer<O>>(announcer: Announcer)
}

final class RealmChangeAnnouncer<O>: NSObject {
    private(set) weak var bag : DisposeBag!
    private let mapWeakObjects: NSPointerArray = NSPointerArray.weakObjects()
    init(bag: DisposeBag) {
        self.bag = bag
        super.init()
    }
    func add<Listener: ReactiveRealmChangeListener & ListSectionController>(listener: Listener) {
        let pointer = Unmanaged.passUnretained(listener).toOpaque()
        mapWeakObjects.addPointer(pointer)
    }
    func sections() -> [Int] {
        return mapWeakObjects.allObjects.map{ ($0 as? ListSectionController)?.section }.compactMap({ $0 })
    }
    //FIXME: this is a bug, even if it matches the same realm object type, it might be of another query, and thus should not affect this section.
    func handler<L: ReactiveRealmChangeListener, H: ReactiveDataSourceHandler<O>>(_ listener: L.Type) -> H? {
        return mapWeakObjects.allObjects.map{ ($0 as? L)?.handler }.filter{ $0 is H }.compactMap({ $0 }).first as? H
    }
}

