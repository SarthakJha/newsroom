//
//  ControllerHeaderView.swift
//  newsroom
//
//  Created by Sarthak Jha on 17/01/23.
//

import UIKit

class ControllerHeaderView: UIView {
    
    private var TitleText: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var label: UILabel = {
        
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setConstraints() {
        
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    public func setTitle(title: String) {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.backgroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 40)] as [NSAttributedString.Key : Any]
        
        self.label.attributedText = NSAttributedString(string: title, attributes: attributes)
    }
}

