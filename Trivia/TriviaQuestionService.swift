//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Andry on 3/26/25.
//

import Foundation

struct TriviaResponse: Codable {
    let results: [TriviaQuestion]
}

class TriviaQuestionService {
    static func fetchTriviaQuestions(completion: @escaping ([TriviaQuestion]?) -> Void) {
        let urlString = "https://opentdb.com/api.php?amount=10" // Removed "&type=multiple"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to fetch trivia: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
                completion(decodedResponse.results) // Pass decoded questions to completion handler
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }

        task.resume()
    }
}
