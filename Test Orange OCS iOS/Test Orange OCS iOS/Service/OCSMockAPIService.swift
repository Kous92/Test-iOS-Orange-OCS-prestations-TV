//
//  OCSMockAPIService.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 20/09/2021.
//

import Foundation

class OCSMockAPIService: APIService {
    var resourceName = ""
    
    func fetchPrograms(query: String, completion: @escaping (Result<Programs, OCSAPIError>) -> ()) {
        print("Resource: \(resourceName)")
        resourceName = "dataProgramTest"
        
        // Pour le test, on se focalisera que sur le film Hitman à titre d'exemple
        guard !query.isEmpty else {
            completion(.failure(.badRequest))
            return
        }
        
        guard let path = Bundle.main.path(forResource: self.resourceName, ofType: "json") else {
            print("Fichier dataProgramTest.json introuvable")
            completion(.failure(.notFound))
            return
        }
        
        // Pour le test, on se focalisera que sur le film Hitman à titre d'exemple
        guard query == "Hitman" else {
            completion(.failure(.noContent))
            return
        }
        
        let url = URL(fileURLWithPath: path)
        var programs: Programs?
        
        do {
            // Récupération des données JSON en type Data
            let data = try Data(contentsOf: url)
            
            // Décodage des données JSON en objets exploitables
            programs = try JSONDecoder().decode(Programs.self, from: data)
            
            if let result = programs {
                completion(.success(result))
                return
            } else {
                completion(.failure(.decodeError))
                return
            }
        } catch {
            print("ERREUR: \(error)")
            completion(.failure(.decodeError))
        }
    }
    
    func fetchProgramDetails(detailUrl: String, completion: @escaping (Result<ProgramDetail, OCSAPIError>) -> ()) {
        resourceName = "dataProgramDetailsTest"
        
        guard let path = Bundle.main.path(forResource: self.resourceName, ofType: "json") else {
            print("Fichier dataProgramDetailsTest.json introuvable")
            completion(.failure(.notFound))
            return
        }
        
        let url = URL(fileURLWithPath: path)
        var programDetails: ProgramDetail?
        
        do {
            // Récupération des données JSON en type Data
            let data = try Data(contentsOf: url)
            
            // Décodage des données JSON en objets exploitables
            programDetails = try JSONDecoder().decode(ProgramDetail.self, from: data)
            
            if let result = programDetails {
                completion(.success(result))
                return
            } else {
                completion(.failure(.decodeError))
                return
            }
        } catch {
            print("ERREUR: \(error)")
            completion(.failure(.decodeError))
        }
    }
}
