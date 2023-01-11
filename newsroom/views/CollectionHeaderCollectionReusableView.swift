//
//  CollectionHeaderCollectionReusableView.swift
//  newsroom
//
//  Created by Sarthak Jha on 26/12/22.
//

import UIKit

final class CollectionHeaderCollectionReusableView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var headerlabel: UILabel = {
        let label = UILabel()
        return label
    }()
}
