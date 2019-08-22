//
//  LapCollectionCell.swift
//  RxRealmDataSources
//
//  Created by Marin Todorov on 12/11/16.
//  Copyright © 2016 RxSwiftCommunity. All rights reserved.
//

import UIKit
import SwifterSwift

class LapCollectionCell: UICollectionViewCell {
    //@IBOutlet weak var customLabel: UILabel!
    public var customLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(customLabel)
        customLabel.anchorCenterSuperview()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.addSubview(customLabel)
        customLabel.anchorCenterSuperview()
    }
}
