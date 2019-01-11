//
//  MediaTableViewCell.swift
//  Sample
//
//  Created by Tae Hyun Na on 2019. 1. 4.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

class MediaTableViewCell: UITableViewCell {
    
    static let defaultIdentifier = "MediaTableViewCell"
    static let defaultHeight:CGFloat = 60
    
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var haveVideoTrackLabel: UILabel!
    @IBOutlet weak var haveAudioTrackLabel: UILabel!
    @IBOutlet weak var haveSubtitleTrackLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var url:URL? {
        didSet {
            if let url = url {
                var haveVideoTrack = false
                var haveAudioTrack = false
                var haveSubtitleTrack = false
                if let trackInfo = P9MediaManager.shared.trackInfoOfPlayer(forKey: mediaImageView.p9MediaView.suggestedKey) {
                    haveVideoTrack = trackInfo[P9MediaManager.NotificationHaveVideoTrack] as? Bool ?? false
                    haveAudioTrack = trackInfo[P9MediaManager.NotificationHaveAudioTrack] as? Bool ?? false
                    haveSubtitleTrack = trackInfo[P9MediaManager.NotificationHaveSubtitleTrack] as? Bool ?? false
                }
                haveVideoTrackLabel.textColor = haveVideoTrack ? .black : .lightGray
                haveVideoTrackLabel.layer.borderColor = haveVideoTrackLabel.textColor.cgColor
                haveAudioTrackLabel.textColor = haveAudioTrack ? .black : .lightGray
                haveAudioTrackLabel.layer.borderColor = haveAudioTrackLabel.textColor.cgColor
                haveSubtitleTrackLabel.textColor = haveSubtitleTrack ? .black : .lightGray
                haveSubtitleTrackLabel.layer.borderColor = haveSubtitleTrackLabel.textColor.cgColor
                titleLabel.text = url.lastPathComponent
                mediaImageView.p9MediaPlay(resourceUrl: url, mute: true, loop: true, autoPlayWhenReady: true, rewindIfPlaying: false)
            } else {
                titleLabel.text = "--"
                mediaImageView.p9MediaPause()
            }
        }
    }
    
    func pause() {
        
        mediaImageView.p9MediaPause()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        haveVideoTrackLabel.layer.borderWidth = 1
        haveAudioTrackLabel.layer.borderWidth = 1
        haveSubtitleTrackLabel.layer.borderWidth = 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.p9MediaManagerNotificationHandler(notification:)), name: .P9MediaManager, object: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func p9MediaManagerNotificationHandler(notification:Notification) {
        
        guard let userInfo = notification.userInfo, let key = userInfo[P9MediaManager.NotificationPlayerKey] as? String, let event = userInfo[P9MediaManager.NotificationEvent] as? P9MediaManager.Event, key == mediaImageView.p9MediaView.suggestedKey else {
            return
        }
        
        switch event {
        case .standbyAlready:
            mediaImageView.p9MediaResume()
        case .place, .placeAgain, .placeAlready:
            timeLabel.text = "place."
        case .fail:
            timeLabel.text = "fail."
        case .readyToPlay:
            let amountSeconds = userInfo[P9MediaManager.NotificationAmountSeconds] as? Int64 ?? 0
            let amountTime = String(format: "%02d:%02d:%02d", (amountSeconds/3600), (amountSeconds/60)%60, amountSeconds%60)
            timeLabel.text = "ready to play with amount time : \(amountTime)"
            haveVideoTrackLabel.textColor = (userInfo[P9MediaManager.NotificationHaveVideoTrack] as? Bool ?? false) ? .black : .lightGray
            haveVideoTrackLabel.layer.borderColor = haveVideoTrackLabel.textColor.cgColor
            haveAudioTrackLabel.textColor = (userInfo[P9MediaManager.NotificationHaveAudioTrack] as? Bool ?? false) ? .black : .lightGray
            haveAudioTrackLabel.layer.borderColor = haveAudioTrackLabel.textColor.cgColor
            haveSubtitleTrackLabel.textColor = (userInfo[P9MediaManager.NotificationHaveSubtitleTrack] as? Bool ?? false) ? .black : .lightGray
            haveSubtitleTrackLabel.layer.borderColor = haveSubtitleTrackLabel.textColor.cgColor
        case .playing:
            let currentSeconds = userInfo[P9MediaManager.NotificationCurrentSeconds] as? Int64 ?? 0
            let currentTime = String(format: "%02d:%02d:%02d", (currentSeconds/3600), (currentSeconds/60)%60, currentSeconds%60)
            let amountSeconds = userInfo[P9MediaManager.NotificationAmountSeconds] as? Int64 ?? 0
            if amountSeconds > 0 {
                let amountTime = String(format: "%02d:%02d:%02d", (amountSeconds/3600), (amountSeconds/60)%60, amountSeconds%60)
                timeLabel.text = "\(currentTime) / \(amountTime)"
            } else {
                timeLabel.text = "\(currentTime)"
            }
        case .playToEnd, .playToEndAndWillRewind:
            timeLabel.text = "done."
        default:
            break
        }
    }
}
