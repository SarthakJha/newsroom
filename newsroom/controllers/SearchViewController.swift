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
    var newsWebViewController: NewsWebViewController!
    var categoriesTableView: UITableView!
    var selectedCategoryIndexPath: IndexPath? {
        didSet{
            searchBar.searchButton.isEnabled = true
        }
    }
    var searchResults: ArticleResponse? {
        didSet{
            DispatchQueue.main.async { [self] in
                searchResultCollectionView.reloadData()
                searchResultCollectionView.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsWebViewController = NewsWebViewController()
        searchBar = SearchBarView()
        categoriesTableView = UITableView()
        categoriesTableView.translatesAutoresizingMaskIntoConstraints = false
        guard let searchBar = searchBar else {return}
        view.addSubview(searchResultCollectionView)
        view.addSubview(searchBar)
        view.addSubview(categoriesTableView)
        searchBar.searchButton.isEnabled = false

        print("view did load")
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
        categoriesTableView.isScrollEnabled = false
        
        searchBar.searchTextField.delegate = self
        searchResultCollectionView.delegate = self
        searchResultCollectionView.dataSource = self
        searchResultCollectionView.register(HeadlineCollectionViewCell.self, forCellWithReuseIdentifier: "search-cell")
        view.backgroundColor = .white
        searchBar.searchButton.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)
      
        addConstraints()
    }
    
    private func addConstraints(){
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20))
        constraints.append( searchResultCollectionView.topAnchor.constraint(equalTo:searchBar.bottomAnchor))
        constraints.append(searchResultCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor))
        constraints.append(searchBar.bottomAnchor.constraint(equalTo: searchResultCollectionView.topAnchor,constant: -20))
        constraints.append(searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor))
        constraints.append(searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor))
        constraints.append(searchResultCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor))
        constraints.append(searchResultCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor))
        constraints.append(categoriesTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor,constant: 70))
        constraints.append(categoriesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        constraints.append(categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20))
        constraints.append(categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private lazy var searchResultCollectionView: UICollectionView = {
        var collectionViewFlow = UICollectionViewFlowLayout()
        collectionViewFlow.scrollDirection = .vertical
        var collectionView = UICollectionView(frame: .zero,collectionViewLayout: collectionViewFlow)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    @objc func searchButtonPressed(){
        guard let searchText = searchBar.searchTextField.text else {return}
        guard let selectedCategoryIndexPath = selectedCategoryIndexPath else {return}
        NewsroomAPIService.APIManager.fetchSearchResults(category: CategoryData.data[selectedCategoryIndexPath.row],searchText: searchText) { data, error in
            if let error = error {
                print(error)
                return
            }
            guard let data = data else {return}
            self.searchResults = data
        }
        categoriesTableView.isHidden = true
        searchBar.searchTextField.resignFirstResponder()
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width-20, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = URL(string: (searchResults?.articles[indexPath.row].url!)!){
            newsWebViewController.url = url
            if let navigationController = navigationController{
                navigationController.pushViewController(self.newsWebViewController, animated: true)
            }
        }
    }
}

extension SearchViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults?.articles.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = searchResultCollectionView.dequeueReusableCell(withReuseIdentifier: "search-cell", for: indexPath) as! HeadlineCollectionViewCell
        cell.headlineText.text = searchResults?.articles[indexPath.row].title
        cell.cellBackgroundImage.sd_setImage(with: URL(string: searchResults?.articles[indexPath.row].urlToImage ?? ""))
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
        searchBar.searchTextField.resignFirstResponder()
        return true
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if (textField.text == ""){
            searchResultCollectionView.isHidden = true
            categoriesTableView.isHidden = false
        }
    }
}

extension SearchViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CategoryData.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = CategoryData.data[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCategoryIndexPath = selectedCategoryIndexPath{
            categoriesTableView.cellForRow(at: selectedCategoryIndexPath)?.backgroundColor = .white
        }
        selectedCategoryIndexPath = indexPath
        categoriesTableView.cellForRow(at: indexPath)?.backgroundColor = .red
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select category"
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
