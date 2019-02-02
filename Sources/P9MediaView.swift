//
//  P9MediaView.swift
//
//
//  Created by Tae Hyun Na on 2017. 10. 3.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit
import AVFoundation

/*!
 @class P9MediaView
 @abstract View module based on P9MediaView.
 */
class P9MediaView: UIView {
    
    /*!
     @property suggestedTagIdForSinglePlay
     @abstract It'll use for tag value of view to check be single on some other's subview.
     */
    @objc static let suggestedTagIdForSinglePlay:Int = 20140101
    
    /*!
     @property suggestedKey
     @abstract suggested player key for this view
     */
    @objc var suggestedKey:String = UUID().uuidString
    
    /*!
     @property releasePlayerWhenImOut
     @abstract if you want to release player for suggestedMyPlayerKey when view releasing then set this.
     */
    @objc var releasePlayerWhenImOut:Bool = false
    
    /*!
     @method deinit
     */
    deinit {
        if releasePlayerWhenImOut == true {
            P9MediaManager.shared.releasePlayer(forKey: suggestedKey)
        }
    }
    
    /*!
     @property layerClass
     @abstract Override property for change layer class to AVPlayerLayer
     */
    override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
}
