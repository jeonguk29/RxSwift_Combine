//
//  NumbersVM.swift
//  CombineTutorial-example
//
//  Created by 정정욱 on 7/10/24.
//

import Foundation
import Combine

class NumbersVM: ObservableObject {
    
    var subscriptions = Set<AnyCancellable>()
    
    // Input - 뷰모델로 들어오는 녀석
    
    @Published var number1 = ""
    @Published var number2 = ""
    @Published var number3 = ""
    @Published var number4 = ""
    
    // OutPut - 뷰모델에서 나가는 녀석
    @Published var resultValue: String = ""
    
    lazy var resultPublisher : AnyPublisher<String, Never> =
    Publishers.CombineLatest4($number1,
                              $number2,
                              $number3,
                              $number4) // 4개를 묶는 것임
        .map { textValue1, textValue2, textValue3, textValue4 -> Int in
            return textValue1.getNumber() + textValue2.getNumber() + textValue3.getNumber() + textValue4.getNumber()
        } // 연산자를 이용하여 형태를 변환 Int 타입으로 다 더한 다음 반환
        .map{ "\($0)" } // 다시 스트링으로 변환
        .eraseToAnyPublisher()
    
    init(){
       print(#fileID, #function, #line, "- <#comment#>")
        
        resultPublisher
            .assign(to: \.resultValue, on: self)
            .store(in: &subscriptions) // 구독했을때 메모리 처리
    }
}
