//
//  Comment.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

class Comment: FirebaseConvertible, Equatable {
    
    static private let textKey = "text"
    static private let audioURLKey = "audioURL"
    static private let author = "author"
    static private let timestampKey = "timestamp"
    
    let text: String?
    let audioURL: String?
    let author: Author
    let timestamp: Date
    
    init(text: String?, audioURL: String?, author: Author, timestamp: Date = Date()) {
        self.text = text
        self.audioURL = audioURL
        self.author = author
        self.timestamp = timestamp
    }
    
    init?(dictionary: [String : Any]) {
        guard let authorDictionary = dictionary[Comment.author] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval else { return nil }
        
        var isText = false
        if let text = dictionary[Comment.textKey] as? String, !text.isEmpty {
            isText = true
        }
        
        switch isText {
        case true:
            guard let text = dictionary[Comment.textKey] as? String, !text.isEmpty else { return nil }
            self.text = text
            self.audioURL = nil
        case false:
            guard let audioURL = dictionary[Comment.audioURLKey] as? String, !audioURL.isEmpty else { return nil }
            self.text = nil
            self.audioURL = audioURL
        }
        
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
    }
    
    var dictionaryRepresentation: [String: Any] {
        return [Comment.textKey: text ?? "",
                Comment.audioURLKey: audioURL ?? "",
                Comment.author: author.dictionaryRepresentation,
                Comment.timestampKey: timestamp.timeIntervalSince1970]
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.author == rhs.author &&
            lhs.timestamp == rhs.timestamp
    }
}
