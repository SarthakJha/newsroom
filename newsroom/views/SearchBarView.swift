//
//  SearchBarView.swift
//  newsroom
//
//  Created by Sarthak Jha on 20/12/22.
//

import UIKit

class SearchBarView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        searchTextField.delegate = self
        addSubview(searchTextField)
        addSubview(searchButton)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        self.widthAnchor.constraint(equalToConstant: 100).isActive = true
        searchTextField.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 10).isActive = true
        searchTextField.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        searchTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        searchButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        searchButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        searchButton.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
//        searchButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        searchButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor).isActive = true
        searchTextField.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -10).isActive = true
//        searchButton.addTarget(self, action: #selector(<#T##@objc method#>), for: .touchUpInside)
        self.backgroundColor = .gray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var searchTextField: UITextField = {
       let textField = UITextField()
        textField.placeholder = "search text"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var searchButton: UIButton = {
        var button = UIButton(type: .system)
        button.titleLabel?.text = "search"
        button.backgroundColor = .blue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 15
        return button
    }()
    
}

extension SearchBarView: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        return true
    }
}
