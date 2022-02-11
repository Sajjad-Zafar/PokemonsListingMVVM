//
//  NetworkError.swift
//  ProductListing
//
//  Created by Muhammad Sajjad Zafar on 28/03/2021.
//

import Foundation

public struct NetworkingError: Error {
    public enum Status: Int {
        case decodeModel            =   -10
        case unknown                =   -1
        case unableToParseResponse  =    1
        case wrongURL               =   -2
        case jsonToDataParsing      =   -3
        case badRequest             =   400
        case unauthorized           =   401
        case noResponse             =   404
        case internalServerError    =   500
        case tooManyRequest         =   429
    }
    
    public var status: Status
    public init(httpStatusCode: Int) {
        self.status = Status(rawValue: httpStatusCode) ?? .unknown
    }
}

extension NetworkingError: CustomStringConvertible {
    public var description: String {
        return String(describing: self.status)
            .replacingOccurrences(of: "(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])", with: "", options: [.regularExpression])
            .capitalized
    }
}

extension NetworkingError {
    public static var unableToParseResponse: NetworkingError {
        return NetworkingError(httpStatusCode: Status.unableToParseResponse.rawValue)
    }
    
    public static var unknown: NetworkingError {
        return NetworkingError(httpStatusCode: Status.unknown.rawValue)
    }
    public static var decodeModel: NetworkingError {
        return NetworkingError(httpStatusCode: Status.decodeModel.rawValue)
    }
    public static var genericError: String {
        return "Something went wrong."
    }
}
