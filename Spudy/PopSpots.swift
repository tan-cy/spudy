//
//  PopSpots.swift
//  Spudy
//
//  Created by Janssen Bozon on 10/16/21.
//

import UIKit

class PopSpots{
    var title = ""
        
        
        init(title:String) {
            self.title = title
        }
        
        static func FetchSpots () -> [PopSpots]{
            
            return [ PopSpots(title: "The Art of Sketching ") ,
                     PopSpots(title: " Watercolor Techniques") ,
                     PopSpots(title: "llustration Techniques ") ,
                     PopSpots(title: " Digital Illustration ")
            ]
            
        }
    }

