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
        self.backgroundColor = .white
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 1
        self.addSubview(headlineText)
        self.translatesAutoresizingMaskIntoConstraints = false
        headlineText.text = "sarthak Jha"
        headlineText.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        headlineText.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        headlineText.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var headlineText: UILabel = {
        var label = UILabel()
        label.textColor = .black
        label.frame.size = CGSize(width: 90, height: 30)
        label.layer.borderWidth = 1
        label.text = ""
    
        return label
    }()
    
//    var headlineImage: UIImage = {
//
//        var img = UIImage(data: Data())
//        return img!
//    }()
    
}
