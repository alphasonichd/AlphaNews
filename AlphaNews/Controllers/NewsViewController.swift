//
//  ViewController.swift
//  AlphaNews
//
//  Created by developer on 25.05.21.
//

import UIKit
import JGProgressHUD


class NewsViewController: UIViewController {
    
    private var newsModel: NewsModelProtocol = NewsModel()
    
    var refreshControl = UIRefreshControl()
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        return tableView
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        view.addSubview(searchBar)
        view.addSubview(tableView)
        refreshControl.attributedTitle = NSAttributedString(string: "Reloading...")
        refreshControl.addTarget(self,
                                 action: #selector(self.refresh(_:)),
                                 for: .valueChanged)
        searchBar.delegate = self
        tableView.addSubview(refreshControl)
        setupSearchBar()
        newsModel.delegate = self
        newsModel.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        spinner.show(in: view)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.frame = CGRect(x: 0,
                                 y: view.safeAreaLayoutGuide.layoutFrame.origin.y,
                                 width: view.frame.width,
                                 height: 50)
        tableView.frame = CGRect(x: 0,
                                 y: searchBar.frame.maxY,
                                 width: view.frame.width,
                                 height: view.frame.height - 50)
    }
    
    func setupTableView() {
        tableView.isHidden = true
        tableView.separatorInset = .zero
        tableView.register(cellClass: NewsTableViewCell.self)
        tableView.backgroundColor = #colorLiteral(red: 0.1811541617, green: 0.5091361403, blue: 0.6723850965, alpha: 1)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    func setupSearchBar() {
        searchBar.barTintColor = .clear
        searchBar.backgroundColor = #colorLiteral(red: 0.1811541617, green: 0.5091361403, blue: 0.6723850965, alpha: 1)
        searchBar.isTranslucent = true
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = #colorLiteral(red: 0.1811541617, green: 0.5091361403, blue: 0.6723850965, alpha: 1)
            textfield.backgroundColor = #colorLiteral(red: 0.9781451821, green: 0.8748882413, blue: 0.8631244302, alpha: 1)
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        newsModel.reloadData()
    }
}

//MARK: - TableView DataSource and Delegate

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsModel.modifiedArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        let article = newsModel.modifiedArticles[indexPath.row]
        cell.configure(imageUrl: article.urlToImage,
                       title: article.title,
                       content: article.description,
                       showMore: article.showMore)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        newsModel.toggleShowMore(forArticleAt: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == newsModel.modifiedArticles.count && newsModel.filtered == nil {
            newsModel.loadMore()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let myView = UIView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: tableView.frame.width,
                                          height: 40))
        let label = UILabel(frame: CGRect(x: 10,
                                          y: 10,
                                          width: tableView.frame.width,
                                          height: 40))
        label.font = UIFont(name: "Helvetica", size: 40.0)
        label.text = "Most Recent"
        label.textColor = #colorLiteral(red: 0.9781451821, green: 0.8748882413, blue: 0.8631244302, alpha: 1)
        myView.addSubview(label)
        return myView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65
    }
}

//MARK: - SearchBar Delegate

extension NewsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        newsModel.filterArticles(with: searchText)
        if searchText == "" {
            newsModel.filterArticles(with: nil)
        }
    }
}

//MARK: - Custom Protocols

extension NewsViewController: ModelDelegate {
    func modelDidUpdate() {
        switch newsModel.event {
        case .refresh:
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.isHidden = false
                self.tableView.separatorColor = #colorLiteral(red: 0.9781451821, green: 0.6626796946, blue: 0.8631244302, alpha: 1)
                self.spinner.dismiss()
                self.refreshControl.endRefreshing()
            }
        case .loadMore:
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.isHidden = false
                self.tableView.separatorColor = #colorLiteral(red: 0.9781451821, green: 0.6626796946, blue: 0.8631244302, alpha: 1)
                self.spinner.dismiss()
            }
        case .cellUpdated(let index):
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }
}
