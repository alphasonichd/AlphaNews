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

final class NewsModel {
    
    private let networkService = NetworkService()
    
    var event: Events = .loadMore
    var filtered: String?
    weak var delegate: ModelDelegate?
    var dayCount = 0
    
    
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
    
    func setDatesAndLoadMore() {
        event = .loadMore
        guard let beginDate = beginDate, dayCount <= 6 else {
            return
        }
        endDate = beginDate
        dayCount += 1
        print(dayCount)
        print(endDate)
        loadMore(from: stringBeginDate, to: stringEndDate)
    }
    
    func reloadData() {
        dayCount = 0
        endDate = Date()
        modifiedArticles = []
        filtered = nil
        loadMore(from: stringBeginDate, to: stringEndDate)
    }
    
    func loadMore(from: String, to: String) {
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
                                                            showMore: false))
                }
                self.modifiedArticles.append(contentsOf: modifiedArticles)
            }
        }
    }
    
    func filterArticles(with text: String) {
        modifiedArticles = modifiedArticles.filter {$0.title.contains(text)}
        filtered = ""
    }
    
    func toggleShowMore(forArticleAt index: Int, event: Events) {
        self.event = event
        modifiedArticles[index].showMore = !modifiedArticles[index].showMore
        self.event = .loadMore
    }
}

struct ModifiedArticle {
    let title: String
    let description: String?
    let urlToImage: String?
    var showMore: Bool
}

enum Events {
    case loadMore
    case refresh
    case cellUpdated(Int)
}
