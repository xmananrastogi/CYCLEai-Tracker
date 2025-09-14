//
//  APIClient.swift
//  CYCLEai-Tracker
//
//  Created by Manan Rastogi on 14/09/25.
//

import Foundation

@MainActor
class APIClient: ObservableObject {
    private let baseURL: String
    private let session: URLSession
    private var authToken: String?

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    init(baseURL: String) {
        self.baseURL = baseURL
        self.session = URLSession.shared
    }

    func setAuthToken(_ token: String?) {
        self.authToken = token
    }

    // MARK: - Generic Request Methods

    func get<T: Decodable>(_ endpoint: String) async -> Result<T, APIError> {
        await performRequestWithDecodable(endpoint: endpoint, method: "GET", body: nil as String?)
    }

    func post<T: Encodable, U: Decodable>(_ endpoint: String, body: T?) async -> Result<U, APIError> {
        await performRequestWithDecodable(endpoint: endpoint, method: "POST", body: body)
    }

    func put<T: Encodable, U: Decodable>(_ endpoint: String, body: T?) async -> Result<U, APIError> {
        await performRequestWithDecodable(endpoint: endpoint, method: "PUT", body: body)
    }

    func delete(_ endpoint: String) async -> Result<Void, APIError> {
        await performRequestWithoutDecodable(endpoint: endpoint, method: "DELETE", body: nil as String?)
    }

    // MARK: - Private Helper Methods

    private func buildRequest<T: Encodable>(endpoint: String, method: String, body: T? = nil) -> Result<URLRequest, APIError> {
        guard let url = URL(string: baseURL + endpoint) else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                return .failure(.encodingError(error.localizedDescription))
            }
        }
        return .success(request)
    }

    private func performRequestWithDecodable<T: Encodable, U: Decodable>(endpoint: String, method: String, body: T?) async -> Result<U, APIError> {
        let requestResult = buildRequest(endpoint: endpoint, method: method, body: body)

        guard case .success(let request) = requestResult else {
            if case .failure(let error) = requestResult {
                return .failure(error)
            }
            return .failure(.unknown)
        }

        do {
            let (data, response) = try await session.data(for: request)
            try validateResponse(response)
            let decodedData = try decoder.decode(U.self, from: data)
            return .success(decodedData)
        } catch let error as APIError {
            return .failure(error)
        } catch let error as DecodingError {
            return .failure(.decodingError(error.localizedDescription))
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    private func performRequestWithoutDecodable<T: Encodable>(endpoint: String, method: String, body: T?) async -> Result<Void, APIError> {
        let requestResult = buildRequest(endpoint: endpoint, method: method, body: body)

        guard case .success(let request) = requestResult else {
            if case .failure(let error) = requestResult {
                return .failure(error)
            }
            return .failure(.unknown)
        }

        do {
            let (_, response) = try await session.data(for: request)
            try validateResponse(response)
            return .success(())
        } catch let error as APIError {
            return .failure(error)
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw APIError.unauthorized
        case 400...499:
            throw APIError.clientError(httpResponse.statusCode)
        case 500...599:
            throw APIError.serverError(httpResponse.statusCode)
        default:
            throw APIError.unexpectedStatusCode(httpResponse.statusCode)
        }
    }
}


// MARK: - API Error Types

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case clientError(Int)
    case serverError(Int)
    case unexpectedStatusCode(Int)
    case networkError(String)
    case decodingError(String)
    case encodingError(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The server URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .unauthorized:
            return "Authentication failed. Please check your credentials."
        case .clientError(let code):
            return "There was a problem with your request (Error: \(code))."
        case .serverError(let code):
            return "The server encountered an error (Error: \(code)). Please try again later."
        case .unexpectedStatusCode(let code):
            return "The server returned an unexpected status code: \(code)."
        case .networkError:
            return "Please check your internet connection and try again."
        case .decodingError:
            return "There was an issue processing data from the server."
        case .encodingError:
             return "There was an issue sending data to the server."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
