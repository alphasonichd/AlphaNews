//
//  NewsModel.swift
//  AlphaNews
//
//  Created by developer on 25.05.21.
//

import Foundation

protocol ModelDelegate: AnyObject {
    func modelDidUpdate()
}

protocol NewsModelProtocol {
    func loadMore()
    func reloadData()
    func toggleShowMore(forArticleAt index: Int)
    func filterArticles(with text: String?)
    var modifiedArticles: [ModifiedArticle] { get }
    var filtered: String? { get }
    var event: Events { get }
    var delegate: ModelDelegate? { get set }
}

final class NewsModel: NewsModelProtocol {
    
    private let networkService = NetworkService()
    
    var event: Events = .loadMore
    var filtered: String?
    weak var delegate: ModelDelegate?
    var dayCount = 0
    
    private(set) var originalArticles: [ModifiedArticle] = []
    
    private(set) var modifiedArticles: [ModifiedArticle] = [] {
        didSet {
            delegate?.modelDidUpdate()
        }
    }
    
    var endDate: Date = Date()
    var beginDate: Date? {
        let beginDate = Calendar.current.date(byAdding: .hour,
                                             value: -24,
                                             to: endDate)
        return beginDate
    }
    private var stringEndDate: String {
        return endDate.iso8601withFractionalSeconds.replacingOccurrences(of: "Z", with: "")
    }
    private var stringBeginDate: String {
        guard let beginDate = beginDate else {
            return stringEndDate
        }
        return beginDate.iso8601withFractionalSeconds.replacingOccurrences(of: "Z", with: "")
    }
    
    var lastLoadedDay: Date = Date()
    
    func loadMore() {
        event = .loadMore
        guard let beginDate = beginDate, dayCount <= 6 else {
            return
        }
        endDate = beginDate
        dayCount += 1
        print(dayCount)
        print(endDate)
        fetchData(from: stringBeginDate, to: stringEndDate)
    }
    
    func reloadData() {
        event = .refresh
        dayCount = 0
        endDate = Date()
        modifiedArticles = []
        filtered = nil
        fetchData(from: stringBeginDate, to: stringEndDate)
    }
    
    func fetchData(from: String, to: String) {
        networkService.fetchNews(from: from, to: to) { result in
            switch result {
            case .failure(let error):
                print("Error fetching news: \(error)")
            case .success(let response):
                var modifiedArticles: [ModifiedArticle] = []
                response.articles.forEach { article in
                    modifiedArticles.append(ModifiedArticle(title: article.title,
                                                            description: article.description,
                                                            urlToImage: article.urlToImage,
                                                            showMore: false,
                                                            id: modifiedArticles.count
                    ))
                }
                self.modifiedArticles.append(contentsOf: modifiedArticles)
                self.originalArticles.append(contentsOf: modifiedArticles)
            }
        }
    }
    
    func filterArticles(with text: String?) {
        if let text = text {
            modifiedArticles = originalArticles.filter {$0.title.contains(text)}
        } else {
            modifiedArticles = originalArticles
        }
        
        filtered = text
    }
    
    func toggleShowMore(forArticleAt index: Int) {
        self.event = .cellUpdated(index)
        modifiedArticles[index].showMore = !modifiedArticles[index].showMore
        guard let targetIndex = originalArticles.firstIndex(where: { article in
            article.id == modifiedArticles[index].id
        }) else {
            return
        }
        originalArticles[targetIndex].showMore = !originalArticles[targetIndex].showMore
    }
}

struct ModifiedArticle {
    let title: String
    let description: String?
    let urlToImage: String?
    var showMore: Bool
    let id: Int
}

enum Events {
    case loadMore
    case refresh
    case cellUpdated(Int)
}
