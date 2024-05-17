//
//  SendHandler.swift
//  Carlisle
//
//  Created by Christopher on 5/15/24.
//
//
//Chains all needed calls together in order to return AI Assistant response

import Foundation

struct SendHandler {
    
    let assistantRequests = AssistantRequests()
    
    func SendMessage(prompt: String, completion: @escaping (String?) -> Void) {
        let newMessage = Chat(role: "user", content: prompt)
        guard let threadId = retrieveThreadId() else {
            print("Creating new Thread")
            assistantRequests.CreateThread_Request { threadId, _, _ in
                if let threadId = threadId {
                    print("Created new Thread")
                    saveThreadId(threadId)
                } else {
                    print("Failed to create new Thread")
                }
                assistantRequests.SendMessage_Request(newChat: newMessage) { _, _, _ in
                    assistantRequests.RunModel_Request() { runId, _, _ in
                        if let runId = runId {
                            print(runId)
                            AssistantRequests.RunStatusChecker().checkingStatus(runId: runId) {_ in
                                assistantRequests.GetMessage_Request { returnString, _, _ in
                                    completion(returnString)
                                }
                            }
                        } else { print("Issue with Run ID") }
                    }
                }
            }
            return
        }
        assistantRequests.SendMessage_Request(newChat: newMessage) { _, _, _ in
            assistantRequests.RunModel_Request() { runId, _, _ in
                if let runId = runId {
                    AssistantRequests.RunStatusChecker().checkingStatus(runId: runId) {_ in
                        assistantRequests.GetMessage_Request { returnString, _, _ in
                            completion(returnString)
                        }
                    }
                } else { print("Issue with Run ID") }
            }
        }
    }
}
