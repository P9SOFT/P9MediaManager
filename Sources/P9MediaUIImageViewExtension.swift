//
//  P9MediaUIImageViewExtension.swift
//
//
//  Created by Tae Hyun Na on 2017. 11. 11.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

@objc extension UIImageView {
    
    /*!
     @property p9MediaView
     @abstract Get P9MediaView
     */
    var p9MediaView:P9MediaView {
        get {
            for subview in subviews {
                if let playView = subview as? P9MediaView, playView.tag == 20140101 {
                    return playView
                }
            }
            let playView = P9MediaView(frame: self.bounds)
            playView.tag = 20140101
            playView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            playView.releasePlayerWhenImOut = true
            self.addSubview(playView)
            return playView
        }
    }
    
    /*!
     @method p9MediaPlayResourceUrl:mute:loop:autoPlayWhenReady:rewindIfPlaying:
     @abstract Play given media resource.
     @param resourceUrl Url of your resource.
     @param mute If you want to play mute then set it.
     @param loop If you want to play loop then set it.
     @param autoPlayWhenReadyFlag If you want to auto play when given resource ready then set it.
     @param rewindIfPlaying If you want to play rewind then set it.
     */
    func p9MediaPlay(resourceUrl:URL, mute:Bool, loop:Bool, autoPlayWhenReady:Bool, rewindIfPlaying:Bool) {
        
        P9MediaManager.shared.setPlayer(resourceUrl: resourceUrl, forKey: p9MediaView.suggestedKey)
        if P9MediaManager.shared.isPlacedPlayer(forKey: p9MediaView.suggestedKey) == false {
            P9MediaManager.shared.placePlayer(forKey: p9MediaView.suggestedKey, toView: p9MediaView, mute: mute, loop: loop, autoPlayWhenReadyFlag: autoPlayWhenReady)
        } else {
            if rewindIfPlaying == true {
                P9MediaManager.shared.setSeekTimeOfPlayer(rate: 0, forKey: p9MediaView.suggestedKey)
            }
            P9MediaManager.shared.playPlayer(forKey: p9MediaView.suggestedKey)
        }
    }
    
    /*!
     @method p9MediaPause
     @abstract Pause player
     */
    func p9MediaPause() {
        
        P9MediaManager.shared.pausePlayer(forKey: p9MediaView.suggestedKey)
    }
    
    /*!
     @method p9MediaResume
     @abstract Resume player
     */
    func p9MediaResume() {
        
        P9MediaManager.shared.playPlayer(forKey: p9MediaView.suggestedKey)
    }
    
    /*!
     @method p9MediaClear
     @abstract Clear P9MediaView resource
     */
    func p9MediaClear() {
        
        for subview in subviews {
            if let playView = subview as? P9MediaView, playView.tag == 20140101 {
                P9MediaManager.shared.displacePlayer(forKey: playView.suggestedKey)
                P9MediaManager.shared.releasePlayer(forKey: playView.suggestedKey)
                playView.removeFromSuperview()
                break
            }
        }
    }
}
