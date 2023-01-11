//
//  generalUtility.swift
//  newsroom
//
//  Created by Sarthak Jha on 06/01/23.
//

import Foundation
import UIKit

final class GeneralUtility {
    static func makeViewInactive(view: inout UIView){
        view.alpha = 0.7
        view.isUserInteractionEnabled = false
    }
    static func makeViewActive(view: inout UIView){
        view.alpha = 1
        view.isUserInteractionEnabled = true
    }
}
