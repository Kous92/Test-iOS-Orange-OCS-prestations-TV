//
//  OCSAPIError.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 12/09/2021.
//

import Foundation

enum OCSAPIError: String, Error {
    case badRequest = "Erreur 400: Requête invalide (des paramètres sont manquants)."
    case forbidden = "Erreur 403: Accès refusé."
    case notFound = "Erreur 404: Aucun contenu disponible."
    case serverError = "Erreur 500: Erreur serveur."
    case networkError = "Une erreur est survenue, pas de connexion Internet."
    case decodeError = "Une erreur est survenue au décodage des données téléchargées."
    case downloadError = "Une erreur est survenue au téléchargement des données."
    case unknown = "Erreur inconnue."
    case noContent = "Pas de contenu disponible."
}
