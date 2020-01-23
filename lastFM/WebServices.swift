//
//  WebServices.swift
//  lastFM
//
//  Created by Bruce Burgess on 1/22/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import Foundation
typealias webServiceCompletionHandler = (_ data: Data? ,_ response: Dictionary<String, Any>, _ error: Error?) -> Void

func postJSONToURL(urlString : String, contentBody : [String : Any?], completionHandler: @escaping webServiceCompletionHandler) {
    
    guard let url = URL(string: urlString) else { return }
    var request = URLRequest(url: url)
    
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/jsonrequest", forHTTPHeaderField: "Accept")
    request.setValue("identity", forHTTPHeaderField: "Content-Encoding")
    
    let session = URLSession.shared
    
    var jsonData = Data()
    do {
        jsonData = try JSONSerialization.data(withJSONObject: contentBody, options: .prettyPrinted)
        let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
        if decoded is  [String : String] {
            //print("decoded data: \(decoded)")
        }
    } catch {
        print(error.localizedDescription)
    }
    
    request.httpBody = jsonData
    let task = session.dataTask(with: request) { (data, response, error) in
        var dictionary : [String : Any]
        
        do{
            dictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]
        } catch let parseError {
            print("error parsing: \(parseError)")
            let responseString = String(data: data!, encoding: String.Encoding.utf8) as String?
            print("failed to parse: \(responseString!)")
            completionHandler(nil,[:],parseError)
            return
        }
        
        completionHandler(data,dictionary,error)
    }
    task.resume()
}
