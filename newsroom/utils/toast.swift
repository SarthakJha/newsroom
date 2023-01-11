//
//  toast.swift
//  newsroom
//
//  Created by Sarthak Jha on 06/01/23.
//

import Foundation
import Toast


public final class ToastHandler {

    @MainActor static func performToast(toastTitle title: String, toastDescription desc: String, toastConfig config: ToastConfiguration) {
        
        let toast = Toast.default(image: nil, title: title, subtitle: desc,configuration: config)
        toast.enableTapToClose()
        toast.show(haptic: .error)
    }
}
