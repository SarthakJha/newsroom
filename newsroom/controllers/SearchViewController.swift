//
//  SearchViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import UIKit
import Lottie
import Toast

class SearchViewController: UIViewController {

    /**
     Allow user to filter search based on category and sources
     */
    
    private var searchBar:SearchBarView! = {
        var view = SearchBarView()
        view.searchButton.isEnabled = false
        view.searchButton.alpha = 0.5

        return view
    }()
    private var newsWebViewController: NewsWebViewController! = NewsWebViewController()
    private var categoriesTableView: UITableView! = {
        var tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private var sourcesTableViewController: SourcesViewController!
    private var currentPage: Int?
    private var didReachEnd: Bool = false
    private var selectedSourceId: String? {
        didSet{
            DispatchQueue.main.async {
                if(self.searchBar.searchTextField.text != ""){
                    self.searchBar.searchButton.isEnabled = true
                    self.searchBar.searchButton.alpha = 1
                }
            }
        }
    }
    
    private var notFoundAnimationView: LottieAnimationView! = {
        var animation = LottieAnimationView.init(name: "notfoundresults")
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.isHidden = true
        animation.animationSpeed = 1
        return animation
    }()
    
    private var loadingAnimationView: LottieAnimationView! = {
        var loadingAnimationView = LottieAnimationView.init(name: "loading")
        loadingAnimationView.translatesAutoresizingMaskIntoConstraints = false
        loadingAnimationView.contentMode = .scaleAspectFit
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.animationSpeed = 1
        return loadingAnimationView
    }()
    
    private lazy var searchResultCollectionView: UICollectionView = {
        var collectionViewFlow = UICollectionViewFlowLayout()
        collectionViewFlow.scrollDirection = .vertical
        var collectionView = UICollectionView(frame: .zero,collectionViewLayout: collectionViewFlow)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.register(HeadlineCollectionViewCell.self, forCellWithReuseIdentifier: "search-cell")
        return collectionView
    }()
    
    
    private var selectedCategoryIndexPath: IndexPath?
    private var searchResults: ArticleResponse? {
        didSet{
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.loadingAnimationView.stop()
                self.loadingAnimationView.isHidden = true
                if((self.searchResults?.totalResults)! > 0){
                    self.searchResultCollectionView.reloadData()
                    self.searchResultCollectionView.isHidden = false
                    self.notFoundAnimationView.isHidden = true
                }else{
                    let configuration = ToastConfiguration(
                        autoHide: true,
                        enablePanToClose: true,
                        displayTime: 3,
                        animationTime: 0.2
                    )
                    let toast = Toast.default(image: nil, title: String(localized: "TOAST_NOT_FOUND_TITLE"), subtitle: String(localized: "TOAST_NOT_FOUND_DESCRIPTION"),configuration: configuration)
                    toast.enableTapToClose()
                    self.searchResultCollectionView.isHidden = true
                    self.notFoundAnimationView.isHidden = false
                    self.notFoundAnimationView.play()
                    toast.show(haptic: .warning)
                }
            }
           
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // adding subviews
        view.addSubview(notFoundAnimationView)
        view.addSubview(loadingAnimationView)
        view.addSubview(searchResultCollectionView)
        view.addSubview(searchBar)
        view.addSubview(categoriesTableView)
        
        // setting tableview/collectionview delegates
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
        searchBar.searchTextField.delegate = self
        searchResultCollectionView.delegate = self
        searchResultCollectionView.dataSource = self
                
        // button targets
        searchBar.searchButton.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)
        
        addConstraints()
    }

    @objc private func searchButtonPressed(){
        currentPage = 1
        guard let searchText = searchBar.searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return}
        guard let selectedCategoryIndexPath = selectedCategoryIndexPath else {return}
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}

            self.searchResultCollectionView.isHidden = true
            self.loadingAnimationView.isHidden = false
            self.loadingAnimationView.play()
            self.notFoundAnimationView.isHidden = true
        }
        if(searchText == ""){
            DispatchQueue.main.async {
                let configuration = ToastConfiguration(
                    autoHide: true,
                    enablePanToClose: true,
                    displayTime: 3,
                    animationTime: 0.2
                )
                let toast = Toast.default(image: nil, title: String(localized: "TOAST_NOT_FOUND_TITLE"), subtitle: String(localized: "TOAST_NOT_FOUND_DESCRIPTION"),configuration: configuration)
                toast.enableTapToClose()
                toast.show(haptic: .warning)
            }
            return
        }
        NewsroomAPIService.APIManager.fetchSearchResults(searchText: searchText, sourceId: selectedSourceId,page: currentPage) { data, error in
            if let _ = error {
                return
            }
            guard let data = data else {return}
            self.searchResults = data
        }
        categoriesTableView.isHidden = true
        searchBar.searchTextField.resignFirstResponder()
    }
    
}

private typealias CollectionViewDelegates = SearchViewController
extension CollectionViewDelegates: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width-20, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = URL(string: (searchResults?.articles[indexPath.row].url!)!){
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}

                if let navigationController = self.navigationController{
                    self.newsWebViewController.url = url
                    navigationController.pushViewController(self.newsWebViewController, animated: true)
                }
            }
        }
    }
}
private typealias CollectionViewDataSources = SearchViewController
extension CollectionViewDataSources: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults?.articles.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if (indexPath.row == (searchResults?.articles.count)!-1 && !didReachEnd){
            currentPage = currentPage! + 1
            NewsroomAPIService.APIManager.fetchSearchResults(searchText: (searchBar.searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!, sourceId: selectedSourceId,  page: currentPage) { data, error in
                if((self.searchResults?.articles.count)! == (self.searchResults?.totalResults!)!){
                    self.didReachEnd = true
                }
                if let error = error {
                    return
                }
                guard let data = data else {return}
                self.searchResults?.articles.append(contentsOf: data.articles)
                DispatchQueue.main.async {
                    self.searchResultCollectionView.reloadData()
                }
            }
        }
        let cell = searchResultCollectionView.dequeueReusableCell(withReuseIdentifier: "search-cell", for: indexPath) as! HeadlineCollectionViewCell
        cell.setData(headlineText: searchResults?.articles[indexPath.row].title, sourceText: searchResults?.articles[indexPath.row].source.name, backgroundImgURL: searchResults?.articles[indexPath.row].urlToImage)
        return cell
    }
}

private typealias TextFieldSearchVC = SearchViewController
extension TextFieldSearchVC: UITextFieldDelegate{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.searchTextField.resignFirstResponder()
        return true
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if (textField.text == ""){
            searchBar.searchButton.isEnabled = false
            searchBar.searchButton.alpha = 0.5
            searchResultCollectionView.isHidden = true
            categoriesTableView.isHidden = false
            notFoundAnimationView.isHidden = true
            searchResultCollectionView.setContentOffset(.zero, animated: false)
            didReachEnd = false
            currentPage = 1
        }else{
            if let selectedSourceId = selectedSourceId{
                searchBar.searchButton.isEnabled = true
                searchBar.searchButton.alpha = 1
            }
        }
    }
}

private typealias TableViewDelegates = SearchViewController
extension TableViewDelegates: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CategoryData.data.count
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
    }
}

private typealias SearchViewControllerConstraints = SearchViewController
extension SearchViewControllerConstraints {
    
    private func addConstraints(){
        
        NSLayoutConstraint.activate(searchBarConstraints())
        NSLayoutConstraint.activate(loadingAnimationConstraints())
        NSLayoutConstraint.activate(notFoundAnimationContraints())
        NSLayoutConstraint.activate(categoriesTableViewConstraints())
        NSLayoutConstraint.activate(searchResultCollectionViewConstraints())
    }
    
    private func searchBarConstraints()->[NSLayoutConstraint]{
        var constraints: [NSLayoutConstraint] = []
        constraints.append(searchBar.bottomAnchor.constraint(equalTo: searchResultCollectionView.topAnchor,constant: -20))
        constraints.append(searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor))
        constraints.append(searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor))
        constraints.append(searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20))
        return constraints
    }
    
    private func loadingAnimationConstraints()->[NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(loadingAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(loadingAnimationView.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        constraints.append(loadingAnimationView.widthAnchor.constraint(equalToConstant: 60))
        return constraints
    }
    
    private func categoriesTableViewConstraints()->[NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(categoriesTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor,constant: 70))
        constraints.append(categoriesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        constraints.append(categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20))
        constraints.append(categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20))
        return constraints
    }
    
    private func searchResultCollectionViewConstraints()->[NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append( searchResultCollectionView.topAnchor.constraint(equalTo:searchBar.bottomAnchor))
        constraints.append(searchResultCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor))
        
        constraints.append(searchResultCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor))
        constraints.append(searchResultCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor))
        return constraints
    }
    
    private func notFoundAnimationContraints()->[NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(notFoundAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(notFoundAnimationView.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        constraints.append(notFoundAnimationView.heightAnchor.constraint(equalToConstant: 60))
        constraints.append(notFoundAnimationView.widthAnchor.constraint(equalToConstant: 60))
        return constraints
    }
}
