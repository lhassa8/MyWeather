//
//  Daily.swift
//  MyWeather
//
//  Created by User on 5/31/16.
//  Copyright © 2016 TheSitePass. All rights reserved.
//

import Foundation

struct Daily {
    
    var day: String!
    var min: String!
    var max: String!
    
    init(day: String, min: String, max: String) {
        self.day = day
        self.min = min
        self.max = max
    }
}