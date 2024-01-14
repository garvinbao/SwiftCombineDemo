//
//  ViewController.swift
//  SwiftCombineDemo
//
//  Created by garvin on 2024/1/13.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var sendVerifyCode: UIButton!
    @IBOutlet weak var inputVerifyCode: UITextField!
    @IBOutlet weak var agree: UISwitch!
    @IBOutlet weak var toLogin: UIButton!
    
    @Published var phone: String? = ""
    @Published var verifyCode: String? = ""
    @Published var isAgree: Bool = false
    
    // 校验手机号的发布者
    var phoneValid: AnyPublisher<Bool, Never> {
        $phone
            // 这里简单判断手机号长度
            .map { $0?.count == 11 ? true : false }
            .eraseToAnyPublisher()
    }
    
    // 校验验证码的发布者
    var verifyCodeValid: AnyPublisher<Bool, Never> {
        $verifyCode
            .map { code in
                guard                   // 验证码校验逻辑（实际情况按照需求自定义）
                    let code = code,    // 值不能为nil
                    code.count == 4,    // 长度为4
                    let _ = Int(code)   // 能转为Int
                else { return false }   // 以上三种全部满足返回true，否则返回false
                
                return true
            }
            .eraseToAnyPublisher()      // 抹去类型转为AnyPublisher
    }
    
    var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        backgroundView.setGradientColor()
        
        phoneValid
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: sendVerifyCode)
            .store(in: &subscriptions)
        
        // 融合三个发布者
        Publishers.CombineLatest3(phoneValid, verifyCodeValid, $isAgree)
            .map { $0 && $1 && $2 }                 // 筛选逻辑
            .receive(on: RunLoop.main)              // 在主线程接受
            .assign(to: \.isEnabled, on: toLogin)   // 结果分配
            .store(in: &subscriptions)              // 返回值Cancellable对象储存在全局容器中
    }
    
    @IBAction func sendVerifyCodeAction(_ sender: UIButton) {
        self.alert(message: "手机号校验通过，验证码已发送至\(phoneNumber.text!)，请注意查收！")
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        self.alert(message: "开始进行登录操作！")
    }
    
    @IBAction func phoneChanged(_ sender: UITextField) { phone = sender.text }
    @IBAction func verifyCodeChanged(_ sender: UITextField) { verifyCode = sender.text }
    @IBAction func agreeChanged(_ sender: UISwitch) { isAgree = sender.isOn }
    
    func alert(message: String) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "确认", style: .cancel))
        self.present(alertController, animated: true)
    }
}


extension UIView {
    // RGB Color: 184 220 200 -> 53 110 136
    func setGradientColor (colors: [CGColor] = [UIColor(red: 184/255.0, green: 220/255.0, blue: 200/255.0, alpha: 1.0).cgColor, UIColor(red: 53/255.0, green: 110/255.0, blue: 136/255.0, alpha: 1.0).cgColor]) {
        let layer = CAGradientLayer()
        layer.colors = colors
        layer.frame = UIScreen.main.bounds
        layer.startPoint = CGPoint(x: 0, y: 0.0)
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)
        self.layer.addSublayer(layer)
    }
}


