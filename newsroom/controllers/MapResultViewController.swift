//
//  MapResultViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 22/12/22.
//

import UIKit

class MapResultViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var articleResponse: ArticleResponse? {
        didSet{
            DispatchQueue.main.async {
                self.newsCollectionView.reloadData()
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articleResponse?.articles.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = newsCollectionView.dequeueReusableCell(withReuseIdentifier: "map-cell", for: indexPath) as! HeadlineCollectionViewCell
        cell.headlineText.text = articleResponse?.articles[indexPath.row].title
        cell.cellBackgroundImage.sd_setImage(with: URL(string: articleResponse?.articles[indexPath.row].urlToImage ?? ""))
        return cell
    }
    
    
    var newsCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        newsCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        view.addSubview(newsCollectionView)
        newsCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        newsCollectionView.register(HeadlineCollectionViewCell.self, forCellWithReuseIdentifier: "map-cell")
        newsCollectionView.delegate = self
        newsCollectionView.dataSource = self
    }
    
    func addConstraints(){
        var constraints: [NSLayoutConstraint] = []
        constraints.append(view.heightAnchor.constraint(equalToConstant: 100))

        constraints.append(newsCollectionView.topAnchor.constraint(equalTo: view.topAnchor,constant: -40))
        constraints.append(newsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        constraints.append(newsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(newsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor))

        NSLayoutConstraint.activate(constraints)
    }
    
}

extension MapResultViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width-20, height: 150)
    }
}
