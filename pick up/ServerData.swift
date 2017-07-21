//
//  ServerData.swift
//  pick up
//
//  Created by KYLE C BIBLE on 5/18/17.
//  Copyright © 2017 KYLE C BIBLE. All rights reserved.
//

import Foundation

class ServerData {
    func getData(completion:  @escaping ([Dictionary<String,Any>]) -> ()){
        let url = "http://54.183.239.55  /games/"
        
        // GET request
        URLSession.shared.dataTask(with: NSURL(string: url)! as URL) { data, response, error in
            // Handle result
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options : .allowFragments) as? [Dictionary<String,Any>]
                {   completion(json)
                    //                    self.jsonObject = json
                    //                    print(jsonObject[1]["latitude"]!) // ==> ["MacBook 2015", "iPhone 6s"]
                } else {
                    print("bad json")
                }
            }
            catch let error as NSError {
                
                print(error)
            }
            }.resume()
    }
    
    
    
    func postData(tupe: (String, String, String, String), completion: @escaping ([String:Any]) -> ()){
    //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
    
    let parameters = ["sport": tupe.2, "message": tupe.3, "latitude": tupe.0, "longitude": tupe.1] as Dictionary<String, String>
    
    //create the url with URL
    let url = URL(string: "http://54.183.239.55/games/")!
    
    //create the session object
    let session = URLSession.shared
    
    //now create the URLRequest object using the url object
    var request = URLRequest(url: url)
    request.httpMethod = "POST" //set http method as POST
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        
    } catch let error {
        print(error.localizedDescription)
    }
    
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    //create dataTask using the session object to send data to the server
    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
        
        guard error == nil else {
            return
        }
        
        guard let data = data else {
            return
        }
        
        do {
            //create json object from data
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                completion(json)
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    })
    task.resume()
}
}
