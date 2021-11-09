//
//  ProgramCellViewModel.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 12/09/2021.
//

import Foundation
import Combine

class ProgramCellViewModel: Hashable {
    @Published private(set) var title: String
    @Published private(set) var subtitle: String
    @Published private(set) var imageURL: String
    @Published private(set) var fullScreenImageURL: String
    @Published private(set) var detaillink: String
    @Published private(set) var id: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: ProgramCellViewModel, rhs: ProgramCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    /*
     -> Concernant l'URL de l'image, il y a un problème, si on commence par le nom de domaine https://api.ocs.fr suivi de /data_plateforme/program/..., le code 503 sera retourné.
     -> La solution est d'utiliser le nom de domaine https://statics.ocs.fr à la place pour obtenir les images.
     -> Les données de l'API sont réelles et sont celles de la version mise en production.
    */
    let baseURL = "https://statics.ocs.fr"
    
    init(title: String = "", subtitle: String = "", imageURL: String = "", fullScreenImageURL: String = "", detaillink: String = "", id: String = "") {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = baseURL + imageURL
        self.fullScreenImageURL = baseURL + fullScreenImageURL
        self.detaillink = detaillink
        self.id = id
    }
}
