//
//  ShareImageOnline.swift
//  Meme Generator
//
//  Created by 林煜凱 on 11/1/21.
//

import Foundation
import Alamofire
//upload image to imgur
struct ImgurResponseResult: Codable {
    var data: ImgurData
    var status: Int
}

struct ImgurData: Codable {
    let link: String
}


func uploadImage(data: Data, completion: @escaping (String?, Error?)-> Void) {
    let headers: HTTPHeaders = [
        "Authorization": "Client-ID 823063d2a8e21a7",
    ]
    
    AF.upload(multipartFormData: { multipartFormData in
        multipartFormData.append(data, withName: "image")
    }, to: "https://api.imgur.com/3/image", method: .post, headers: headers)
        .responseDecodable(of: ImgurResponseResult.self) { response in
            
            switch response.result {
            case .success(let result):
                //print(result.status)
                //print(result.data.link)
                completion(result.data.link, nil)
            case .failure(let error):
                //print(error)
                completion(nil, error)
            }
            
       
        }}

