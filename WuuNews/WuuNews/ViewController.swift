//
//  ViewController.swift
//  WuuNews
//
//  Created by Tindwende Thierry Sawadogo on 8/27/22.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        return table
    }()
    
    let refreshControl = UIRefreshControl()
    
    var refreshBool: Bool = false
    
    private var viewModels = [NewsTableViewCellViewModel]()
    
    private var articles = [Article]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WuuNews"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .systemBackground
        
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        
        fetchAPI()
    }
    
    
    
    @objc func refresh(_ sender: AnyObject) {
           
           fetchAPI()
           
           if refreshBool{
           refreshControl.endRefreshing()
           }
       }
    
    
    
    private func fetchAPI() {
        
        APICaller.shared.getTopStories { [weak self] result in
            
            switch result {
            case .success(let articles):
                self?.refreshBool = true
                print("refresh worked")
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NewsTableViewCellViewModel(title: $0.title, subtitle: $0.description ?? "No Description" , imageURL: URL(string: $0.urlToImage ?? "" ))
                })
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath
        ) as? NewsTableViewCell else {
            fatalError()
        }
        //cell.textLabel!.text =
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let article = articles[indexPath.row]
        
        guard let url = URL(string: article.url ?? "") else { return }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}

