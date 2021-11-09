//
//  Test_Orange_OCS_iOSTests.swift
//  Test Orange OCS iOSTests
//
//  Created by Koussaïla Ben Mamar on 06/09/2021.
//

import XCTest
import Combine
@testable import Test_Orange_OCS_iOS

class Test_Orange_OCS_iOSTests: XCTestCase {
    var programViewModel: ProgramViewModel!
    var programCellViewModel: ProgramCellViewModel!
    var programDetailViewModel: ProgramDetailViewModel!
    var subscriptions: Set<AnyCancellable>!
    @Published var searchKey = ""
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        subscriptions = []
        programViewModel = ProgramViewModel(apiService: OCSMockAPIService(), sut: true)
        programCellViewModel = ProgramCellViewModel(title: "HITMAN", subtitle: "action, thriller", imageURL: "/data_plateforme/program/35797/origin_hitmanxxxxxw0014384_2bvz3.jpg?size=small", fullScreenImageURL: "/data_plateforme/program/35797/origin_hitmanxxxxxw0014384_2bvz3.jpg?size=large", detaillink: "/apps/v2/details/programme/HITMANXXXXXW0014384", id: "HITMANXXXXXW0014384")
        programDetailViewModel = ProgramDetailViewModel(programViewModel: programCellViewModel, apiService: OCSMockAPIService())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFetchProgramData() {
        let expectation = expectation(description: "Récupérer le contenu d'un programme recherché.")
        let apiService = OCSMockAPIService()
        apiService.resourceName = "dataProgramTest"
        
        apiService.fetchPrograms(query: "Hitman") { result in
            expectation.fulfill()
            switch result {
            case .success(let program):
                if let content = program.contents {
                    XCTAssertGreaterThan(content.count, 0)
                }
            case .failure(_):
                XCTFail()
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testFetchProgramDetailsData() {
        let expectation = expectation(description: "Récupérer le contenu des détails d'un programme recherché.")
        let apiService = OCSMockAPIService()
        apiService.resourceName = "dataProgramDetailsTest"
        
        apiService.fetchProgramDetails(detailUrl: "dataProgramDetailsTest") { result in
            expectation.fulfill()
            switch result {
            case .success(let program):
                XCTAssertNotNil(program.contents)
            case .failure(_):
                XCTFail()
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testBadRequest() {
        let expectation = expectation(description: "Vérifier que l'erreur d'une requête invalide se déclenche.")
        let apiService = OCSMockAPIService()
        apiService.resourceName = ""
        
        apiService.fetchPrograms(query: "") { result in
            expectation.fulfill()
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual("Erreur 400: Requête invalide (des paramètres sont manquants).", error.rawValue)
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testProgramCellViewModel() {
        XCTAssertEqual(programCellViewModel.title, "HITMAN")
        XCTAssertEqual(programCellViewModel.subtitle, "action, thriller")
        XCTAssertEqual(programCellViewModel.detaillink, "/apps/v2/details/programme/HITMANXXXXXW0014384")
    }
    
    func testProgramDetailViewModel() {
        XCTAssertEqual(programCellViewModel.title, "HITMAN")
        XCTAssertEqual(programCellViewModel.subtitle, "action, thriller")
        XCTAssertEqual(programCellViewModel.detaillink, "/apps/v2/details/programme/HITMANXXXXXW0014384")
    }
    
    func testProgramViewModelSearchKey() {
        let expectation = self.expectation(description: "Vérifier que l'appel réseau simulé donne du contenu.")
        
        searchKey = "Hitman"
        $searchKey.receive(on: RunLoop.main).removeDuplicates().sink { [weak self] searchValue in
            print(searchValue)
            self?.programViewModel.searchQuery = searchValue
            XCTAssertEqual("Hitman", searchValue)
            expectation.fulfill()
        }.store(in: &subscriptions)
        
        waitForExpectations(timeout: 1)
    }
    
    func testProgramViewModelFetchData() {
        let expect1 = XCTestExpectation(description: "Entrée reçue")
        let expect2 = XCTestExpectation(description: "Appel réseau et données récupérées")
        
        searchKey = "Hitman"
        $searchKey.receive(on: RunLoop.main).removeDuplicates().sink { [weak self] searchValue in
            print(searchValue)
            self?.programViewModel.searchQuery = searchValue
            expect1.fulfill()
        }.store(in: &subscriptions)
        
        programViewModel.updated.sink { updated in
            if updated {
                expect2.fulfill()
            }
        }.store(in: &subscriptions)
        
        wait(for: [expect1, expect2], timeout: 10)
        XCTAssertGreaterThan(programViewModel.contents.count, 0)
    }
    
    func testProgramViewModelError() {
        let expect3 = XCTestExpectation(description: "Aucune entrée fournie")
        let expect4 = XCTestExpectation(description: "Appel réseau et erreur récupérée")
        
        searchKey = ""
        $searchKey.receive(on: RunLoop.main).removeDuplicates().sink { [weak self] searchValue in
            print(searchValue)
            self?.programViewModel.searchQuery = searchValue
            expect3.fulfill()
        }.store(in: &subscriptions)
        
        programViewModel.error.sink { _ in
            expect4.fulfill()
        }.store(in: &subscriptions)
        
        wait(for: [expect3, expect4], timeout: 10)
        XCTAssertEqual(programViewModel.contents.count, 0)
    }
    
    func testProgramDetailViewModelFetchData() {
        let expect5 = XCTestExpectation(description: "Appel réseau et détails")
        programDetailViewModel.getProgramDetails()
        
        programDetailViewModel.loaded.sink { loaded in
            print(loaded)
            if loaded {
                expect5.fulfill()
            }
        }.store(in: &subscriptions)
        
        wait(for: [expect5], timeout: 5)
        XCTAssertEqual(programDetailViewModel.title, "HITMAN")
        XCTAssertTrue(programDetailViewModel.isMovie)
        XCTAssertEqual(programDetailViewModel.pitch, "Costume sombre, crâne rasé et code barre tatoué sur la nuque, l'agent 47 est le plus mystérieux et redoutable des tueurs professionnels. Il exécute ses contrats sans jamais laisser la moindre trace jusqu'au jour où sa cible l'oblige à se découvrir. Policiers, agents secrets et tueurs à gages... cette fois-ci, 47 est seul contre tous ! Xavier Gens, passionné de jeux vidéos, avait à coeur de ne pas trahir les fans de la saga Hitman : « Le principal challenge était de respecter un maximum, que ce soit dans les costumes ou les décors, l'univers graphique et la direction artistique du jeu, tous deux très marqués ». La jeune actrice Olga Kurylenko en est déjà a sa seconde apparition dans une adaptation de jeu vidéo puisqu'elle tourna dans Max Payne, quelques mois à peine après Hitman.")
    }
}
