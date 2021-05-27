//
//  NetworkService.swift
//  AlphaNews
//
//  Created by developer on 25.05.21.
//

import Foundation

final class NetworkService {
    
    static let apiKey = "7ff1842574b845a696fde752eb84359d"
    private let urlPath = "https://newsapi.org/v2/top-headlines?country=us"
    
    public func fetchNews(from: String, to: String, completion: @escaping (Result<NewsResponse, Error>) -> Void) {
        guard let urlString = URL(string: "\(urlPath)&from=\(from)&to=\(to)&apiKey=\(NetworkService.apiKey)") else {
            completion(.failure(NSError(domain: "", code: 1, userInfo: nil)))
            return
        }

        let task = URLSession.shared.dataTask(with: urlString) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let newsData = self.parseJSON(data: data),
                  error == nil else {
                print("Error fetching data from urlsession")
                return
            }
            completion(.success(newsData))
        }
        task.resume()
    }
    
    private func parseJSON(data: Data) -> NewsResponse? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(NewsResponse.self, from: data)
            let articles = decodedData.articles
            return NewsResponse(articles: articles)
        } catch {
            return nil
        }
    }
}
