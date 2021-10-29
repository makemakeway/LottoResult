//
//  LottoAPIManager.swift
//  LottoResult
//
//  Created by 박연배 on 2021/10/29.
//

import Foundation
import SwiftyJSON
import Alamofire


class LottoAPIManager {
    static let shared = LottoAPIManager()
    
    private init() { }
    
    func fetchLottoData(count:String, result: @escaping (JSON) -> ()) {
        let url = "https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=\(count)"
        
        AF.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                result(json)
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
