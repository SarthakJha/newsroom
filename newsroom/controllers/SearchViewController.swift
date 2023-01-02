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
    
    var searchBar:SearchBarView!
    var newsWebViewController: NewsWebViewController!
    var categoriesTableView: UITableView!
    var sourcesTableViewController: SourcesViewController!
    var activityIndicator: UIActivityIndicatorView!
    var selectedSourceId: String? {
        didSet{
            searchBar.searchButton.isEnabled = true
        }
    }
    
    private var notFoundAnimationView: LottieAnimationView!
    private var loadingAnimationView: LottieAnimationView!
    var selectedCategoryIndexPath: IndexPath? 
    var searchResults: ArticleResponse? {
        didSet{
            DispatchQueue.main.async { [self] in
                loadingAnimationView.stop()
                loadingAnimationView.isHidden = true
                if((searchResults?.totalResults)! > 0){
                    searchResultCollectionView.reloadData()
                    searchResultCollectionView.isHidden = false
                    notFoundAnimationView.isHidden = true
                }else{
                    let configuration = ToastConfiguration(
                        autoHide: true,
                        enablePanToClose: true,
                        displayTime: 3,
                        animationTime: 0.2
                    )
                    let toast = Toast.default(image: nil, title: "No results found!", subtitle: "No news articles could be founf with your search text",configuration: configuration)
                    toast.enableTapToClose()
                    searchResultCollectionView.isHidden = true
                    notFoundAnimationView.isHidden = false
                    notFoundAnimationView.play()
                    toast.show(haptic: .warning)
                }
            }
           
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView(style: .medium)
        view.addSubview(activityIndicator)
//        activityIndicator.backgroundColor = .red
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        notFoundAnimationView = .init(name: "notfoundresults")
        loadingAnimationView = .init(name: "loading")
        notFoundAnimationView.translatesAutoresizingMaskIntoConstraints = false
        notFoundAnimationView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        notFoundAnimationView.contentMode = .scaleAspectFit
        notFoundAnimationView.loopMode = .loop
        notFoundAnimationView.animationSpeed = 1
        
        loadingAnimationView.translatesAutoresizingMaskIntoConstraints = false
        loadingAnimationView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        loadingAnimationView.contentMode = .scaleAspectFit
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.animationSpeed = 1
        view.addSubview(notFoundAnimationView)
        view.addSubview(loadingAnimationView)
        newsWebViewController = NewsWebViewController()
        searchBar = SearchBarView()
        categoriesTableView = UITableView()
        categoriesTableView.translatesAutoresizingMaskIntoConstraints = false
        guard let searchBar = searchBar else {return}
        view.addSubview(searchResultCollectionView)
        view.addSubview(searchBar)
        view.addSubview(categoriesTableView)
        searchBar.searchButton.isEnabled = false
        notFoundAnimationView.isHidden = true
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
        constraints.append(notFoundAnimationView.centerXAnchor.constraint(equalTo: searchResultCollectionView.centerXAnchor))
        constraints.append(notFoundAnimationView.centerYAnchor.constraint(equalTo: searchResultCollectionView.centerYAnchor))
        constraints.append(loadingAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(loadingAnimationView.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        constraints.append(loadingAnimationView.heightAnchor.constraint(equalToConstant: 60))
        constraints.append(loadingAnimationView.widthAnchor.constraint(equalToConstant: 60))
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
        DispatchQueue.main.async { [self] in
            searchResultCollectionView.isHidden = true
//            activityIndicator.startAnimating()
            loadingAnimationView.isHidden = false
            loadingAnimationView.play()
            notFoundAnimationView.isHidden = true
        }
        if(searchText == ""){
            let configuration = ToastConfiguration(
                autoHide: true,
                enablePanToClose: true,
                displayTime: 3,
                animationTime: 0.2
            )
            let toast = Toast.default(image: nil, title: "No results found!", subtitle: "No news articles could be founf with your search text",configuration: configuration)
            toast.enableTapToClose()
            toast.show(haptic: .warning)
            return
        }
        NewsroomAPIService.APIManager.fetchSearchResults(searchText: searchText, sourceId: selectedSourceId) { data, error in
            if let error = error {
                print("errorrr: ",error)
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
            DispatchQueue.main.async { [self] in
                if let navigationController = navigationController{
                    newsWebViewController.url = url
                    navigationController.pushViewController(self.newsWebViewController, animated: true)
                }
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
        cell.sourceLabel.text = searchResults?.articles[indexPath.row].source.name
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
            notFoundAnimationView.isHidden = true
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
        return "Select category"
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}

extension SearchViewController: SourcesDelgate{
    func didSelectSource(_ controller: UIViewController, sourceId: String) {
        selectedSourceId = sourceId
    }
}
