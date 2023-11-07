//
//  TabController.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 6/10/23.
//

import UIKit

class TabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.unselectedItemTintColor = UIColor { $0.userInterfaceStyle == .dark ? .systemGray5 : .systemGray2 }
        self.tabBar.backgroundColor = UIColor(named: "ColorSet")
        

        //boton logout
        let outButton = UIBarButtonItem()
        outButton.image = UIImage(systemName: "square.and.arrow.up")?.rotate(radians: .pi / 2.0)
        outButton.target = self
        outButton.action = #selector(logOut)
        
        navigationItem.rightBarButtonItem = outButton
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    
    @objc func logOut() {
        let sb = self.storyboard
        self.present(sb!.instantiateViewController(withIdentifier: "loginID"), animated: true)
    }


}


extension UIImage {
    func rotate(radians: CGFloat) -> UIImage? {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.x, y: -origin.y,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return rotatedImage
        }
        return nil
    }
}
