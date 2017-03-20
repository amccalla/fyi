//
//  BaseRestClientService.swift
//  FYI
//
//  Created by Andrew McCalla on 12/21/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import Alamofire
import ObjectMapper

class BaseRestClientService: NSObject {
    lazy var hostUrl = Bundle.main.object(forInfoDictionaryKey: "HostUrl") as! String
    
    let defaultErrorMessage = "Unable to process your request. Please try again later."
    
    // creates GET request
    //
    func getRequest() -> DataRequest {
        return request(url(), method: .get, parameters: nil, encoding: URLEncoding.default)
    }
    
    // create POST request with given body
    //
    func postRequestFor(_ body: [String: AnyObject]?) -> DataRequest {
        return  request(url(), method: .post, parameters: body, encoding: postRequestParameterEncoding())
    }
    
    // returns url for which request should be made.
    //
    func url() -> String {
        return baseURL() + resourcePath()
    }
    
    // Must be override by sub classes
    func resourcePath() -> String {
        assertionFailure("\(#file) \(#function), ERRORMESSAGE: This method must be override by a sub-class")
        return ""
    }
    
    func postRequestParameterEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    // returns a dictionary which represents give mappable object
    //
    func jsonFormat<N: Mappable>(_ object: N) -> [String: AnyObject] {
        return Mapper().toJSON(object) as [String: AnyObject]
    }
    
    // This method parse the given server error message
    //
    func errorMessageFromResponse(_ data: Data?) -> String {
        if let responseData = data {
            do {
                if let errorDictionary = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: String] {
                    let errorMessage = errorDictionary["errorMessage"] ?? ""
                    return errorMessage
                }
            } catch {
                print("Error in parsing error message from server response.")
            }
        }
        return defaultErrorMessage
    }
    
    func phoneNumberFrom(_ data: Data?) -> String? {
        if let responseData = data {
            do {
                let errorDictionary = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: String]
                return errorDictionary?["phone-no"]
            } catch {
                // error in executing
                //
            }
        }
        return nil
    }
    
    func baseURL() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "HostUrl") as! String
    }
    
    // do the get request and try to parse the response json data and call proper closure based on request result
    //
    func retrieveJSONDataWith(_ success: @escaping (_ data: [String : AnyObject]) -> Void, failure:((_ errorMessage: String, _ data: Data?) -> Void)? ) {
        getRequest().validate().responseJSON { (response: DataResponse<Any>) in
            if response.result.isSuccess {
                if let jsonData = response.result.value as? [String : AnyObject] {
                    success(jsonData)
                } else {
                    failure?("unable to parse response", nil)
                }
            } else {
                let error = self.errorMessageFromResponse(response.data)
                failure?(error, response.data)
            }
        }
    }
    
    // Cancel any of the networks calls and completion as user is logged out
    //
    class func cancelNetworkCallIfAny() {
        let session = SessionManager().session
        if #available(iOS 9.0, *) {
            session.getAllTasks { tasks in
                tasks.forEach { $0.cancel() }
            }
        } else {
            // Fallback on earlier versions
            session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
                dataTasks.forEach { $0.cancel() }
                uploadTasks.forEach { $0.cancel() }
                downloadTasks.forEach { $0.cancel() }
            }
        }
    }
}
