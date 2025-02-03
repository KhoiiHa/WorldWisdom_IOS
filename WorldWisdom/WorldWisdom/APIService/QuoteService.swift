//
//  QuoteService.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import Foundation

class QuoteService {

    static let shared = QuoteService()

    private let baseURL = "http://localhost:3001" // Mockoon läuft lokal auf Port 3001

    private func fetchData<T: Decodable>(from url: URL) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Code: \(httpResponse.statusCode)")
            }
            print("Response Data: \(String(data: data, encoding: .utf8) ?? "Keine Daten")")

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw QuoteError.networkError("Ungültige Serverantwort")
            }

            return try JSONDecoder().decode(T.self, from: data)

        } catch let decodingError as DecodingError {
            throw QuoteError.parsingError("Fehler beim Decodieren der Daten: \(decodingError.localizedDescription)")
        } catch {
            throw QuoteError.handleError(error)
        }
    }

    // Funktion für das Abrufen von Zitaten
    func fetchQuotes() async throws -> [Quote] {
        let urlString = "\(baseURL)/api/quotes"

        // Fetch Data mit der generierten URL
        guard let url = URL(string: urlString) else {
            throw QuoteError.networkError("Ungültige URL")
        }

        return try await fetchData(from: url)
    }
}
