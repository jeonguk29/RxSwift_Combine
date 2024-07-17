//
//  NumbersViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa //를 사용하여 버튼 클릭, 타이핑에 대한 이벤트(변경)를 처리할 수 있음 즉 Observable로 받을수 있음

class NumbersViewController: ViewController {
    @IBOutlet weak var number1: UITextField!
    @IBOutlet weak var number2: UITextField!
    @IBOutlet weak var number3: UITextField!

    @IBOutlet weak var result: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // combineLatest를 활용하여 두 가지 파이프라인을 합침 - 아래 하나하나가 파이프라인
        Observable.combineLatest(number1.rx.text.orEmpty,
                                 number2.rx.text.orEmpty,
                                 number3.rx.text.orEmpty) {
            textValue1, textValue2, textValue3 -> Int in
                return (Int(textValue1) ?? 0) + (Int(textValue2) ?? 0) + (Int(textValue3) ?? 0)
            } // 3가지 물줄기를 합쳐서 Int로 반환
            .map { $0.description } // 연산자를 통해 숫자를 문자열로 바꿈
            .bind(to: result.rx.text) // 구독이 되어 있음
            .disposed(by: disposeBag)
            // 구독을 하면 disposed 라는 찌꺼기가 나오는데 disposeBag에 보내서 한번에 관리
    }
}

