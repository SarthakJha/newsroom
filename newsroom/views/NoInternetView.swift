//
//  NoInternetView.swift
//  newsroom
//
//  Created by Sarthak Jha on 09/01/23.
//

import UIKit
import Lottie
import Toast

final class NoInternetView: UIView {
    
    private var noInternetLottie: LottieAnimationView = {
        var view = LottieAnimationView.init(name: "noInternet")
        view.loopMode = .loop
        view.animationSpeed = 1.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var tryAgainButton: UIButton = {
        var button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        let myNormalAttributedTitle = NSAttributedString(string: "Try again!",
                                                         attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
        
        button.setAttributedTitle(myNormalAttributedTitle, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(noInternetLottie)
        addSubview(tryAgainButton)
        tryAgainButton.addTarget(self, action: #selector(checkConnectivity), for: .touchUpInside)
        viewConstraints()
    }
    
    @objc private func checkConnectivity(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            if(NetworkMonitor.shared.isReachable){
                self.stopView()
            }else{
                let configuration = ToastConfiguration(
                    autoHide: true,
                    enablePanToClose: true,
                    displayTime: 3,
                    animationTime: 0.2
                )
                ToastHandler.performToast(toastTitle: "Connection failed!", toastDescription: "Unable to connect to the internet!", toastConfig: configuration)
            }
        }
    }
    
    private func viewConstraints(){
        let constraints: [NSLayoutConstraint] = [
            noInternetLottie.centerXAnchor.constraint(equalTo: centerXAnchor),
            noInternetLottie.centerYAnchor.constraint(equalTo: centerYAnchor),
            noInternetLottie.heightAnchor.constraint(equalToConstant: 200),
            noInternetLottie.widthAnchor.constraint(equalToConstant: 200),
            tryAgainButton.topAnchor.constraint(equalTo: noInternetLottie.bottomAnchor),
            tryAgainButton.widthAnchor.constraint(equalToConstant: noInternetLottie.frame.width),
            tryAgainButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    public func startView(){
        noInternetLottie.play()
        isHidden = false
    }
    public func stopView(){
        noInternetLottie.stop()
        isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
