//
//  ProgramViewController.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 07/09/2021.
//

import UIKit
import Kingfisher
import AVFoundation
import AVKit
import Combine

class ProgramDetailViewController: UIViewController {
    var subscriptions: Set<AnyCancellable> = []
    
    @IBOutlet weak var programImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    // Injection de dépendance, on exploite le contenu du programme sélectionné, stockée dans la vue modèle associée à la cellule du CollectionView.
    private var viewModel: ProgramDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBindings()
        viewModel.getProgramDetails()
    }
    
    @IBAction func backToMainView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /* Au tap sur le bouton Play:
     -> Un player AVPlayer est instancié.
     -> Une vue AVPlayerViewController est crée et une référence au player est passée.
     -> La vue du player AVPlayerViewController permet de lire, mettre en pause, avancer, reculer et diffuser par AirPlay, le flux vidéo par le biais d'HTTP Live Streaming. */
    @IBAction func playVideoStream(_ sender: Any) {
        // Pour la partie vidéo, je reprends le modèle venant d'Apple et le média de test fourni par Orange.
        guard let url = URL(string: viewModel.videoMediaStreamLink) else {
            return
        }
        
        // Création d'un player AVPlayer, on lui passe l'URL du média au format m3u8 afin de permettre le streaming HTTP en direct (HTTP Live Streaming)
        let player = AVPlayer(url: url)
        
        // Création d'un nouvel AVPlayerViewController et on passe une référence au player.
        let controller = AVPlayerViewController()
        controller.player = player

        // La vue est présentée modalement (en plein écran) et appelle la méthode play() du player lors de la compétion de present()
        present(controller, animated: true) {
            player.play()
        }
    }
}

extension ProgramDetailViewController {
    // Injection de dépendance, on exploite le contenu du programme sélectionné, stockée dans la vue modèle associée à la cellule du CollectionView.
    func prepareView(with viewModel: ProgramCellViewModel) {
        self.viewModel = ProgramDetailViewModel(programViewModel: viewModel)
    }
    
    private func setBindings() {
        viewModel.error.sink { [unowned self] message in
            if let errorMessage = message {
                let alert = UIAlertController(title: "Erreur", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                self.activitySpinner.stopAnimating()
            }
        }.store(in: &subscriptions)
        
        viewModel.loaded.sink { [unowned self] loaded in
            print(loaded)
            if loaded {
                self.activitySpinner.stopAnimating()
                self.titleLabel.text = self.viewModel.title
                self.subtitleLabel.text = self.viewModel.subtitle
                self.pitchLabel.text = self.viewModel.pitch
                self.setImage()
                
                // On affiche les éléments cachés une fois leur contenu récupéré.
                self.titleLabel.isHidden = false
                self.subtitleLabel.isHidden = false
                self.pitchLabel.isHidden = false
                programImage.isHidden = false
            } else {
                programImage.isHidden = true
                titleLabel.isHidden = true
                subtitleLabel.isHidden = true
                pitchLabel.isHidden = true
            }
        }.store(in: &subscriptions)
    }
    
    private func setImage() {
        // Avec Kingfisher, c'est asynchrone, rapide et efficace. Le cache est géré automatiquement.
        let defaultImage = UIImage(named: "OCSImageNotAvailable")
        let resource = ImageResource(downloadURL: URL(string: viewModel.imageURL)!)
        programImage.kf.indicatorType = .activity // Indicateur pendant le téléchargement
        programImage.kf.setImage(with: resource, placeholder: defaultImage)
    }
}
