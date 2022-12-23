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

    var headlineText: UILabel = {
        var label = UILabel()
        label.textColor = .black
        label.frame.size = CGSize(width: 200, height: 40)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Times New Roman", size: 20)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 2
        label.backgroundColor = UIColor(white: 1, alpha: 0.7)

        return label
    }()
    
    var cellBackgroundImage: UIImageView = {
        let imageview = UIImageView()
        return imageview
    }()
    
    var sourceLabel: UILabel = {
       var label = UILabel()
        label.numberOfLines = 1
        label.textColor = .black
        label.frame.size = CGSize(width: 50, height: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor(white: 1, alpha: 0.5)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 1
        self.addSubview(cellBackgroundImage)
        self.addSubview(headlineText)
        self.addSubview(sourceLabel)
        constraintsCell()
        self.translatesAutoresizingMaskIntoConstraints = true
        cellBackgroundImage.frame = self.bounds
        cellBackgroundImage.translatesAutoresizingMaskIntoConstraints = true
        cellBackgroundImage.layer.cornerRadius = 20
        cellBackgroundImage.clipsToBounds = true
    }
    
    func constraintsCell(){
        let constraints: [NSLayoutConstraint] = [
            headlineText.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            headlineText.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 20),
            headlineText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            sourceLabel.topAnchor.constraint(equalTo: topAnchor,constant: 10),
            sourceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
