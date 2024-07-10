//
//  NumbersViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import CombineCocoa

import Combine

class NumbersViewController: UIViewController {
    @IBOutlet weak var number1: UITextField!
    @IBOutlet weak var number2: UITextField!
    @IBOutlet weak var number3: UITextField!

    @IBOutlet weak var number4: UITextField!
    
    @IBOutlet weak var result: UILabel!
    
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 변화는 값만 프린트로 출력
        Publishers
            .CombineLatest4(number1.textPublisher,
                            number2.textPublisher,
                            number3.textPublisher,
                            number4.textPublisher) // 파이프라인 4개를 묶는 것임
            .map { textValue1, textValue2, textValue3, textValue4 -> Int in
                return textValue1.getNumber() + textValue2.getNumber() + textValue3.getNumber() + textValue4.getNumber()
            } // 연산자를 이용하여 형태를 변환 Int 타입으로 다 더한 다음 반환
            .sink(receiveValue: { value in
                print(#fileID, #function, #line, "- value : \(value)")
            })
            .store(in: &subscriptions) // 구독했을때 메모리 처리
            
        // 실제 결과 라벨에 반영
        Publishers
            .CombineLatest4(number1.textPublisher,
                            number2.textPublisher,
                            number3.textPublisher,
                            number4.textPublisher) // 4개를 묶는 것임
            .map { textValue1, textValue2, textValue3, textValue4 -> Int in
                return textValue1.getNumber() + textValue2.getNumber() + textValue3.getNumber() + textValue4.getNumber()
            } // 연산자를 이용하여 형태를 변환 Int 타입으로 다 더한 다음 반환
            .map{ "\($0)" } // 다시 스트링으로 변환
            .assign(to: \.text, on: result) // 라벨 텍스트여 연결하여 바로 값 변경되게 구현
            .store(in: &subscriptions) // 구독했을때 메모리 처리
            

    }
    
    
}

extension String? {
    
    func getNumber() -> Int {
        return Int(self ?? "0") ?? 0
    }
}

extension String {
    
    func getNumber() -> Int {
        return Int(self ?? "0") ?? 0
    }
}

