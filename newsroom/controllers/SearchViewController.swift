//
//  SearchViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import UIKit

class SearchViewController: UIViewController {

    /**
     Allow user to filter search based on category and sources
     */
    
    var searchBar:SearchBarView!
    
    var searchResults: ArticleResponse? {
        didSet{
            DispatchQueue.main.async { [self] in
                searchResultCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        searchTextField.delegate = self
        searchResultCollectionView.delegate = self
        searchResultCollectionView.dataSource = self
        searchResultCollectionView.register(HeadlineCollectionViewCell.self, forCellWithReuseIdentifier: "search-cell")
        view.backgroundColor = .white
        searchBar = SearchBarView()
//        searchBar.frame.size = CGSize(width: 500, height: 20)
        guard let searchBar = searchBar else {return}
        view.addSubview(searchResultCollectionView)
        view.addSubview(searchBar)

        addConstraints()
    }
    
    private func addConstraints(){
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor))
        constraints.append( searchResultCollectionView.topAnchor.constraint(equalTo:searchBar.bottomAnchor))
        constraints.append(searchResultCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor))
        constraints.append(searchBar.bottomAnchor.constraint(equalTo: searchResultCollectionView.topAnchor))
        constraints.append(searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor))
        constraints.append(searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor))
        constraints.append(searchResultCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor))
        constraints.append(searchResultCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private lazy var searchTextField: UITextField = {
       let textField = UITextField()
        textField.placeholder = "search text"
        textField.backgroundColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var searchResultCollectionView: UICollectionView = {
        var collectionViewFlow = UICollectionViewFlowLayout()
        collectionViewFlow.scrollDirection = .vertical
        var collectionView = UICollectionView(frame: .zero,collectionViewLayout: collectionViewFlow)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
}

extension SearchViewController: UICollectionViewDelegate{
}

extension SearchViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = searchResultCollectionView.dequeueReusableCell(withReuseIdentifier: "search-cell", for: indexPath) as! HeadlineCollectionViewCell
        return cell
    }
}


extension SearchViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("editing started")
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("ended editing")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        return true
    }
}
