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
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        searchTextField.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 10).isActive = true
        searchTextField.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        searchTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        searchButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        searchButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        searchTextField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        searchButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
//        searchButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        searchButton.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        searchButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor).isActive = true
        searchButton.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -5).isActive = true
        searchTextField.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -10).isActive = true
        searchButton.setTitle("search", for: .normal)
        searchButton.setTitleColor(.white, for: .normal)
        searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 10))
        searchTextField.leftViewMode = .always
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
        textField.layer.shadowOpacity = 1
        textField.layer.shadowRadius = 5.0
        textField.layer.shadowOffset = CGSize.zero // Use any CGSize
        textField.layer.shadowColor = UIColor.gray.cgColor
        return textField
    }()
    
    lazy var searchButton: UIButton = {
        var button = UIButton(type: .system)
        button.layer.borderWidth = 1
        button.backgroundColor = .black
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
