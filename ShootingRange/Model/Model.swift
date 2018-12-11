//
//  Model.swift
//  ShootingRange
//
//  Created by Sergey Krotkih on 30/11/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation
import RxSwift

class Model {

    // The global observable subject
    var targetHit = PublishSubject<Int>()
    
    var threadSafeCurrentTargets: [[UInt8]] {
        var targetsCopy: [[UInt8]]!
        targetIsQueue.sync {
            targetsCopy = self.targets
        }
        return targetsCopy
    }
    
    private var targetIsReady = PublishSubject<Bool>()
    private var targets = [[UInt8]]()
    private var _gameOver = false
    private var gameOver: Bool {
        get {
            var valueCopy: Bool!
            gameOverQueue.sync {
                valueCopy = self._gameOver
            }
            return valueCopy
        }
        set {
            gameOverQueue.async(flags: .barrier) { [weak self] in
                guard let `self` = self else {
                    return
                }
                self._gameOver = newValue
            }
        }
    }
    
    private let disposeBag = DisposeBag()
    // target's size
    private let targetSize = 10 * 1024 * 1024
    
    let background = DispatchQueue.global()
    private let gameOverQueue = DispatchQueue(label: "com.skdevappleid.ShootingRange.gameover", attributes: .concurrent)
    private let targetIsQueue = DispatchQueue(label: "com.skdevappleid.ShootingRange.targets", attributes: .concurrent)
    
    func startGame() {
        gameOver = false
        subscribeOnNewTarget()
        subscribeOnShot()
        generateNewTarget()
        prepareAndMakeNextShot()
    }
    
    func stopGame() {
        gameOver = true
    }
}

// MARK: - Private Target's methods

extension Model {
    
    // create a new target after random delay
    private func generateNewTarget() {
        
        if gameOver {
            return
        }
        
        let delayInSec = Double.random(in: 0.1...0.5)
        
        background.asyncAfter(deadline: .now() + delayInSec) { [weak self] in
            guard let `self` = self else {
                return
            }
            self.addTarget()
        }
    }
    
    // put new target to the array
    private func addTarget() {
        targetIsQueue.async(flags: .barrier) { [weak self] in
            let target: [UInt8] = Array(repeating: UInt8(0xFF), count: self?.targetSize ?? 0)
            self?.targets.append(target)
            self?.targetIsReady.onNext(true)
        }
    }
    
    // go to create the next target
    private func subscribeOnNewTarget() {
        targetIsReady.subscribe(onNext: { [weak self] value in
            self?.generateNewTarget()
        }).disposed(by: disposeBag)
    }
}

// MARK: - Private Shot's methods

extension Model {

    // prepare and make a next shot after random delay
    private func prepareAndMakeNextShot() {
        if gameOver {
            return
        }
        let delayInSec = Double.random(in: 0.1...0.5)
        background.asyncAfter(deadline: .now() + delayInSec) { [weak self] in
            guard let `self` = self else {
                return
            }
            self.makeShot()
        }
    }
    
    // make shot: remove random target's item
    private func makeShot() {
        targetIsQueue.async(flags: .barrier) { [weak self] in
            guard let `self` = self else {
                return
            }
            if self.targets.count > 0 {
                let index = Int.random(in: 0..<self.targets.count)
                // target is destroyed
                self.targets.remove(at: index)
                self.targetHit.onNext(index + 1)
            } else {
                self.targetHit.onNext(0)
            }
        }
    }
    
    // go to next shot
    private func subscribeOnShot() {
        targetHit.subscribe(onNext: { value in
            self.prepareAndMakeNextShot()
        }).disposed(by: disposeBag)
    }
}
