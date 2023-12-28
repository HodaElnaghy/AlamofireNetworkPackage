//
//  File.swift
//  
//
//  Created by Ahmed Hamam on 28/12/2023.
//

import Foundation

public enum ApiError: Error {
    case internalError
    case serverError
    case parsingError
    case urlBadFormmated
    case unknownError
    case errorDecoding
    
    var localizedError: String {
        switch self {
        case .internalError:
            "internalError"
        case .serverError:
            "serverError"
        case .parsingError:
            "parsingError"
        case .urlBadFormmated:
            "urlBadFormmated"
        case .unknownError:
            "unknownError"
        case .errorDecoding:
            "errorDecoding"
        }
    }
}

