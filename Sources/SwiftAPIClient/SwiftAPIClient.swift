// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

protocol APIClient {
    var session: URLSession { get }
    var baseURL: URL { get }
    var defaultHeaders: [String: String] { get }
}

extension APIClient {
    func makeRequest(
        endpoint: String,
        method: String = "GET",
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil,
        additionalHeaders: [String: String] = [:]
    ) throws -> URLRequest {
        let url = baseURL.appending(path: endpoint)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        components?.queryItems = queryItems?.isEmpty == false ? queryItems : nil

        guard let finalURL = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = method
        request.httpBody = body

        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        for (key, value) in defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        for (key, value) in additionalHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    func perform<T: Decodable>(
        _ endpoint: String,
        method: String = "GET",
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: [String: String] = [:]
    ) async throws -> T {
        let request = try makeRequest(
            endpoint: endpoint,
            method: method,
            queryItems: queryItems,
            body: body,
            additionalHeaders: headers
        )

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
            (200..<300).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

extension APIClient {
    var defaultHeadres: [String: String] { [:] }
}
