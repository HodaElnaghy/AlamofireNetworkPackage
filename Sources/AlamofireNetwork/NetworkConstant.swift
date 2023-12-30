//
//  File.swift
//  
//
//  Created by Ahmed Hamam on 28/12/2023.
//

import Foundation
import Alamofire

public enum HTTPMethod: String{
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum Parameter{
    case requestPlain
    case requestParameters( parameter: [String: Any] )

}

public enum ParametersEncoding {
    case noParam
    case httpBody
    case queryString
}

public protocol APIRequest {

    var baseURL: String { get }

    var path: String { get }

    var method: HTTPMethod { get }

    var parameter: Parameter { get }
    
    var encoding: ParametersEncoding { get }
    
    var headers: [String: String]? { get }
}
