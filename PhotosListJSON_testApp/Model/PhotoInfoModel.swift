//
//  PhotoInfoModel.swift
//  PhotosListJSON_testApp
//
//  Created by Kirill Smirnov on 20.03.2024.
//

import Foundation


public struct PhotoInfo: Codable {
    var albumId: Int
    var id: Int
    var title: String
    var url: String
    var thumbnailUrl: String
}
