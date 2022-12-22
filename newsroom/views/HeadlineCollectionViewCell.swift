//
//  HeadlineCollectionViewCell.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import UIKit
import SDWebImage

class HeadlineCollectionViewCell: UICollectionViewCell {
    
    var cellImageURL: String?
    var headlineLabelText: String?
    override func prepareForReuse() {
        headlineText.text = ""
        cellBackgroundImage = UIImageView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = .red
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 1
        self.addSubview(cellBackgroundImage)
        self.addSubview(headlineText)
        addCellConstraint()

        cellBackgroundImage.frame = self.bounds
        cellBackgroundImage.translatesAutoresizingMaskIntoConstraints = true
        cellBackgroundImage.layer.cornerRadius = 20
        cellBackgroundImage.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        headlineText.text = headlineLabelText
//        headlineText.backgroundColor = UIColor(white: 1, alpha: 0.4)
    }
    
    func addCellConstraint() {
        var constraints: [NSLayoutConstraint] = []
        
        constraints.append(headlineText.bottomAnchor.constraint(equalTo: self.bottomAnchor))
        constraints.append(headlineText.leadingAnchor.constraint(equalTo: self.leadingAnchor))
        constraints.append(headlineText.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(headlineText.heightAnchor.constraint(equalToConstant: 20))
//        constraints.append(headlineText.topAnchor.constraint(equalTo: self.topAnchor))
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var headlineText: UILabel = {
        var label = UILabel()
        label.textColor = .black
//        label.frame.size = CGSize(width: 300, height: 30)
        label.layer.borderWidth = 1
    
        return label
    }()
    
    var cellBackgroundImage: UIImageView = {
        let imageview = UIImageView()
        return imageview
    }()
    
}
