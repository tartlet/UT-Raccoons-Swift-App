//
//  Post.swift
//  poostorm
//
//  Created by Jingsi Zhou on 11/27/22.
//

import Foundation
import UIKit

public class Post {
    var postID: String?
    var location: String?
    var date:String?
    var description:String?
    var postTitle:String?
    var timeStart:String?
    var timeStop:String?
    var uid:String?
    
    init (userKey: String, dict: [String: Any]) {
        guard let location1 = dict["location"] as? String,
        let date1 = dict["date"] as? String,
        let description1 = dict["description"] as? String,
        let postTitle1 = dict["postTitle"] as? String,
        let timeStart1 = dict["timeStart"] as? String,
        let timeStop1 = dict["timeStop"] as? String,
        let uid1 = dict["uid"] as? String else {return}
        self.postID = userKey
        self.location = location1
        self.description = description1
        self.date = date1
        self.postTitle = postTitle1
        self.timeStart = timeStart1
        self.timeStop = timeStop1
        self.uid = uid1
    }
}
