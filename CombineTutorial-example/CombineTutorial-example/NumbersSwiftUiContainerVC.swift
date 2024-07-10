//
//  NumbersSwiftUiContainerVC.swift
//  CombineTutorial-example
//
//  Created by Jeff Jeong on 2022/10/14.
//

import Foundation
import UIKit
import SwiftUI


// 💁 SwiftUI View를 UIKit에 적용하는 방법
class SwiftUiContainerVC<SwiftUiView: View> : UIViewController {
    
    let swiftUiView : SwiftUiView
    
    init(swiftUiView: SwiftUiView){ // 생성시 스유뷰 받기
        self.swiftUiView = swiftUiView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.configureHostingVC()
    }
    
    fileprivate func configureHostingVC() {
        let hostingVC = UIHostingController(rootView: swiftUiView)
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addChild(hostingVC)
        self.view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
        NSLayoutConstraint.activate([
            hostingVC.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            hostingVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
}

// 이런걸 hosting컨트롤러 라고 말함
/*
 아래 처럼 사용시 뷰컨에서는 이렇게 사용함
 
 navToNumbersSwiftUiBtn // 스유뷰로 이동하는 버튼
     .tapPublisher
     .sink(receiveValue: {
         print(#fileID, #function, #line, "- <#comment#>")
         #warning("TODO : - numbers로 화면이동")
         let numbersVC = NumbersSwiftUiViewContainerVC()
         self.navigationController?.pushViewController(numbersVC, animated: true)
     })
     .store(in: &subscriptions)
 
단점 아래 NumbersView()를 계속 바꿔서 사용해야함
그래서 제네릭을 활용하여 위처럼 구현
 
 */
class NumbersSwiftUiViewContainerVC : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.configureHostingVC()
    }
    
    fileprivate func configureHostingVC() {
        let hostingVC = UIHostingController(rootView: NumbersView()) // SwiftUI View를 UIKit에서 관리 할 수 있게 해주는 애임
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addChild(hostingVC) // 자식 뷰로 넣어 오토레이아웃 설정
        self.view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self) // hostingVC가 내 부모로 이동이 되었다. 알려주는것 나자신에게
        NSLayoutConstraint.activate([
            hostingVC.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            hostingVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
}

/*
 UIKit이 메모리 참조 방식을 사용해서 View를 만들었다면
 SwiftUI는 struct를 사용하여 View를 재생성함
 */
struct MyView : View {
    
    @State var input : String = ""
    
    var body: some View {
        VStack(alignment: .trailing){
            
            Text("MyView")
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.purple)
    }
    
//    static func getContainerVC() -> UIViewController {
//        return SwiftUiContainerVC(swiftUiView: Self())
//    }
}

struct NumbersView : View {
    
    @State var input : String = ""
    
    var body: some View {
        VStack(alignment: .trailing){
            
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Divider()
            
            Text("합계")
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.yellow)
    }
    
//    static func getContainerVC() -> UIViewController {
//        return SwiftUiContainerVC(swiftUiView: Self())
//    }
}

extension View {
    func getContainerVC() -> UIViewController {
        return SwiftUiContainerVC(swiftUiView: self)
    }
}

struct NumbersView_Previews: PreviewProvider {
    static var previews: some View {
        NumbersView()
    }
}
