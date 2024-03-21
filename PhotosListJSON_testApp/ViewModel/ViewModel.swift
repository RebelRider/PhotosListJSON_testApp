//
//  ViewModel.swift
//  PhotosListJSON_testApp
//
//  Created by Kirill Smirnov on 20.03.2024.
//

import Foundation

public protocol ViewModel: AnyObject {
    associatedtype ViewState
    typealias RenderStateCallback = (ViewState) -> ()
    func setRenderCallback(_ renderCallback: @escaping RenderStateCallback)
}
