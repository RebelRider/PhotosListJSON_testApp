//
//  JSONService.swift
//  PhotosListJSON_testApp
//
//  Created by Kirill Smirnov on 20.03.2024.
//

import Foundation


final class APIService {
    public static let photosUrl = "https://jsonplaceholder.typicode.com/photos"
    
    public static func fetchAllPhotos(_ completion: @escaping ([PhotoInfo], Error?) -> ()) {
        guard let url = URL(string: photosUrl) else {
            completion([], APIServiceError.wrongURL)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion([], error)
                }
                return
            }
            guard let data = data else { return }
            guard response != nil else { return }
            guard let photos = try? JSONDecoder().decode([PhotoInfo].self, from: data) else {
                DispatchQueue.main.async {
                    completion([], APIServiceError.decodeError)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(photos, nil)
            }
        }
        
        task.resume()
    }

}

public enum APIServiceError: Error {
    case wrongURL
    case decodeError
}
