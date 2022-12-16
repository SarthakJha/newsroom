//
//  HeadlineCollectionViewCell.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import UIKit

class HeadlineCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCellView(){
        self.backgroundColor = .red
        self.layer.cornerRadius = 20
        
    }
}
