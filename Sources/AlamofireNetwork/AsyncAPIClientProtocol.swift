//
//  File.swift
//
//
//  Created by Omar on 30/12/2023.
//

import Foundation
import Alamofire

public protocol AsyncAPIClientProtocol {
    associatedtype T where T: APIRequest
    
    func startRequest<M: Decodable>(target: T, responseModel: M.Type) async throws -> M
    func uploadData<M: Decodable>(target: T, responseModel: M.Type) async throws -> M?
}

extension AsyncAPIClientProtocol {
    public func startRequestWithAsyncAwait<M: Decodable>(target: T, responseModel: M.Type) async throws -> M {
        let method = Alamofire.HTTPMethod(rawValue: target.method.rawValue)
        let headers = Alamofire.HTTPHeaders(target.headers ?? [:])
        let params = buildParams(parameter: target.parameter)
        let encoding = buildParameterEncoding(encoding: target.encoding)
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(target.baseURL + target.path,
                       method: method,
                       parameters: params,
                       encoding: encoding,
                       headers: headers)
            .validate()
            .responseDecodable(of: M.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func startUploadRequestWithAsyncAwait<M: Decodable>(target: T, responseModel: M.Type) async throws -> M? {
        let method = Alamofire.HTTPMethod(rawValue: target.method.rawValue)
        let headers = Alamofire.HTTPHeaders(target.headers ?? [:])
        let parameters = buildParams(parameter: target.parameter)
        
        let response: M? = try await withCheckedThrowingContinuation { continuation in
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
            }, to: target.baseURL + target.path, method: method, headers: headers)
            .validate()
            .responseDecodable(of: M.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        return response
    }
    
    private func buildParams(parameter: Parameter) -> [String: Any] {
        switch parameter {
        case .requestPlain:
            return ([:])
        case .requestParameters(parameter: let parameters):
            return parameters
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
