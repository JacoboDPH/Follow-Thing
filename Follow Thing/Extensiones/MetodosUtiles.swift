//
//  MetodosUtiles.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 08/08/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import Foundation
import UIKit

func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
       let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
       label.numberOfLines = 0
       label.lineBreakMode = NSLineBreakMode.byWordWrapping
       label.font = font
       label.text = text
       label.sizeToFit()

       return label.frame.height
   }

extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

}

// USOS DEL DISPATCH
//DispatchQueue.background(delay: 3.0, background: {
//    // do something in background
//}, completion: {
//    // when background job finishes, wait 3 seconds and do something in main thread
//})
//
//DispatchQueue.background(background: {
//    // do something in background
//}, completion:{
//    // when background job finished, do something in main thread
//})
//
//DispatchQueue.background(delay: 3.0, completion:{
//    // do something in main thread after 3 seconds
//})
