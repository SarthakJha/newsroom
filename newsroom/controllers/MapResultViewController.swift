//
//  MapResultViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 22/12/22.
//

import UIKit
import CoreLocation

class MapResultViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var delegate:MapViewControllerDelegate!
    var dismissButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = true
        button.layer.cornerRadius = 2
        return button
    }()
    
    var dragable: UIView = {
        let dragableView = UIView()
        dragableView.translatesAutoresizingMaskIntoConstraints = true
        dragableView.backgroundColor = .systemGray
        dragableView.alpha = 0.6
        dragableView.layer.cornerRadius = 5
        return dragableView
    }()
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.didTapOnSearchResults(self, indexPath: indexPath)
    }
    
    @objc func dissmissSheet(){
        self.dismiss(animated: true)
    }
    
    var navBar: UINavigationBar!
    
    var articleResponse: ArticleResponse? {
        didSet{
            DispatchQueue.main.async {
                guard let newsCollectionView = self.newsCollectionView else {return}
                newsCollectionView.reloadData()
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articleResponse?.articles.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = newsCollectionView.dequeueReusableCell(withReuseIdentifier: "map-cell", for: indexPath) as! HeadlineCollectionViewCell
        cell.headlineText.text = articleResponse?.articles[indexPath.row].title
        cell.sourceLabel.text = articleResponse?.articles[indexPath.row].source.name
        cell.cellBackgroundImage.sd_setImage(with: URL(string: articleResponse?.articles[indexPath.row].urlToImage ?? ""))
        return cell
    }
    
    
    var newsCollectionView: UICollectionView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        self.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navBar)

        navBar.setItems([UINavigationItem(title: "results")], animated: true)
        
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
//        constraints.append(dismissButton.topAnchor.constraint(equalTo: view.topAnchor))
//        constraints.append(dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor))
//        constraints.append(dismissButton.bottomAnchor.constraint(equalTo: newsCollectionView.topAnchor))
//        constraints.append(dismissButton.heightAnchor.constraint(equalToConstant: 20))
//        constraints.append(dismissButton.widthAnchor.constraint(equalToConstant: 20))

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
