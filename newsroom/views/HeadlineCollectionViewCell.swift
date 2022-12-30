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
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Times New Roman", size: 22)
        label.textColor = .white
        label.text = ""
        label.numberOfLines = 4
        return label
    }()
    
    var fullNewsIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "next-icon"))
        imageView.frame = CGRect(x: 0, y: 0, width: 5, height: 5)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var fullNewsButton: UIButton = {
        var button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 5, height: 5)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var cellBackgroundImage: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.sizeToFit()
        imageview.layer.cornerRadius = 25
        imageview.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return imageview
    }()
    
    var sourceLabel: UILabel = {
       var label = UILabel()
        label.numberOfLines = 1
        label.textColor = .systemGray
        label.font = UIFont(name: "Avenir", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        

        self.backgroundColor = .black
        self.layer.cornerRadius = 40
        self.addSubview(cellBackgroundImage)
        self.addSubview(headlineText)
        self.addSubview(sourceLabel)
        constraintsCell()
        self.translatesAutoresizingMaskIntoConstraints = true
        cellBackgroundImage.clipsToBounds = true
    }
    
    
    func constraintsCell(){
        let constraints: [NSLayoutConstraint] = [
            headlineText.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            headlineText.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 20),
            headlineText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            headlineText.topAnchor.constraint(equalTo: sourceLabel.bottomAnchor, constant: 10),
            sourceLabel.topAnchor.constraint(equalTo: cellBackgroundImage.bottomAnchor,constant: 5),
            sourceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            sourceLabel.bottomAnchor.constraint(equalTo: headlineText.topAnchor),
            cellBackgroundImage.topAnchor.constraint(equalTo: self.topAnchor),
            cellBackgroundImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cellBackgroundImage.trailingAnchor.constraint(equalTo: trailingAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
