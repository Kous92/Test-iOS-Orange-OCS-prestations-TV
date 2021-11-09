//
//  ProgramPitchViewModel.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 15/09/2021.
//

import Foundation
import Combine

class ProgramDetailViewModel {
    var cancellables = Set<AnyCancellable>()
    
    var error = CurrentValueSubject<String?, Never>(nil)
    var loaded = CurrentValueSubject<Bool, Never>(false)
    
    private let apiService: APIService?
    private let detaillink: String
    
    private(set) var videoMediaStreamLink: String
    
    // L'élément-clé de l'architecture MVVM pour le data binding entre la vue et la vue modèle. La vue ayant une référence sur ce callback va permettre la mise à jour de son contenu.
    var callback: (_ type: CallbackType) -> () = { _ in }
    
    // Ici nous avons les champs pour que ce la vue doit afficher
    @Published private(set) var imageURL: String
    @Published private(set) var title: String
    @Published private(set) var subtitle: String
    @Published private(set) var isMovie: Bool = false
    @Published private(set) var isSerie: Bool = false
    @Published private(set) var seasons: Int = 0
    @Published private(set) var pitch: String = ""
    
    // Injection de dépendances
    init(programViewModel: ProgramCellViewModel, apiService: APIService = OCSAPIService()) {
        self.apiService = apiService
        detaillink = "https://api.ocs.fr" + programViewModel.detaillink
        imageURL = programViewModel.fullScreenImageURL
        title = programViewModel.title
        subtitle = programViewModel.subtitle
        
        // Ancien contenu vidéo: "https://ocsstreaming.akamaized.net/olstest/ols1/ols1_hd.m3u8"
        videoMediaStreamLink = "https://bitmovin-a.akamaihd.net/content/bbb/stream.m3u8"
    }
    
    func getProgramDetails() {
        apiService?.fetchProgramDetails(detailUrl: detaillink, completion: { [unowned self] result in
            switch result {
            case .success(let data):
                print("OK")
                
                guard let content = data.contents else {
                    self.error.send("Erreur: aucun contenu pour \"\(self.title)\"")
                    self.loaded.send(false)
                    return
                }
                
                // S'il y a une durée, le contenu est en format film. Sinon, c'est une série avec des saisons et des épisodes.
                if content.duration != nil {
                    self.isMovie = true
                    self.pitch = content.pitch ?? "Pitch indisponible"
                } else {
                    self.isSerie = true
                    
                    if let seasons = content.seasons {
                        self.seasons = seasons.count
                        self.subtitle = "Saison \(seasons[0].number ?? 1), \(seasons[0].subtitle ?? "Sous-titre indisponible pour la saison \(seasons[0].number ?? 1)")"
                        self.pitch = seasons[0].pitch ?? "Pitch indisponible"
                    }
                }
    
                self.loaded.send(true)
            case .failure(let error):
                print(error.rawValue)
                // S'il y a eu une erreur, le callback va notifier la vue qu'il y a une erreur à afficher, par le biais du data binding de l'architecture MVVM.
                self.error.send(error.rawValue)
                self.loaded.send(false)
            }
        })
    }
    
    func fetchProgramDetails() {
        apiService?.fetchProgramDetails(detailUrl: detaillink, completion: { [weak self] result in
            switch result {
            case .success(let data):
                print("OK")
                
                guard let content = data.contents else {
                    self?.callback(.failure(OCSAPIError.noContent.rawValue))
                    return
                }
                
                // S'il y a une durée, le contenu est en format film. Sinon, c'est une série avec des saisons et des épisodes.
                if content.duration != nil {
                    self?.isMovie = true
                    self?.pitch = content.pitch ?? "Pitch indisponible"
                } else {
                    self?.isSerie = true
                    
                    if let seasons = content.seasons {
                        self?.seasons = seasons.count
                        self?.subtitle = "Saison \(seasons[0].number ?? 1), \(seasons[0].subtitle ?? "Sous-titre indisponible pour la saison \(seasons[0].number ?? 1)")"
                        self?.pitch = seasons[0].pitch ?? "Pitch indisponible"
                    }
                }
    
                self?.callback(.reload)
            case .failure(let error):
                print(error.rawValue)
                // S'il y a eu une erreur, le callback va notifier la vue qu'il y a une erreur à afficher, par le biais du data binding de l'architecture MVVM.
                self?.callback(.failure(error.rawValue))
            }
        })
    }
}
