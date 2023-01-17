//
//  SearchViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import UIKit
import Lottie
import Toast

final class SearchViewController: UIViewController {

    /**
     Allow user to filter search based on category and sources
     */
    private var headlineLabel: ControllerHeaderView = ControllerHeaderView(frame: .zero)
    private var debouncer: Debouncer?
    var newsViewCollection: NewsViewController!
    private var searchBar:SearchBarView! = {
        var view = SearchBarView()
        view.searchButton.isEnabled = false
        view.searchButton.alpha = 0.5

        return view
    }()
    private var sourceLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .gray
        label.layer.cornerRadius = 20
        label.font = UIFont(name: "Avenir", size: 20)
        return label
    }()
    private var newsWebViewController: NewsWebViewController! = NewsWebViewController()
    private var categoriesTableView: UITableView = {
        var tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private var sourcesTableViewController: SourcesViewController!
    private var selectedSourceId: String? {
        didSet{
            DispatchQueue.main.async {
                if(self.searchBar.searchTextField.text != ""){
                    self.searchBar.searchButton.isEnabled = true
                    self.searchBar.searchButton.alpha = 1
                }
                
                self.sourceLabel.text = "    \(String(localized: "SOURCE_PLACEHOLDER")) \(self.selectedSourceId ?? "")"
            }
        }
    }

    
    private var selectedCategoryIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        debouncer = Debouncer(delay: 1, callback: handleSearch)
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 20
        newsViewCollection = NewsViewController(collectionViewLayout: flowLayout)
        newsViewCollection.setControllerType(controllerType: .searchResult)
        newsViewCollection.delegate = self
        newsViewCollection.collectionView.isHidden = true
        
        // adding subviews
        view.addSubview(searchBar)
        view.addSubview(categoriesTableView)
        view.addSubview(sourceLabel)
        view.addSubview(newsViewCollection.collectionView)
        view.addSubview(newsViewCollection.loadingAnimation)
        view.addSubview(newsViewCollection.notFoundAnimation)
        view.addSubview(headlineLabel)

        // setting tableview/collectionview delegates
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
        searchBar.searchTextField.delegate = self

        // button targets
        searchBar.searchButton.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)
        
        headlineLabel.setTitle(title: "Search")
        
        addConstraints()
    }

    @objc private func searchButtonPressed(){
        
        handleSearch()
        searchBar.searchTextField.resignFirstResponder()
    }
    
    private func handleSearch(){
        guard let searchText = searchBar.searchTextField.text else {return}
        newsViewCollection.setSearchText(searchText: searchText)
    }
}

private typealias TextFieldSearchVC = SearchViewController
extension TextFieldSearchVC: UITextFieldDelegate{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.searchTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        DispatchQueue.main.async { [self] in
            
            guard let debouncer = debouncer else {return}
            debouncer.call()
            
            if (textField.text == ""){
                searchBar.searchButton.isEnabled = false
                searchBar.searchButton.alpha = 0.5
                newsViewCollection.collectionView.isHidden = true
                categoriesTableView.isHidden = false
                newsViewCollection.notFoundAnimation.isHidden = true
                newsViewCollection.collectionView.setContentOffset(.zero, animated: false)
            }else{
                if let selectedSourceId = selectedSourceId {
                    searchBar.searchButton.isEnabled = true
                    searchBar.searchButton.alpha = 1
                    
                    categoriesTableView.isHidden = true
                    newsViewCollection.collectionView.isHidden = false
                }
                
            }
        }
    }
}

private typealias TableViewDelegates = SearchViewController
extension TableViewDelegates: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CategoryData.data.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: tableView.frame.width-10, height: 30)
        label.text = String(localized: "CATEGORY_TABLE_VIEW_TITLE")
        label.font = UIFont(name: "Avenir", size: 20)
        label.textColor = .black
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let ad = "CATEGORY_\(CategoryData.data[indexPath.row].uppercased())"
        cell.textLabel?.text = String(localized: String.LocalizationValue(ad))
        cell.backgroundColor = .white
        cell.textLabel?.textColor = .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCategoryIndexPath = selectedCategoryIndexPath{
            categoriesTableView.cellForRow(at: selectedCategoryIndexPath)?.backgroundColor = .white
            categoriesTableView.cellForRow(at: selectedCategoryIndexPath)?.textLabel?.textColor = .black
            
        }
        categoriesTableView.cellForRow(at: indexPath)?.backgroundColor = .black
        categoriesTableView.cellForRow(at: indexPath)?.textLabel?.textColor = .white
        categoriesTableView.cellForRow(at: indexPath)?.selectionStyle = .none
        selectedCategoryIndexPath = indexPath
        sourcesTableViewController = SourcesViewController()
        sourcesTableViewController.delegate = self
        sourcesTableViewController.category = CategoryData.data[indexPath.row]
        present(sourcesTableViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(localized: "CATEGORY_TABLE_VIEW_TITLE")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}

private typealias SourceDelegates = SearchViewController
extension SourceDelegates: SourcesDelgate {
    func didSelectSource(_ controller: UIViewController, sourceId: String) {
        selectedSourceId = sourceId
        newsViewCollection.setSourceId(sourceId: sourceId)
    }
}

private typealias SearchViewControllerConstraints = SearchViewController
extension SearchViewControllerConstraints {
    
    private func addConstraints(){
        
        NSLayoutConstraint.activate(searchBarConstraints())
        NSLayoutConstraint.activate(loadingAnimationConstraints())
        NSLayoutConstraint.activate(notFoundAnimationContraints())
        NSLayoutConstraint.activate(categoriesTableViewConstraints())
        NSLayoutConstraint.activate(newsViewCollectionConstraints())
        NSLayoutConstraint.activate(headerConstraints())
    }
    
    private func headerConstraints()->[NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(headlineLabel.heightAnchor.constraint(equalToConstant: 50))
        constraints.append(headlineLabel.bottomAnchor.constraint(equalTo: searchBar.topAnchor,constant: -25))
        constraints.append(headlineLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15))
        constraints.append(headlineLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor))
        constraints.append(headlineLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60))
        return constraints
    }
    
    private func searchBarConstraints()->[NSLayoutConstraint]{
        var constraints: [NSLayoutConstraint] = []
        constraints.append(searchBar.bottomAnchor.constraint(equalTo: sourceLabel.topAnchor,constant: -5))
        constraints.append(searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor))
        constraints.append(searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor))
        constraints.append(searchBar.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor))
        return constraints
    }
    
    private func loadingAnimationConstraints()->[NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(newsViewCollection.loadingAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(newsViewCollection.loadingAnimation.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        constraints.append(newsViewCollection.loadingAnimation.widthAnchor.constraint(equalToConstant: 60))
        return constraints
    }
    
    private func categoriesTableViewConstraints()->[NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(categoriesTableView.topAnchor.constraint(equalTo: sourceLabel.bottomAnchor))
        constraints.append(categoriesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        constraints.append(categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20))
        constraints.append(categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20))
        return constraints
    }
    
    private func newsViewCollectionConstraints()->[NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append( newsViewCollection.collectionView.topAnchor.constraint(equalTo:sourceLabel.bottomAnchor,constant: 15))
        constraints.append(newsViewCollection.collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor))
        
        constraints.append(newsViewCollection.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor))
        constraints.append(newsViewCollection.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor))
        return constraints
    }
    
    private func notFoundAnimationContraints()->[NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(newsViewCollection.notFoundAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(newsViewCollection.notFoundAnimation.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        constraints.append(newsViewCollection.notFoundAnimation.heightAnchor.constraint(equalToConstant: 60))
        constraints.append(newsViewCollection.notFoundAnimation.widthAnchor.constraint(equalToConstant: 60))
        return constraints
    }
    
    private func sourceLabelConstraints()->[NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(sourceLabel.topAnchor.constraint(equalTo:searchBar.bottomAnchor))
        constraints.append(sourceLabel.bottomAnchor.constraint(equalTo: self.categoriesTableView.topAnchor))
        constraints.append(sourceLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20))
        constraints.append(sourceLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor))
        return constraints
    }
}

extension SearchViewController: NewsViewControllerDelegate {
    func pushWebView(_ viewController: UIViewController) {
        if let navigationController = navigationController {
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}
