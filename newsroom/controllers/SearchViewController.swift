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
    
    var tableView: UITableView!
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func loadView() {
        searchController = UISearchController(searchResultsController: nil)

        tableView = UITableView()
        tableView.tableHeaderView = searchController.searchBar
    }
}

extension SearchViewController: UITableViewDelegate{
    
}

extension SearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
