//
//  ShootingViewController.swift
//  ShootingRange
//
//  Created by Sergey Krotkih on 29/11/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

class ShootingViewController: UIViewController {

    @IBOutlet weak var shootedCountLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    private let viewModel = ShootingViewModel()
    private let disposeBag = DisposeBag()
    private var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.startGame()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.stopGame()
    }
    
    private func configureView() {
        bindTheLabel()
        bindCloseButton()
    }
    
    private func bindTheLabel() {
        viewModel.shotInTargetCount.subscribe(onNext: { [weak self] value in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.shootedCountLabel.text = "\(value)"
                self.playSound()
            }
        }).disposed(by: disposeBag)
    }
    
    private func bindCloseButton() {
        closeButton.rx.tap.bind(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
}

// MARK: - Private methods

extension ShootingViewController {

    private func playSound() {
        let path = Bundle.main.path(forResource: "shot", ofType: "mp3")
        let url = URL(fileURLWithPath: path ?? "")
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
