//
//  ViewController.swift
//  CombineTutorial-example
//
//  Created by Jeff Jeong on 2022/10/13.
//

import UIKit
import CombineCocoa
/*
 CombineCocoa 사용시 좋은게 버튼클릭에 대한 이벤트를 퍼블리셔로 받을 수가 있음
 */
import Combine



class ViewController: UIViewController {
    
    var subscriptions = Set<AnyCancellable>()
    
    @IBOutlet weak var navToNumbersBtn: UIButton!
    
    @IBOutlet weak var navToNumbersSwiftUiBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navToNumbersBtn
            .tapPublisher
            .sink(receiveValue: {
                print(#fileID, #function, #line, "- <#comment#>")
                #warning("TODO : - numbers로 화면이동")
                let numbersVC = NumbersViewController.instantiate("Numbers") // 뷰컨이름 - 연결된 스토리보드 이름 넣어주면 됨
                self.navigationController?.pushViewController(numbersVC, animated: true)
            })
            .store(in: &subscriptions)// 해당 뷰컨이 메모리에서 사라지면 구독에 대한 찌꺼기 담는 부분임
        
        navToNumbersSwiftUiBtn // 스유뷰로 이동하는 버튼
            .tapPublisher
            .sink(receiveValue: {
                print(#fileID, #function, #line, "- <#comment#>")
                #warning("TODO : - numbers로 화면이동")
//                let numbersVC = NumbersSwiftUiViewContainerVC()
                
//                let numbersVC = SwiftUiContainerVC(swiftUiView: NumbersView())
                
//                let numbersVC = NumbersView.getContainerVC()
                
                let numbersVC = NumbersView().getContainerVC()
                
//                let myVC = MyView().getContainerVC()
//                self.navigationController?.pushViewController(myVC, animated: true)
                self.navigationController?.pushViewController(numbersVC, animated: true)
            })
            .store(in: &subscriptions)
    }


}

