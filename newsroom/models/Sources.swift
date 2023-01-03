//
//  Sources.swift
//  newsroom
//
//  Created by Sarthak Jha on 01/01/23.
//

import Foundation

struct Sources: Decodable{
    let status: StatusValues
    let sources: [SourceData]?
    let error: String?
}

struct SourceData: Decodable{
    let name: String
    let category: String
    let id: String
}
