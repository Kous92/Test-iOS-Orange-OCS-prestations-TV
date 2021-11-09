//
//  PitchProgram.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 12/09/2021.
//

import Foundation

struct ProgramDetail: Codable {
    var contents: Contents?
}

struct Contents: Codable {
    var duration: String?
    var pitch: String?
    var imageurl, fullscreenimageurl: String?
    var seasons: [Season]?
    var episodes: [Episode]?
}

struct Season: Codable {
    var menutitle: [SeasonTitle]?
    var subtitle: String?
    var number: Int?
    var pitch, imageurl: String?
    var episodes: [Episode]?
}

struct Episode: Codable {
    var number: Int?
}

struct SeasonTitle: Codable {
    var value: String?
}
