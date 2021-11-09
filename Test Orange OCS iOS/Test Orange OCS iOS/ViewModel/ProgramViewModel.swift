//
//  ProgramViewModel.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 12/09/2021.
//

import Foundation
import Combine
import UIKit

class ProgramViewModel {
    var sut = false // Si c'est par le biais d'un test ou non. SUT: System Under Test
    var cancellables = Set<AnyCancellable>()
    private let apiService: APIService?
    
    @Published var searchQuery = ""
    var error = CurrentValueSubject<String?, Never>(nil)
    var updated = CurrentValueSubject<Bool, Never>(false)
    
    var diffableDataSource: ProgramCollectionViewDiffableDataSource!
    var snapshot = NSDiffableDataSourceSnapshot<String?, ProgramCellViewModel>()
    
    // C'est cette vue modèle qui a un contact avec le modèle. La vue ne doit pas connaître le modèle.
    var contents = [Content]()
    
    // Chaque cellule a sa vue modèle, la vue ne doit rien savoir du modèle.
    var programCellViewModels = [ProgramCellViewModel]()
    
    // Injection de dépendance de l'objet qui gère l'appel de l'API
    init(apiService: APIService = OCSAPIService(), sut: Bool = false) {
        self.apiService = apiService
        self.sut = sut
        // Un puissant élément de la programmation réactive avec debounce, la recherche ne se déclenche qu'après une temporisation de 0,5 secondes. De plus, ça rend l'interface fluide et dynamique lorsque l'utilisateur recherche son contenu avec une actualisation automatique en temps réel.
        $searchQuery.receive(on: RunLoop.main).removeDuplicates().debounce(for: .seconds(0.5), scheduler: RunLoop.main).sink { _ in
            self.fetchOCSPrograms()
        }.store(in: &cancellables)
    }
    
    func fetchOCSPrograms() {
        guard !self.searchQuery.isEmpty && self.searchQuery.count > 1 else {
            self.error.send("Contenu vide")
            return
        }
        
        apiService?.fetchPrograms(query: searchQuery, completion: { [unowned self] result in
            guard (self.diffableDataSource != nil && !sut) || (sut && self.diffableDataSource == nil) else {
                print("Erreur Data Source")
                return
            }
            
            if !sut {
                self.snapshot.deleteAllItems()
                self.snapshot.appendSections([""])
            }
            
            switch result {
            case .success(let data):
                guard let content = data.contents else {
                    self.error.send("Aucun résultat pour \"\(self.searchQuery)\"")
                    self.updated.send(false)
                    return
                }
                
                self.contents = content
                self.programCellViewModels = self.contents.compactMap {ProgramCellViewModel(title: $0.title?[0].value ?? "", subtitle: $0.subtitle ?? "", imageURL: $0.imageurl ?? "", fullScreenImageURL: $0.fullscreenimageurl ?? "", detaillink: $0.detaillink ?? "")} 
                // Dès que les données sont mises à jour dans la vue modèle, le callback va permettre le data binding avec la vue pour que celle-ci mette automatiquement à jour les éléments visuels. C'est la partie-clé de l'architecture MVVM.
                // self?.callback(.reload)
                print("Succès: \(self.contents.count) programmes obtenus.")
                self.updated.send(true)
                
                if !sut {
                    if self.programCellViewModels.isEmpty {
                        self.diffableDataSource.apply(self.snapshot, animatingDifferences: true)
                        return
                    }
                
                    self.snapshot.appendItems(self.programCellViewModels, toSection: "")
                    self.diffableDataSource.apply(self.snapshot, animatingDifferences: true)
                }
                
            case .failure(let error):
                print(error.rawValue)
                self.error.send(error.rawValue)
                self.updated.send(false)
            }
        })
    }
}
