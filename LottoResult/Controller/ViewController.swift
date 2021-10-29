//
//  ViewController.swift
//  LottoResult
//
//  Created by 박연배 on 2021/10/26.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    
    //MARK: Property
    
    var upToDate = UserDefaults.standard.integer(forKey: "latest")
    
    var lottoData: LottoModel? {
        didSet {
            settingLayout()
        }
    }
    
    var lottoDrawRange = Array<Int>()
    
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH"
        df.locale = Locale(identifier: "ko-KR")
        df.timeZone = TimeZone(identifier: "KST")
        
        return df
    }()
    
    
    @IBOutlet weak var lottoTextField: UITextField!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var countsLabel: UILabel!
    
    @IBOutlet weak var firstPrizeNumber: UILabel!
    @IBOutlet weak var firstNumberView: UIView!
    
    @IBOutlet weak var secondPrizeNumber: UILabel!
    @IBOutlet weak var secondNumberView: UIView!
    
    @IBOutlet weak var thirdPrizeNumber: UILabel!
    @IBOutlet weak var thirdNumberView: UIView!
    
    @IBOutlet weak var fourthPrizeNumber: UILabel!
    @IBOutlet weak var fourthNumberView: UIView!
    
    @IBOutlet weak var fifthPrizeNumber: UILabel!
    @IBOutlet weak var fifthNumberView: UIView!
    
    @IBOutlet weak var sixthPrizeNumber: UILabel!
    @IBOutlet weak var sixthNumberView: UIView!
    
    @IBOutlet weak var bonusPrizeNumber: UILabel!
    @IBOutlet weak var bonusNumberView: UIView!
    
    @IBOutlet weak var numbersStack: UIStackView!
    
    //MARK: Method
    
    func makePickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        self.lottoTextField.inputView = pickerView
    }
    
    func makeAlert(title: String?, message: String?, buttonTitle1: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: buttonTitle1, style: .default)
        
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }

    
    func calculateDate() {
        let todayString = dateFormatter.string(from: Date())
        guard let today = dateFormatter.date(from: todayString)?.addingTimeInterval(3600 * 9) else {
            return
        }
        
        
        print(recentSaturday)
        
        
    }
    
    func textFieldConfig() {
        self.lottoTextField.keyboardType = .numberPad
        self.lottoTextField.autocorrectionType = .no
        self.lottoTextField.autocapitalizationType = .none
    }
    
    func fetchLottoData() {
        var text = lottoTextField.text!
        
        if text.isEmpty {
            text = "900"
        }
        
        LottoAPIManager.shared.fetchLottoData(count: text) { json in
            print(json)
            self.lottoData = LottoModel(drwtNo1: json["drwtNo1"].intValue,
                                        drwtNo2: json["drwtNo2"].intValue,
                                        drwtNo3: json["drwtNo3"].intValue,
                                        drwtNo4: json["drwtNo4"].intValue,
                                        drwtNo5: json["drwtNo5"].intValue,
                                        drwtNo6: json["drwtNo6"].intValue,
                                        bnusNo: json["bnusNo"].intValue,
                                        drwNoDate: json["drwNoDate"].stringValue,
                                        drwNo: json["drwNo"].intValue)
        }
        
    }
    
    func settingLayout() {
        guard let data = self.lottoData else {
            return
        }
        
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowRadius = 5
        headerView.layer.shadowOffset = .zero
        headerView.layer.shadowPath = UIBezierPath(rect: headerView.bounds).cgPath
        headerView.layer.shadowOpacity = 0.5
        headerView.layer.cornerRadius = 10
        
        settingBall(label: firstPrizeNumber, ball: firstNumberView, num: data.drwtNo1)
        settingBall(label: secondPrizeNumber, ball: secondNumberView, num: data.drwtNo2)
        settingBall(label: thirdPrizeNumber, ball: thirdNumberView, num: data.drwtNo3)
        settingBall(label: fourthPrizeNumber, ball: fourthNumberView, num: data.drwtNo4)
        settingBall(label: fifthPrizeNumber, ball: fifthNumberView, num: data.drwtNo5)
        settingBall(label: sixthPrizeNumber, ball: sixthNumberView, num: data.drwtNo6)
        settingBall(label: bonusPrizeNumber, ball: bonusNumberView, num: data.bnusNo)
        
        self.countsLabel.text = String(data.drwNo) + "회"
        self.dateLabel.text = data.drwNoDate + " 추첨"
    }
    
    func settingBall(label: UILabel, ball: UIView, num: Int) {
        let width = ball.frame.size.width / 2
        
        label.textColor = .white
        label.text = String(num)
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        ball.backgroundColor = pickBallColor(num: num)
        ball.layer.cornerRadius = width
    }
    
    func pickBallColor(num: Int) -> UIColor {
        switch num {
        case 1..<10:
            return UIColor.orange
        case 10..<20:
            return UIColor.systemTeal
        case 20..<30:
            return UIColor.systemPink
        case 30..<45:
            return UIColor.purple
        default:
            return UIColor.darkGray
        }
    }
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLottoData()
        textFieldConfig()
        self.lottoTextField.delegate = self
        calculateDate()
        self.lottoDrawRange = Array<Int>(1...100).reversed()
        
        let gesture = UITapGestureRecognizer()
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
        
    }


}


extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text!.isEmpty {
            makeAlert(title: "오류", message: "조회할 회차를 입력해주세요.", buttonTitle1: "확인")
            return false
        } else if Int(textField.text!) == nil {
            makeAlert(title: "오류", message: "숫자만 입력할 수 있습니다.", buttonTitle1: "확인")
        }
        
        fetchLottoData()
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.makePickerView()
        return true
    }
    
    
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return lottoDrawRange.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(lottoDrawRange[row]) + "회"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(lottoDrawRange[row])
        self.lottoTextField.text = String(lottoDrawRange[row])
        fetchLottoData()
    }
    
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != self.lottoTextField {
            self.lottoTextField.endEditing(true)
            
            return true
        }
        return false
    }
}
