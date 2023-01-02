//
//  SourcesViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 02/01/23.
//

import UIKit
import Lottie

protocol SourcesDelgate {
    func didSelectSource(_ controller: UIViewController, sourceId: String)
}
class SourcesViewController: UIViewController {
    var delegate: SourcesDelgate?
    var loadingIndicator: LottieAnimationView!
    var selectedSourceId: String?
    private var sourcesTableView: UITableView!
    var category: String?
    var sources: Sources? {
        didSet{
            DispatchQueue.main.async { [self] in
                loadingIndicator.stop()
                sourcesTableView.reloadData()
                sourcesTableView.isHidden = false
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadingIndicator = .init(name: "loading")
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        sourcesTableView = UITableView()
        sourcesTableView.translatesAutoresizingMaskIntoConstraints = false
        sourcesTableView.delegate = self
        sourcesTableView.isHidden = true
        sourcesTableView.dataSource = self
        guard let category = category else {return}
        view.addSubview(sourcesTableView)
        addConstraint()
        loadingIndicator.play()
        NewsroomAPIService.APIManager.fetchSources(category: category) { sources, err in
            if let error = err{
                print("sources:", error)
                DispatchQueue.main.async {
                    self.sourcesTableView.isHidden = false
                    self.loadingIndicator.stop()
                }
                return
            }
            self.sources = sources
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sources = nil
    }
    
    func addConstraint(){
        let constaints: [NSLayoutConstraint] = [
            sourcesTableView.topAnchor.constraint(equalTo: view.topAnchor),
            sourcesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sourcesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sourcesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 60),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 60)
        ]
        
        NSLayoutConstraint.activate(constaints)
    }
}
extension SourcesViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sources?.sources?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = sources?.sources![indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSourceId = sources?.sources![indexPath.row].id
        if let delegate = delegate{
            delegate.didSelectSource(self, sourceId: selectedSourceId!)

        }
        dismiss(animated: true)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select a source"
    }
}
