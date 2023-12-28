//
//  File.swift
//
//
//  Created by Ahmed Hamam on 28/12/2023.
//

import Foundation
import Alamofire

public protocol APIClientProtocol {
    associatedtype T where T: APIRequest
    
    func startRequest<M: Decodable>(target: T, responseModel: M.Type, completion: @escaping (Result<M?, ApiError>) -> Void)
    
    func startUploadRequest()
}

extension APIClientProtocol {
   public func startRequest<M: Decodable>(target: T, responseModel: M.Type, completion: @escaping (Result<M?, ApiError>) -> Void) {
        
        let method = Alamofire.HTTPMethod(rawValue: target.method.rawValue)
        let headers = Alamofire.HTTPHeaders(target.headers ?? [:])
        let params = buildParams(parameter: target.parameter)
        let encoding = buildParameterEncoding(encoding: target.encoding)
        
        AF.request(target.baseURL + target.path, method: method, parameters: params, encoding: encoding, headers: headers)
            .validate()
            .responseDecodable(of: responseModel) { (response) in
                
                guard let statusCode = response.response?.statusCode else {
                    print("Can't get status code")
                    completion(.failure(ApiError.unknownError))
                    return
                }
                
                if statusCode == 200 {
                    guard let response = try? response.result.get() else {
                        print("Error while getting response")
                        completion(.failure(ApiError.errorDecoding))
                        return
                    }
                        print("\(responseModel) result returned successfully")
                    completion(.success(response))
                    
                } else {
                    print("Status code not successful 200")
                    completion(.failure(ApiError.serverError))
                }
            }
    }
    //([String: Any], ParameterEncoding)
    private func buildParams(parameter: Parameter) -> ([String: Any]){
        switch parameter {
            
        case .requestPlain:
           // return ([:], URLEncoding.default)
            return ([:])
            // case .requestParameters(parameter: let parameters, encoding: let encoding)
        case .requestParameters(parameter: let parameters):
            return (parameters)
        }
    }
    
    private func buildParameterEncoding(encoding: ParametersEncoding) -> ParameterEncoding {
        switch encoding {
        case .noParam:
            return URLEncoding.default
        case .httpBody:
            return URLEncoding.httpBody
        case .queryString:
            return URLEncoding.queryString
        }
    }
    
}
