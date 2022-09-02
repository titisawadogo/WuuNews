//
//  APICaller.swift
//  WuuNews
//
//  Created by Tindwende Thierry Sawadogo on 8/27/22.
//

import Foundation

final class APICaller {
    
    static let shared = APICaller()
    
    struct Constants {
        static let topHeadlinesURL = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=0f6308c5fd89446688fe36ad6e581ff7")
    }
    
    private init() {}
    
    public func getTopStories(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let url = Constants.topHeadlinesURL else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    
                    print("Articles:\(result.articles.count)")
                    completion(.success(result.articles))
                    
                }
                catch {
                    completion(.failure(error))
                }
                
            }
        }
        task.resume()
    }
    
}


// Models

struct APIResponse: Codable {
    let articles: [Article]
}


struct Article: Codable {
    let source: Source
    let title: String
    let description: String? //?
    let url: String?//?
    let urlToImage: String?//?
    let publishedAt: String
}

struct Source: Codable {
    let name: String
}
