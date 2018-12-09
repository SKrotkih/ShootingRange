//
//  ShootingViewModel.swift
//  ShootingRange
//
//  Created by Sergey Krotkih on 29/11/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation
import RxSwift

class ShootingViewModel {

   var shotInTargetCount = PublishSubject<Int>()
    private let model = Model()
    private let disposeBag = DisposeBag()
    
    func startGame() {
        _shotInTargetCount = 0
        bindHitTargetEvent()
        model.startGame()
    }

    func stopGame() {
        model.stopGame()
    }
    
    private var _shotInTargetCount = 0 {
        didSet {
            shotInTargetCount.onNext(_shotInTargetCount)
        }
    }

    // Subscribe on the model's events like a "target hit"
    private func bindHitTargetEvent() {
        model.targetHit.subscribe(onNext: { [weak self] value in
            guard let `self` = self else {
                return
            }
            if value > 0 {
                self._shotInTargetCount += 1
            }
        }).disposed(by: disposeBag)
    }

}
