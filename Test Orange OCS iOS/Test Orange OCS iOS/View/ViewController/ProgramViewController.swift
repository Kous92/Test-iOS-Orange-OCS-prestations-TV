//
//  ViewController.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 06/09/2021.
//

import UIKit
import Combine

class ProgramCollectionViewDiffableDataSource: UICollectionViewDiffableDataSource<String?, ProgramCellViewModel> {}

class ProgramViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var searchSuggestionLabel: UILabel!
    
    private var selectedIndex = 0
    var search = ""
    
    var cancellables: Set<AnyCancellable> = []
    @Published var searchKey = ""
    
    let viewModel = ProgramViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = createLayoutDifferentSection()
        setBindings()
        setViews()
    }
}

extension ProgramViewController {
    // C'est ici que la programmation réactive se met en place
    private func setBindings() {
        $searchKey.receive(on: RunLoop.main).removeDuplicates().sink { searchValue in
            print(searchValue)
            self.viewModel.searchQuery = searchValue
        }.store(in: &cancellables)
        
        viewModel.error.sink { [unowned self] message in
            if message == "Contenu vide" {
                self.noResultLabel.isHidden = true
                self.searchSuggestionLabel.isHidden = true
            } else {
                self.noResultLabel.isHidden = false
                self.searchSuggestionLabel.isHidden = false
                self.noResultLabel.text = message
            }
            
            self.noResultLabel.text = message
            // print("Erreur du ViewModel reçue: \(message ?? "Rien")")
        }.store(in: &cancellables)
        
        viewModel.updated.sink { [unowned self] updated in
            if updated {
                self.collectionView.isHidden = false
            } else {
                self.collectionView.isHidden = true
            }
        }.store(in: &cancellables)
        
        // iOS 13 requis. Avec le CollectionViewDiffableDataSource, l'actualisation est automatique dès que la vue modèle actualise le contenu.
        viewModel.diffableDataSource = ProgramCollectionViewDiffableDataSource(collectionView: collectionView) { (collectionView, indexPath, model) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "programCell", for: indexPath) as? ProgramCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.viewModel = model
            return cell
        }
    }
    
    private func setViews() {
        self.noResultLabel.isHidden = true
        self.searchSuggestionLabel.isHidden = true
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Annuler"
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .label
        searchBar.backgroundImage = UIImage() // Supprimer le fond par défaut
        searchBar.showsCancelButton = false
    }
}

extension ProgramViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(true, animated: true) // Afficher le bouton d'annulation
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchKey = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchKey = ""
        self.searchBar.text = ""
        searchBar.resignFirstResponder() // Masquer le clavier et stopper l'édition du texte
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Masquer le clavier et stopper l'édition du texte
        self.searchBar.setShowsCancelButton(false, animated: true) // Masquer le bouton d'annulation
    }
}

extension ProgramViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // print("Cellule \(selectedIndex) tapée.")
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "programDetailViewController") as? ProgramDetailViewController else {
            print("Erreur instanciation vue.")
            return
        }
        
        // Injection de dépendance, on exploite le contenu du programme sélectionné, stockée dans la vue modèle associée à la cellule du CollectionView.
        viewController.prepareView(with: viewModel.programCellViewModels[indexPath.row])
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true, completion: nil)
    }
}

// Ces 2 méthodes adoptant le protocole UICollectionViewDelegateFlowLayout permettent l'affiche du CollectionView sous forme de grille à 2 colonnes, adapté à tout format d'écran.
// Source: https://morioh.com/p/e468fe7e7488
extension ProgramViewController: UICollectionViewDelegateFlowLayout {
    private func createLayout() -> UICollectionViewLayout {
        // iOS 13 requis
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(CGFloat(10))
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func createLayoutDifferentSection() -> UICollectionViewLayout {
        // iOS 13 requis
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            var columns = 1
            switch sectionIndex{
            case 1:
                columns = 2
            case 2:
                columns = 5
            default:
                columns = 2
                
            }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            let groupHeight = columns == 1 ? NSCollectionLayoutDimension.absolute(44) : NSCollectionLayoutDimension.fractionalWidth(0.47)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10)
            return section
        }
        
        return layout
    }
}
