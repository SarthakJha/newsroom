//
//  searchViewModel.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/01/23.
//

import Foundation

final class SearchViewModel: NewsViewmodel {
    
    override init(screenType: NewsControllerType, countryCode: String? = "in", delegate: ViewModelDelegate? = nil, newsArticles: ArticleResponse? = nil) {
        
        super.init(screenType: screenType)
    }
}
