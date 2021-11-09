//
//  APIService.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 20/09/2021.
//

import Foundation

protocol APIService {
    func fetchPrograms(query: String, completion: @escaping (Result<Programs, OCSAPIError>) -> ())
    func fetchProgramDetails(detailUrl: String, completion: @escaping (Result<ProgramDetail, OCSAPIError>) -> ())
}
