//
//  OCSAPIService.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 12/09/2021.
//

import Foundation
import Alamofire

class OCSAPIService: APIService {
    let baseURL = "https://api.ocs.fr/apps/v2/contents?search=title%3D"
    
    func fetchPrograms(query: String, completion: @escaping (Result<Programs, OCSAPIError>) -> ()) {
        let stringURL = baseURL + (query.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? "")
        guard let url = URL(string: stringURL) else {
            completion(.failure(.badRequest))
            return
        }
        
        print(url.absoluteString)
        AF.request(url).validate().responseDecodable(of: Programs.self) { response in
            switch response.result {
                case .success:
                    guard let data = response.value else {
                        completion(.failure(.downloadError))
                        return
                    }
                    
                    completion(.success(data))
                    
                case let .failure(error):
                    print(error)
                    guard let httpResponse = response.response else {
                        print("ERREUR: \(error)")
                        return
                    }
                    
                    switch httpResponse.statusCode {
                        case 400:
                            completion(.failure(.badRequest))
                        case 403:
                            completion(.failure(.forbidden))
                        case 404:
                            completion(.failure(.notFound))
                        case (500...599):
                            completion(.failure(.serverError))
                        default:
                            completion(.failure(.unknown))
                    }
            }
        }
    }
    
    func fetchProgramDetails(detailUrl: String, completion: @escaping (Result<ProgramDetail, OCSAPIError>) -> ()) {
        guard let url = URL(string: detailUrl) else {
            completion(.failure(.badRequest))
            return
        }
        
        print(url.absoluteString)
        AF.request(url).validate().responseDecodable(of: ProgramDetail.self) { response in
            switch response.result {
                case .success:
                    guard let data = response.value else {
                        completion(.failure(.downloadError))
                        return
                    }
                    
                    completion(.success(data))
                    
                case let .failure(error):
                    print(error)
                    guard let httpResponse = response.response else {
                        print("ERREUR: \(error)")
                        return
                    }
                    
                    switch httpResponse.statusCode {
                        case 400:
                            completion(.failure(.badRequest))
                        case 403:
                            completion(.failure(.forbidden))
                        case 404:
                            completion(.failure(.notFound))
                        case (500...599):
                            completion(.failure(.serverError))
                        default:
                            completion(.failure(.unknown))
                    }
            }
        }
    }
}
