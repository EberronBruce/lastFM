//
//  WebServices.swift
//  lastFM
//
//  Created by Bruce Burgess on 1/22/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import Foundation

/*
 This file is used to have a template is make the API calls easier to read.
 */

typealias webServiceCompletionHandler = (_ data: Data? ,_ response: Dictionary<String, Any>, _ error: Error?) -> Void
typealias webDataCompletionHandler = (_ data:Data?, _ error: Error?) -> Void

func postJSONToURL(urlString : String, contentBody : [String : Any?], completionHandler: @escaping webServiceCompletionHandler) {
    
    guard let url = URL(string: urlString) else { return }
    var request = URLRequest(url: url)
    
    request.httpMethod = WEB_POST
    request.setValue(WEB_APPLICATION_JSON, forHTTPHeaderField: WEB_CONTENT_TYPE)
    request.setValue(WEB_APPLICATION_JSON_REQUEST, forHTTPHeaderField: WEB_ACCEPT)
    request.setValue(WEB_IDENTITY, forHTTPHeaderField: WEB_CONTENT_ENCODING)
    
    let session = URLSession.shared
    
    var jsonData = Data()
    do {
        jsonData = try JSONSerialization.data(withJSONObject: contentBody, options: .prettyPrinted)
    } catch {
        print(error.localizedDescription)
    }
    
    request.httpBody = jsonData
    let task = session.dataTask(with: request) { (data, response, error) in
        var dictionary : [String : Any]
        
        do{
            dictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]
        } catch let parseError {
            print("\(WEB_ERROR_PARSING)\(parseError)")
            let responseString = String(data: data!, encoding: String.Encoding.utf8) as String?
            print("\(WEB_FAILED_TO_PARSE)\(responseString!)")
            completionHandler(nil,[:],parseError)
            return
        }
        
        completionHandler(data,dictionary,error)
    }
    task.resume()
}


func getDataFromURL(urlString: String, completion: @escaping webDataCompletionHandler) {
    if let url = URL(string: urlString) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? WEB_ERROR_UNKNOWN)
                completion(nil, error!)
                return
            }
            DispatchQueue.main.async {
                if data != nil {
                    completion(data!, nil)
                } else {
                    print("\(WEB_GET_DATA_FROM)\(urlString)\(WEB_RETURN_NIL)")
                    completion(nil, nil)
                }
            }
            
        }.resume()
    }
    
}
