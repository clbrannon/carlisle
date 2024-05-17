//
//  ResponseModels.swift
//  Carlisle
//
//  Created by Christopher on 5/13/24.
//

import Foundation

struct Chat: Codable {
    var role: String
    var content: String
}

struct Usage: Codable {
    var prompt_tokens: Int64
    var completion_tokens: Int64
    var total_tokens: Int64
}

struct Thread: Codable {
    let id, object: String
    let created_at: Int64
    let metadata: [String : String?]?
    let tool_resources: ToolResources?
}

struct ThreadDeletionStatus: Codable {
    let id, object: String
    let deleted: Bool
}

struct Message: Codable {
    let id: String
    let object: String
    let created_at: Int64
    let assistant_id: String?
    let thread_id: String
    let run_id: String?
    let role: String
    let content: [Content]
    let attachments: [String]?
    let metadata: [String : String?]?
}

struct ListMessages: Codable {
    let object: String?
    let data: [Message]
}

struct Content: Codable {
    let type: String
    let text: Text
}

struct Text: Codable {
    let value: String
    let annotations: [String]?
}

struct Attachments: Codable {
    let file_id: String
    let tools: [String]
}
struct Tools: Codable {
    let type: String
}

struct Run: Codable {
    let id: String?
    let object: String
    let created_at: Int64
    let assistant_id, thread_id, status: String
    let started_at, expires_at, cancelled_at, failed_at, completed_at: Int64?
    let last_error: String?
    let model: String?
    let instructions, incomplete_details: String?
    let tool_resources: ToolResources?
    let tools: [Tools?]?
    let metadata: [String: String?]?
    let usage: Usage?
    let temperature, top_p: Double?
    let max_prompt_tokens, max_completion_tokens: Int64?
    let truncation_strategy: TruncationStrategy?
    let response_format, tool_choice: String?
}

struct TruncationStrategy: Codable {
    let type: String?
    let last_messages: String?
}

struct ToolResources: Codable {
    let code_interpreter: CodeInterpreter?
    let file_search: FileSearch?
}

struct FileSearch: Codable {
    let file_ids: [String]
}

struct CodeInterpreter: Codable {
    let file_ids: [String]
}

struct RunData: Codable {
    let assistant_id: String
    let instructions: String?
}

struct ErrorRunResponse: Codable {
    let error: openAiError?
}

struct openAiError: Codable {
    let message: String?
    let type: String?
    let param: String?
    let code: String?
}
