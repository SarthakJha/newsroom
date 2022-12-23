//
//  article.swift
//  newsroom
//
//  Created by Sarthak Jha on 19/12/22.
//

import Foundation

enum StatusValues: String, Decodable {
    case ok = "ok"
    case error = "error"
}

struct ArticleResponse: Decodable {
    let status: StatusValues
    let totalResults: Int64?
    let articles: [Article]
}

struct Article:Decodable {
    let source: Source
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
}

struct Source: Decodable {
    let id: String?
    let name: String?
}
