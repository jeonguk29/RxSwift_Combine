//
//  UIViewController+Ext.swift
//  CombineTutorial-example
//
//  Created by Jeff Jeong on 2022/10/13.
//

import Foundation
import UIKit


// 뷰컨트롤러를 좀더 쉽게 불러오는 tip
protocol StoryBoarded {
    static func instantiate(_ storyboardName: String) -> Self
}

extension StoryBoarded where Self: UIViewController {
    // StoryBoarded 프로토콜을 준수하는 애들중에서 그 애들이 UIViewController인 애들에 대한 extension
    
    static func instantiate(_ storyboardName: String) -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! Self
        // String(describing: self) 내 자신에 대한 이름을 가져옴
    }
}

extension UIViewController : StoryBoarded {} // 위에서 정의한걸 뷰컨에 확장
