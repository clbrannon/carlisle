//
//  APICall_New.swift
//  Carlisle
//
//  Created by Christopher on 5/13/24.
//
// All required calls needed to communicate with OpenAI Assistant through API endpoints.
//
// -Need to segregate handler logic into seperate handler file.

import Foundation

struct AssistantRequests {
    
    let asstId: String
    let baseUrl: String
    var request: URLRequest
    var headers: [String: String]
    var body: [String: String]?
    let getParameters: [String: String]
    
    init() {
        
        asstId = AssistantInfo.id
        baseUrl = AssistantInfo.baseURL
        headers = AssistantInfo.headers
        getParameters = AssistantInfo.getMessageParameters
        
        guard let url = URL(string: "https://nothing.com") else {fatalError("Invalid dummy URL")}
        request = URLRequest(url: url)
        
    }
    
    func CreateThread_Request(completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        
        let appendedUrl: String = baseUrl + "/threads"
        var request = request
        
        guard let url = URL(string: appendedUrl) else {return}
        
        request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        print("Sending Request for new Thread")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                print("Error retrieving new Thread ID: \(error)")
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                
                let jsonObject = try decoder.decode(Thread.self, from: data )
                print(jsonObject)
                
                let threadId = jsonObject.id
                print("Thread Recieved:\(threadId)")
                
                completion(threadId, response, error)
                
            } catch {
                print(error)
            }
        }
        
        task.resume()
    }
    
    func SendMessage_Request(newChat: Chat?, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        print("Sending Message to Thread")
        
        var appendedUrl: String = ""
        
        if let thread_id = retrieveThreadId() {
            
            appendedUrl = baseUrl + "/threads/\(thread_id)/messages"
            
        } else{}
        var request = request
        
        guard let url = URL(string: appendedUrl) else {return}
        
        request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let newChat = newChat {
            
            saveChats(newChat)
            
            do {
                request.httpBody = try JSONEncoder().encode(newChat)
                print("Adding Chat to Request: \(newChat)")
                
                
            } catch let error {
                print(error.localizedDescription)
                
            }
            
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                print("Message failed to Send: \(error)")
                return
            }
            
            print("Message succesffully sent")
            
            do {
                
                let decoder = JSONDecoder()
                
                let jsonObject = try decoder.decode(Message.self, from: data )
                
                completion(data, response, error)
                
            } catch {
                print(error)
            }

        }
        
        task.resume()
    }
    
    func GetMessage_Request( completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        
        print("Getting Response")
        
        var appendedUrl: String = ""
        
        if let thread_id = retrieveThreadId() {
            
            appendedUrl = baseUrl + "/threads/\(thread_id)/messages"
            
        } else{}
        
        var request = request
        
        guard let url = URL(string: appendedUrl) else {return}
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            urlComponents.queryItems = getParameters.map { URLQueryItem(name: $0, value: $1) }
            
            request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            guard let parameters = try? JSONSerialization.data(withJSONObject: getParameters) else {
                fatalError("Failed to encode parameters")
            }
            
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                guard
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    error == nil
                else {
                    print(error)
                    return
                }
                do {
                    
                    let decoder = JSONDecoder()
                    
                    let jsonObject = try decoder.decode(ListMessages.self, from: data )
                    
                    if let lastMessageReceived = jsonObject.data.first?.content.last?.text.value {
                        
                        completion(lastMessageReceived, response, error)
                    } else {
                        completion(nil, response, error)
                    }
                    
                    if let jsonData = try? JSONEncoder().encode(jsonObject),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        print("All messages: \(jsonString)")
                    } else {
                        print("Failed to convert JSON data to string")
                    }
                    
                } catch {
                    print(error)
                    completion(nil, response, error)
                }
            }
            task.resume()
        }
    }
    
    func RunModel_Request( completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        
        print("Sending Run Request")
        
        let asstId = asstId
        let runData = RunData(assistant_id: asstId, instructions: nil)
        
        var appendedUrl: String = ""
        
        var request = request
        
        if let thread_id = retrieveThreadId() {
            appendedUrl = baseUrl + "/threads/\(thread_id)/runs"
            
        } else{}
        
        guard let url = URL(string: appendedUrl) else {return}
        
        request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(runData)
        } catch let error {
            print(error.localizedDescription)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            print("Run Request Sent")
            
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
                    
            else {
                print("Run failed: \(error)")
                return
            }
            do {
                
                let decoder = JSONDecoder()
                
                let jsonObject = try decoder.decode(Run.self, from: data )
                
                if let idReturned = jsonObject.id {
                    completion(idReturned, response, error)
                } else {
                    completion(nil, response, error)
                }
                
            } catch {
                print(error)
                completion(nil, response, error)
            }
            
        }
        
        task.resume()
    }
    
    class RunStatusChecker {
        
        var timer: Timer?
        let baseUrl: String
        var request: URLRequest
        var checkRunHeaders: [String: String]
        
        
        init() {
            
            baseUrl = AssistantInfo.baseURL
            checkRunHeaders = AssistantInfo.checkRunHeaders
            
            guard let url = URL(string: "https://nothing.com") else {fatalError("Invalid dummy URL")}
            request = URLRequest(url: url)
            
        }
        
        func checkingStatus(runId: String, completion: @escaping (Bool) -> Void) {
            
            checkRunStatus(runId: runId) { isComplete in
                if isComplete {
                    // If the condition is met, call the completion handler
                    completion(true)
                } else {
                    // If the condition is not met, recursively call the function again immediately
                    self.checkingStatus(runId: runId, completion: completion)
                }
            }
        }
        
        func stopCheckingStatus() {
            print("Run complete")
            timer?.invalidate()
            timer = nil
        }
        
        func checkRunStatus(runId: String, completion: @escaping (Bool) -> Void) {
            
            print("Checking Run Status")
            
            var appendedUrl: String = ""
            
            var request = request
            
            if let thread_id = retrieveThreadId() {
                appendedUrl = baseUrl + "/threads/\(thread_id)/runs/\(runId)"
                
            } else{}
            
            guard let url = URL(string: appendedUrl) else {return}
            
            request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.httpBody = nil
            
            for (key, value) in checkRunHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            // Perform the URLRequest to retrieve the Run object
            URLSession.shared.dataTask(with: request) { data, response, error in
                // Check for errors
                guard let data = data,
                      error == nil else {
                    print("Error retrieving Run object: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                // Decode the JSON data into a Run object
                do {
                    
                    let jsonObject = try JSONDecoder().decode(Run.self, from: data)
                    
                    print(jsonObject.status)
                    
                    if jsonObject.status == "completed" {
                        
                        print("Run is complete")
                        
                        self.stopCheckingStatus()
                        
                        completion(true)
                        
                    } else {print("Run not completed")
                        
                        completion(false)}
                } catch {
                    
                    print("Error decoding Run object: \(error.localizedDescription)")
                    
                    print(String(data: data, encoding: .utf8))
                    
                    let errorJsonObject = try? JSONDecoder().decode(ErrorRunResponse.self, from: data)
                    
                    // Polling Run object appears to have a bug. Call incorrectly thinks I'm attempting to alter run
                    
                    if let errorJsonObject = errorJsonObject {
                        if let errorMessage = errorJsonObject.error?.message {
                            if errorMessage == "Cannot update run with status 'in_progress'." || errorMessage == "Cannot update run with status 'queued'." {
                                completion(false)

                            }
                        }
                    } else {print("Error Understanding response")}
                }
                
            }
            .resume()
        }
    }
}
