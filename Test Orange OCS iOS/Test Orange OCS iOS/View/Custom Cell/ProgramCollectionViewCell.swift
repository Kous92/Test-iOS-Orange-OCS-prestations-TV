//
//  ProgramCollectionViewCell.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 12/09/2021.
//

import UIKit
import Combine
import Kingfisher

class ProgramCollectionViewCell: UICollectionViewCell {
    
    // L'image au format small est initialement de taille 415x233, ratio: 415/233
    @IBOutlet weak var programImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    private var subscriptions: Set<AnyCancellable> = []
    
    var viewModel: ProgramCellViewModel? {
        didSet {
            setBindings()
        }
    }
    
    func configure(with viewModel: ProgramCellViewModel) {
        self.viewModel = viewModel
    }
    
    private func setBindings() {
        // Les labels s'actualisent de façon réactive par le biais de la vue modèle
        viewModel?.$title.assign(to: \.text!, on: titleLabel).store(in: &subscriptions)
        viewModel?.$subtitle.assign(to: \.text!, on: subtitleLabel).store(in: &subscriptions)
        
        // L'image va s'actualiser de façon réactive
        viewModel?.$imageURL.compactMap{ URL(string: $0) }.sink { [weak self] url in
            // Avec Kingfisher, c'est asynchrone, rapide et efficace. Le cache est géré automatiquement.
            let defaultImage = UIImage(named: "OCSImageNotAvailableSmall")
            let resource = ImageResource(downloadURL: url)
            self?.programImage.kf.indicatorType = .activity // Indicateur pendant le téléchargement
            self?.programImage.kf.setImage(with: resource, placeholder: defaultImage)
        }.store(in: &subscriptions)
    }
}
