//
//  NetworkProtocol.swift
//  OCS distribution
//
//  Created by Sergey on 24/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import Foundation

protocol NetworkProtocol {
    func successRequest(result: [Vacancy])
    
    func errorRequest(errorMessage: String)
}
