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
import IGListKit

class ViewController: UICollectionViewController {
    static let inMemoryIdentifier = "My In-Memory Realm"

    private(set) var adapter: ListAdapter?
    
    private var grid = Grid(columns: 6, margin: UIEdgeInsets(all: 24), padding: UIEdgeInsets(all: 12))
    
    private(set) lazy var realm : Realm = {
        let config = Realm.Configuration(inMemoryIdentifier: ViewController.inMemoryIdentifier)
        let realm = try! Realm(configuration: config)
        return realm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupIGListKit()
    }
    
    private func setupIGListKit() {
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
        adapter?.collectionView = collectionView
        adapter?.dataSource = self
        
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
}

extension ViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [RealmSection(id: 0), RealmSection(id: 1)]
    }
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return SectionController(grid: grid, collectionView)
    }
}

final class RealmSection {
    let sectionId : Int
    init(id sectionId:Int) {
        self.sectionId = sectionId
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
