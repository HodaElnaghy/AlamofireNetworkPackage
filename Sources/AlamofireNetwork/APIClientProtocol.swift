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
    
    func startRequest<M: Decodable>(target: T, responseModel: M.Type, completion: @escaping (Result<M, ApiError>) -> Void)
    func startUploadRequest<M: Codable>(target: T, responseModel: M.Type,fileExt: String  ,completion: @escaping (Result<M?, ApiError>) -> Void)
}

extension APIClientProtocol {
    public func startRequest<M: Decodable>(target: T, responseModel: M.Type, completion: @escaping (Result<M, ApiError>) -> Void) {
        
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
    
    func startUploadRequest<M: Codable>(target: T, responseModel: M.Type, completion: @escaping (Result<M?, ApiError>) -> Void) {
        let method = Alamofire.HTTPMethod(rawValue: target.method.rawValue)
        let headers = Alamofire.HTTPHeaders(target.headers ?? [:])
        let parameters = buildParams(parameter: target.parameter)
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                if let string = value as? String {
                    multipartFormData.append(string.data(using: .utf8)!, withName: key)
                }
                if let integer = value as? Int {
                    multipartFormData.append("\(integer)".data(using: .utf8)!, withName: key)
                }
                if let double = value as? Double {
                    multipartFormData.append("\(double)".data(using: .utf8)!, withName: key)
                }
                if let data = value as? Data {
                    multipartFormData.append(data, withName: key, fileName: "file.png", mimeType: "image/png")
                }
            }
        },to: target.baseURL + target.path, method: method, headers: headers).uploadProgress(queue: .main, closure: { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        })
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
    
    private func buildParams(parameter: Parameter) -> ([String: Any]){
        switch parameter {
            
        case .requestPlain:
            return ([:])
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
