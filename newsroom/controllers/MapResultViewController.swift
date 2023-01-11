//
//  MapResultViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 22/12/22.
//

import UIKit
import CoreLocation

final class MapResultViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var delegate:MapViewControllerDelegate!
    private var currentPage: Int?
    private var newsCollectionView: UICollectionView!
    var didReachEnd: Bool?

    private var dismissButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = true
        button.layer.cornerRadius = 2
        return button
    }()
    
    private var dragable: UIView = {
        let dragableView = UIView()
        dragableView.translatesAutoresizingMaskIntoConstraints = true
        dragableView.backgroundColor = .systemGray
        dragableView.alpha = 0.6
        dragableView.layer.cornerRadius = 5
        return dragableView
    }()
    
    var articleResponse: ArticleResponse? {
        didSet{
            DispatchQueue.main.async {
                guard let newsCollectionView = self.newsCollectionView else {return}
                newsCollectionView.reloadData()
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.didTapOnSearchResults(self, indexPath: indexPath)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        newsCollectionView.setContentOffset(.zero, animated: false)
    }
    
    @objc func dissmissSheet(){
        self.dismiss(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articleResponse?.articles.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.row == (articleResponse?.articles.count)!-1 && !didReachEnd!){
            currentPage = currentPage! + 1
            NewsroomAPIService.APIManager.fetchHeadlines(category: nil, countryCode: nil,page: currentPage!) { articles, error in
                if let error = error{
                    return
                }
                self.articleResponse?.articles.append(contentsOf: articles!.articles)
                DispatchQueue.main.async {
                    self.newsCollectionView.reloadData()
                }
                if((self.articleResponse?.articles.count)! == (self.articleResponse?.totalResults!)!){
                    self.didReachEnd = true
                }
            }
        }
        let cell = newsCollectionView.dequeueReusableCell(withReuseIdentifier: "map-cell", for: indexPath) as! HeadlineCollectionViewCell
        cell.setData(headlineText: articleResponse?.articles[indexPath.row].title, sourceText: articleResponse?.articles[indexPath.row].source.name, backgroundImgURL: articleResponse?.articles[indexPath.row].urlToImage)
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPage = 2
        if (didReachEnd == nil){
            didReachEnd = false
        }
        self.view.translatesAutoresizingMaskIntoConstraints = false
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        newsCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        newsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newsCollectionView)
        view.addSubview(dismissButton)
        view.addSubview(dragable)
        dragable.frame = CGRect(x: view.frame.width/2-75, y: 0, width: 150, height: 10)

        dismissButton.addTarget(self, action: #selector(dissmissSheet), for: .touchUpInside)

        newsCollectionView.register(HeadlineCollectionViewCell.self, forCellWithReuseIdentifier: "map-cell")
        newsCollectionView.delegate = self
        
        newsCollectionView.dataSource = self
        addConstraints()

    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentPage = 2
        articleResponse = nil
    }
    
    
    func addConstraints(){
        var constraints: [NSLayoutConstraint] = []
        constraints.append(view.heightAnchor.constraint(equalToConstant: 100))
        constraints.append(dragable.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(dragable.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(dragable.bottomAnchor.constraint(equalTo: newsCollectionView.topAnchor))

        constraints.append(newsCollectionView.topAnchor.constraint(equalTo: dragable.bottomAnchor))
        constraints.append(newsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        constraints.append(newsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(newsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        NSLayoutConstraint.activate(constraints)
    }
    
}

extension MapResultViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width-20, height: 300)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
    }
}
