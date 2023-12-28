////
////  File.swift
////  
////
////  Created by Ahmed Hamam on 28/12/2023.
////
//
//import Foundation
//import Alamofire
//
//class APIClient<T: APIRequest> {
//    
//    func fetchData<M: Decodable>(target: T, responseModel: M.Type, completion: @escaping (Result<M?, ApiError>) -> Void){
//        
//        let method = Alamofire.HTTPMethod(rawValue: target.method.rawValue)
//        let headers = Alamofire.HTTPHeaders(target.headers ?? [:])
//        let params = buildParams(task: target.task)
//        
//        AF.request(target.baseURL + target.path, method: method, parameters: params.0, encoding: params.1, headers: headers)
//            .validate()
//            .responseDecodable(of: responseModel) { (response) in
//                
//                guard let statusCode = response.response?.statusCode else {
//                    // Add custom error
//                    print("Can't get status code")
//                    completion(.failure(ApiError.unknownError))
//                    return
//                }
//                
//                if statusCode == 200 {
//                    // successful request
//                    guard let response = try? response.result.get() else {
//                        // Add custom error
//                        print("Error while getting response")
//                        completion(.failure(ApiError.errorDecoding))
//                        return
//                    }
//                    
//                    // return the result
//                    print("\(responseModel) result returned successfully")
//                    completion(.success(response))
//                    
//                } else {
//                    // Add custom error based on status code
//                    print("Status code not successful 200")
//                    completion(.failure(ApiError.serverError))
//                
//                }
//            }
//        // upload  > Rename
//        func uploadData<M: Decodable>(target: T, responseModel: M.Type, completion: @escaping (Result<M?, ApiError>) -> Void){
//            
//            let method = Alamofire.HTTPMethod(rawValue: target.method.rawValue)
//            let headers = Alamofire.HTTPHeaders(target.headers ?? [:])
//            let params = buildParams(task: target.task)
//            
//            AF.upload(multipartFormData: { multipartFormData in
//                
//            }, to: target.baseURL + target.path, method: method, headers: headers).uploadProgress(queue: .main, closure: { progress in
//                print("Upload Progress: \(progress.fractionCompleted)")
//            })
//        }
//        
//    }
//    
//    private func buildParams(task: Parameter) -> ([String: Any], ParameterEncoding){
//        switch task {
//            
//        case .requestPlain:
//            return ([:], URLEncoding.default)
//        case .requestParameters(parameter: let parameters, encoding: let encoding):
//            return (parameters, encoding)
//        }
//    }
//    
//}
