//
//  BaseService.swift
//  Pokemon List
//
//  Created by Sajjad Zafar on 08/02/2022.
//

import Foundation
import Combine

let BASE_URL = "https://pokeapi.co"
let GET_POKEMONS_LIST_URL = "/api/v2/pokemon"

protocol APIService {
    var cancellables: Set<AnyCancellable> { get set }
    func requestCombine<T: Decodable>(with urlRequest: URLRequest) -> AnyPublisher<T, NetworkingError>
    func makeRequest<T: Decodable>(with urlString:String, method: String, query: [String:String]?, headers: [String : String]?, body: [String : Any]?, bodyInArray: [[String : Any]]?) -> AnyPublisher<T, NetworkingError>
    
    func post<T: Decodable>(_ urlString: String, query: [String:String]?, headers: [String : String]?, body: [String : Any]?, bodyInArray: [[String : Any]]?) -> AnyPublisher<T, NetworkingError>
    func get<T: Decodable>(_ urlString: String, query: [String:String]?, headers: [String : String]?, body: [String : Any]?) -> AnyPublisher<T, NetworkingError>
    func delete<T: Decodable>(_ urlString: String, query: [String:String]?, headers: [String : String]?, body: [String : Any]?) -> AnyPublisher<T, NetworkingError>
    func put<T: Decodable>(_ urlString: String, query: [String:String]?, headers: [String : String]?, body: [String : Any]?) -> AnyPublisher<T, NetworkingError>
    func decodeErrors(_ error: NetworkingError)
}


struct BaseService: APIService {
    
    var cancellables: Set<AnyCancellable>
    
    init() {
        cancellables = Set<AnyCancellable>()
    }
    
    func decodeErrors(_ error: NetworkingError) {
        print("StatusCode: \(error.status.rawValue) -> Error: \(error)")
    }
    
    func delete<T>(_ urlString: String, query: [String : String]?, headers: [String : String]?, body: [String : Any]?) -> AnyPublisher<T, NetworkingError> where T : Decodable {
        return makeRequest(with: urlString, method: "DELETE", query: query, headers: headers, body: body)
    }
    
    func put<T>(_ urlString: String, query: [String : String]?, headers: [String : String]?, body: [String : Any]?) -> AnyPublisher<T, NetworkingError> where T : Decodable {
        return makeRequest(with: urlString, method: "PUT", query: query, headers: headers, body: body)
    }
    
    func post<T>(_ urlString: String, query: [String : String]?, headers: [String : String]?, body: [String : Any]?, bodyInArray: [[String : Any]]? = nil) -> AnyPublisher<T, NetworkingError> where T : Decodable {
        
        return makeRequest(with: urlString, method: "POST", query: query, headers: headers, body: body, bodyInArray: bodyInArray)
    }
    
    func get<T>(_ urlString: String, query: [String : String]?, headers: [String : String]?, body: [String : Any]?) -> AnyPublisher<T, NetworkingError> where T : Decodable {
        
        return makeRequest(with: urlString, method: "GET", query: query, headers: headers, body: body)
    }
    
    func makeRequest<T>(with urlString:String, method: String = "GET", query: [String : String]? = nil, headers: [String : String]? = nil, body: [String : Any]? = nil, bodyInArray: [[String : Any]]? = nil) -> AnyPublisher<T, NetworkingError> where T : Decodable {
        
        let defaultQuery = query
        let completeUrl:String
        var params: [String] = []
        defaultQuery?.forEach { (key: String, value: String) in
            let param = "\(key)=\(value)"
            params.append(param)
        }
        let queryString = params.joined(separator: "&")
        completeUrl = "\(urlString)?\(queryString)"
        guard let url = URL(string: completeUrl) else {
            return Fail(error: NetworkingError(httpStatusCode: NetworkingError.Status.wrongURL.rawValue)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        if let headers = headers {
            headers.forEach({ (key: String, value: String) in
                request.setValue(value, forHTTPHeaderField: key)
            })
        }
        if let body = body {
            do {
                let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
                request.httpBody = bodyData as Data
            } catch {
                
                return Fail(error: NetworkingError(httpStatusCode: NetworkingError.Status.jsonToDataParsing.rawValue)).eraseToAnyPublisher()
            }
        }
        request.httpMethod = method
        print("REQUEST","URL: \(urlString)", "BODY \(body ?? [:])", "HEADERS \(headers ?? [:])", separator: "\n")
        return requestCombine(with: request)
    }
    
    func requestCombine<T>(with urlRequest: URLRequest) -> AnyPublisher<T, NetworkingError> where T : Decodable {
        
        let decoder = JSONDecoder()
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .receive(on: DispatchQueue.main)
            .mapError { _ in  .unknown }
            .flatMap { data, response -> AnyPublisher<T, NetworkingError> in
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 422 || response.statusCode == 400 || response.statusCode == 500 {
                        
                        return Just(data)
                            .decode(type: T.self, decoder: decoder)
                            .mapError {_ in .unableToParseResponse}
                            .eraseToAnyPublisher()
                        
                    } else if (200...299).contains(response.statusCode) {
                        data.printString()
                        return Just(data)
                            .decode(type: T.self, decoder: decoder)
                            .mapError {_ in .unableToParseResponse}
                            .eraseToAnyPublisher()
                    } else {
                        return Fail(error: NetworkingError(httpStatusCode: response.statusCode))
                            .eraseToAnyPublisher()
                    }
                }
                return Fail(error: NetworkingError.unknown)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
