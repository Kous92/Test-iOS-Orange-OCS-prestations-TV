//
//  Program.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 12/09/2021.
//

import Foundation

struct Programs: Codable {
    let template: String?
    let parentalrating: Int?
    let title: String?
    let offset: Int?
    let limit: String?
    let total, count: Int?
    let contents: [Content]?
}

// MARK: - Content
struct Content: Codable {
    let title: [Title]?
    let subtitle: String?
    let subtitlefocus: [String]?
    let imageurl, fullscreenimageurl, id, detaillink: String?
    let duration: String?
    let playinfoid: PlayInfo?
}

// MARK: - Playinfoid
struct PlayInfo: Codable {
    let hd, sd, uhd: String?
}

struct Title: Codable {
    let color: String?
    let type, value: String?
}

