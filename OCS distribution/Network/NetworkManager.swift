//
//  NetworkManager.swift
//  OCS distribution
//
//  Created by Sergey on 24/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

final class NetworkManager {
    private let baseUrl = URL(string: "https://jobs.github.com/positions.json")!
    private var currentRequest: String?
    private var page: Int = 0
    private var isLastPage = false
    
    private init() {}
    
    class func shared() -> NetworkManager {
        return sharedNetworkManager
    }
    
    private static var sharedNetworkManager: NetworkManager = {
        let networkManager = NetworkManager()
        return networkManager
    }()
    
    func getRequestVacancy(request: String, listener: NetworkProtocol) {
        if request != currentRequest {
            currentRequest = request
            isLastPage = false
            page = 0
        }
        
        let params:[String: String] = [
            "search" : request,
            "page" : String(page)
        ]
        makeRequest(params, listener)
    }
    
    func getRequestVacancy(listener: NetworkProtocol) {
        if !isLastPage {
            if let request = currentRequest {
                let params:[String: String] = [
                    "search" : request,
                    "page" : String(page)
                ]
                makeRequest(params, listener)
            }
        }
    }
    
    private func makeRequest(_ params:[String: String],_ listener: NetworkProtocol) {
        Alamofire.request(baseUrl, method: .get, parameters: params).responseJSON { response in
            if response.result.isSuccess {
                let responseJSON : JSON = JSON(response.result.value!)
                self.parsingJsonResult(responseJSON, listener)
            } else {
                listener.errorRequest(errorMessage: "Response in errorr \(response.error!)")
            }
        }
    }
    
    private func parsingJsonResult(_ responseJSON: JSON, _ listener: NetworkProtocol) {
        var resultVacancy = [Vacancy]()
        if let responseArray = responseJSON[].array {
            self.page += 1
            if !responseArray.isEmpty {
                for item in responseArray {
                    let vacancy = Vacancy(
                        id: item["id"].string ?? "none",
                        type: item["type"].string ?? "none",
                        url: item["url"].string ?? "none",
                        createdAt: item["created_at"].string ?? "none",
                        company: item["company"].string ?? "none",
                        companyUrl: item["company_url"].string ?? "none",
                        location: item["location"].string ?? "none",
                        title: item["title"].string ?? "none",
                        description: item["description"].string ?? "none",
                        howToApply: item["how_to_apply"].string ?? "none",
                        companyLogo: item["company_logo"].string ?? "none")
                    resultVacancy.append(vacancy)
                }
            } else {
                isLastPage = true
            }
            listener.successRequest(result: resultVacancy)
        }
    }
    
}
