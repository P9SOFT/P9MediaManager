//
//  P9MediaManager.swift
//
//
//  Created by Tae Hyun Na on 2017. 10. 3.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit
import AVFoundation

/*!
 @abstract Notification name of P9MediaManager.
 */
extension Notification.Name {
    static let P9MediaManager = Notification.Name("P9MediaManagerNotification")
}
@objc extension NSNotification {
    public static let P9MediaManager = Notification.Name.P9MediaManager
}

/*!
 @class P9MediaManager
 @abstract Helper module to handling Media resource.
 */
class P9MediaManager: NSObject {
    
    /*!
     @abstract Available key list in Notification.userInfo from P9MediaManager's notification.
     @constant NotificationPlayerKey Key of player that you given by String.
     @constant NotificationEvent Event information by listed 'P9MediaManager.Event' by enum(Int).
     @constant NotificationResourceUrlString Resource url string by String.
     @constant NotificationHaveVideoTrack Flag of having video track or not by Bool.
     @constant NotificationHaveAudioTrack Flag of having audio track or not by Bool.
     @constant NotificationHaveClosedCaptionTrack Flag of having closed caption track or not by Bool.
     @constant NotificationHaveSubtitleTrack Flag of having subtitle track or not by Bool.
     @constant NotificationAmountSeconds Amount seconds data by Int64.
     @constant NotificationCurrentSeconds Current seconds data by Int64.
     @constant NotificationAvailableSeconds Available seconds data by Int64.
     @constant NotificationMute Mute status by Bool.
     @constant NotificationVolumn Volumn value by Float from zero to one.
     */
    @objc static let NotificationPlayerKey = "P9MediaManagerNotificationPlayerKey"
    @objc static let NotificationEvent = "P9MediaManagerNotificationEvent"
    @objc static let NotificationResourceUrlString = "P9MediaManagerNotificationResourceUrlString"
    @objc static let NotificationHaveVideoTrack = "P9MediaManagerNotificationHaveVideoTrack"
    @objc static let NotificationHaveAudioTrack = "P9MediaManagerNotificationHaveAudioTrack"
    @objc static let NotificationHaveClosedCaptionTrack = "P9MediaManagerNotificationHaveClosedCaptionTrack"
    @objc static let NotificationHaveSubtitleTrack = "P9MediaManagerNotificationHaveSubtitleTrack"
    @objc static let NotificationAmountSeconds = "P9MediaManagerNotificationAmountSeconds"
    @objc static let NotificationCurrentSeconds = "P9MediaManagerNotificationCurrentSeconds"
    @objc static let NotificationAvailableSeconds = "P9MediaManagerNotificationAvailableSeconds"
    @objc static let NotificationMute = "P9MediaManagerNotificationMute"
    @objc static let NotificationVolumn = "P9MediaManagerNotificationVolumn"
    
    /*!
     @enum Event
     
     @abstract
     List that you catchable event from P9MediaManager's notification to handling media.
     You can get these values from Notification.userInfo by key 'P9MediaManager.NotificationKey'.
     
     @constant unknown
     just unknown.
     
     @constant standby
     Media resource just created and standby by given url that your given key.
     Check more String value for key 'P9MediaManager.NotificationResourceUrlString' from Notification.userInfo to verify resource url.
     
     @constant standbyAgain
     Media resource created again and standby by given url that your given key.
     Check more String value for key 'P9MediaManager.NotificationResourceUrlString' from Notification.userInfo to verify resource url.
     
     @constant standbySkip
     Media resource creation skipped because it already standby.
     Check more String value for key 'P9MediaManager.NotificationResourceUrlString' from Notification.userInfo to verify resource url.
     
     @constant release
     Media resource for given key was released just now.
     
     @constant place
     Media resource for given key is setted on your some given view just now.
     
     @constant placeAgain
     Media resource for given key is setted again on your some given view just now.
     
     @constant placeSkip
     Media resource for given key setting skipped because it already placed.
     
     @constant displace
     Media resource for given key is unsetted on your some given view just now.
     
     @constant play
     Media resource for given key called play request.
     
     @constant pause
     Media for given key was paused just now.
     
     @constant seek
     Media for given key was seeked just now.
     Check more Int64 value for key 'P9MediaManager.NotificationCurrentSeconds', 'P9MediaManager.NotificationAmountSeconds' from Notification.userInfo.
     to verify current and amount seconds.
     
     @constant mute
     Media for given key's mute status changed just now.
     Check more Bool Value for key 'P9MediaManager.NotificationMute' from Notification.userInfo.
     
     @constant volumn
     Media for given key's volumn value changed just now.
     Check more Float Value for key 'P9MediaManager.NotificationVolumn' from Notification.userInfo.
     
     @constant buffering
     Media for given key got data and accumulated just now.
     Check more Int64 value for key 'P9MediaManager.NotificationAvailableSeconds' from Notification.userInfo to verify available seconds.
     Available seconds means like the buffered data size. It always less then amount size of resource.
     
     @constant readyToPlay
     Media resource for given key now available to play.
     Check more Int64 value for key 'P9MediaManager.NotificationAmountSeconds' from Notification.userInfo to verify amount seconds of resource.
     You can also get those information from value 'P9MediaManager.NotificationAmountSeconds'.
     If value is equal to zero then, it is streaming resource.
     If value is greater then zero, it is vod resource.
     And, you can verify tracks by checking Bool value for key 'P9MediaManager.NotificationHaveVideoTrack', 'P9MediaManager.NotificationHaveAudioTrack', 'P9MediaManager.NotificationHaveClosedCaptionTrack' and 'P9MediaManager.NotificationHaveSubtitleTrack'.
     
     @constant playing
     Media resource for given key is going to play.
     Check more Int64 value for key 'P9MediaManager.NotificationCurrentSeconds', 'P9MediaManager.NotificationAmountSeconds' from Notification.userInfo
     to verify current and amount seconds on playing.
     
     @constant pending
     Media resource for given key is pending just now for some other reason like network problem or resource down.
     If some other reason resolved, you can get 'playing' events again automatically.
     
     @constant playToEnd
     Media resource for given key had play all contents just now.
     
     @constant playToEndAndWillRewind
     Media resource for given key had play all contents just now and will rewind because setted loop.
     
     @constant fail
     Media resource for given key got some failure.
     */
    @objc(P9MediaManagerEvent) enum Event: Int {
        case unknown
        case standby
        case standbyAgain
        case standbyAlready
        case release
        case place
        case placeAgain
        case placeAlready
        case displace
        case play
        case pause
        case seek
        case mute
        case volume
        case buffering
        case readyToPlay
        case playing
        case pending
        case playToEnd
        case playToEndAndWillRewind
        case fail
    }
    
    fileprivate let keyPathStatus = "status"
    fileprivate let keyPathLoadedTimeRanges = "loadedTimeRanges"
    
    fileprivate class MediaItem {
        
        var resourceUrl:URL
        var playerItem:AVPlayerItem
        var playerItemVideoOutput:AVPlayerItemVideoOutput
        init(resourceUrl:URL, playerItem:AVPlayerItem, playerItemVideoOutput:AVPlayerItemVideoOutput) {
            self.resourceUrl = resourceUrl
            self.playerItem = playerItem
            self.playerItemVideoOutput = playerItemVideoOutput
        }
    }
    
    fileprivate class PlayNode {
        
        var player:AVPlayer?
        var playerLayer:AVPlayerLayer?
        var autoPlayWhenReady:Bool = false
        var loop:Bool = false
        var userInfo:[String:Any] = [:]
        var snapshotRefer:(completion:((URL, Int64, UIImage?) -> Void)?, pickSecond:Int64, useMemoryCache:Bool)?
        var mediaItem:MediaItem?
        var readyToPlay:Bool = false
        var amountSeconds:Int64 = 0
        var availableSeconds:Int64 = 0
        var haveVideoTrack:Bool = false
        var haveAudioTrack:Bool = false
        var haveClosedCaptionTrack:Bool = false
        var haveSubtitleTrack:Bool = false
        var subtitles:[String] = []
        func resetMediaHandlingValues() {
            mediaItem = nil
            readyToPlay = false
            amountSeconds = 0
            availableSeconds = 0
            haveAudioTrack = false
            haveVideoTrack = false
            haveClosedCaptionTrack = false
            haveSubtitleTrack = false
            subtitles.removeAll()
        }
    }
    
    fileprivate class SnapshotNode {
        var pickSecond:Int64 = 0
        var image:UIImage?
        init(pickSecond:Int64, image:UIImage?) {
            self.pickSecond = pickSecond
            self.image = image
        }
    }
    
    fileprivate let localQueue = DispatchQueue(label: "p9.manager.media.main.queue")
    fileprivate var nodes:[String:PlayNode] = [:]
    fileprivate var playbackTimeObservers:[AVPlayer:Any] = [:]
    fileprivate var keyForPlayerItem:[AVPlayerItem:String] = [:]
    fileprivate var snapshots:[String:SnapshotNode] = [:]
    
    /*!
     @property shared
     @abstract Singleton instance of P9MediaManager.
     */
    @objc static let shared = P9MediaManager()
    
    /*!
     @method deinit
     */
    deinit {
        
        releaseAllPlayers()
    }
    
    /*!
     @method setPlayerResourceUrl:force:key:
     @abstract set resource of player for given key.
     @param resourceUrl Url of your resource.
     @param forKey Key value that you want.
     @returns Succeed or not.
     */
    @objc @discardableResult func setPlayer(resourceUrl:URL, forKey key:String) -> Bool {
        
        let node = nodes[key] ?? PlayNode()
        let resourceUrlString = resourceUrl.absoluteString
        
        if let previousResourceUrlString = node.mediaItem?.resourceUrl.absoluteString, previousResourceUrlString == resourceUrlString {
            notify(key: key, event: .standbyAlready, parameters: [P9MediaManager.NotificationResourceUrlString:previousResourceUrlString])
            return true
        }
        let event = setNode(node, withUrl: resourceUrl, key: key)
        notify(key: key, event: event, parameters: [P9MediaManager.NotificationResourceUrlString:resourceUrl.absoluteString])
        
        return true
    }
    
    /*!
     @method setPlayerResourceUrl:force:
     @abstract set resource of player for given key.
     @param resourceUrl Url of your resource and using url string by key automatically.
     @returns Succeed or not.
     */
    @objc @discardableResult func setPlayer(resourceUrl:URL) -> Bool {
        
        return setPlayer(resourceUrl: resourceUrl, forKey: resourceUrl.absoluteString)
    }
    
    /*!
     @method releasePlayerForKey:
     @abstract Release player for given key. You can release player when you don't need anymore for efficient resource management.
     @param forKey Key value that you want to release.
     */
    @objc func releasePlayer(forKey key:String) {
        
        guard let node = nodes[key] else {
            return
        }
        
        if let player = node.player {
            player.pause()
            releaseObserversOf(player: player)
        }
        if let playerLayer = node.playerLayer {
            playerLayer.player = nil
            node.playerLayer = nil
        }
        if let playerItem = node.mediaItem?.playerItem {
            releaseObserversOf(playerItem: playerItem)
            keyForPlayerItem.removeValue(forKey: playerItem)
        }
        nodes.removeValue(forKey: key)
        
        notify(key: key, event: .release)
    }
    
    /*!
     @method releaseAllPlayers
     @abstract Release all players.
     */
    @objc func releaseAllPlayers() {
        
        for (key, node) in nodes {
            if let player = node.player {
                player.pause()
                releaseObserversOf(player: player)
            }
            if let playerLayer = node.playerLayer {
                playerLayer.player = nil
                node.playerLayer = nil
            }
            if let playerItem = node.mediaItem?.playerItem {
                releaseObserversOf(playerItem: playerItem)
                keyForPlayerItem.removeValue(forKey: playerItem)
            }
            notify(key: key, event: .release)
        }
        nodes.removeAll()
        playbackTimeObservers.removeAll()
    }
    
    /*!
     @method placePlayerForKey:toView:autoPlayWhenReadyFlag:
     @abstract Place player for given key to given view. Given view's layer class must be AVPlayerLayer.
     @param forKey Key value that you want to place.
     @param toView Placing view and it's layer class must be AVPlayerLayer.
     @param mute If you want to play mute then set it.
     @param loop If you want to play loop then set it.
     @param autoPlayWhenReadyFlag If you want to auto play when given resource ready then set it.
     @returns Succeed or not.
     */
    @objc @discardableResult func placePlayer(forKey key:String, toView:UIView, mute:Bool, loop:Bool, autoPlayWhenReadyFlag:Bool) -> Bool {
        
        guard let node = nodes[key], let player = node.player, let playerLayer = toView.layer as? AVPlayerLayer else {
            return false
        }
        
        player.isMuted = mute
        node.loop = loop
        node.autoPlayWhenReady = autoPlayWhenReadyFlag
        
        var event:Event = .place
        if let placedPlayerLayer = node.playerLayer {
            if placedPlayerLayer === playerLayer {
                notify(key: key, event: .placeAlready)
                if autoPlayWhenReadyFlag == true {
                    playPlayer(forKey: key)
                }
                return true
            }
            placedPlayerLayer.player = nil
            event = .placeAgain
        }
        playerLayer.player = player
        node.playerLayer = playerLayer
        
        notify(key: key, event: event)
        
        if autoPlayWhenReadyFlag == true {
            playPlayer(forKey: key)
        }
        
        return true
    }
    
    /*!
     @method displacePlayerForKey:
     @abstract Displace player for given key from placed view already.
     @param forKey Key value that you want to place.
     @returns Succeed or not.
     */
    @objc @discardableResult func displacePlayer(forKey key:String) -> Bool {
        
        guard let node = nodes[key], let placeAvLayer = node.playerLayer else {
            return false
        }
        
        placeAvLayer.player = nil
        node.playerLayer = nil
        
        notify(key: key, event: .displace)
        
        return true
    }
    
    /*!
     @method playPlayerForKey:
     @abstract Play player for given key.
     @param forKey Key value that you want to play.
     @returns Succeed or not.
     */
    @objc @discardableResult func playPlayer(forKey key:String) -> Bool {
        
        guard let player = nodes[key]?.player, playbackTimeObservers[player] != nil else {
            return false
        }
        
        if isPlayingPlayer(forKey: key) == false {
            player.play()
            notify(key: key, event: .play)
        }
        
        return true
    }
    
    /*!
     @method playPlayerWhenReady:
     @abstract Play player for given key.
     @param loop If you want to play loop then set it.
     @param forKey Key value that you want to play.
     @returns Succeed or not.
     */
    @objc @discardableResult func playPlayerWhenReady(loop:Bool, forKey key:String) -> Bool {
        
        guard let node = nodes[key], let player = node.player else {
            return false
        }
        
        node.loop = loop
        node.autoPlayWhenReady = true
        
        if playbackTimeObservers[player] != nil, isPlayingPlayer(forKey: key) == false {
            player.play()
            notify(key: key, event: .play)
        }
        
        return true
    }
    
    /*!
     @method pausePlayerForKey:
     @abstract Pause player for given key.
     @param forKey Key value that you want to pause.
     @returns Succeed or not.
     */
    @objc @discardableResult func pausePlayer(forKey key:String) -> Bool {
        
        guard let player = nodes[key]?.player else {
            return false
        }
        
        if isPlayingPlayer(forKey: key) == true {
            player.pause()
            notify(key: key, event: .pause)
        }
        
        return true
    }
    
    /*!
     @method pauseAllPlayers
     @abstract Pause all players.
     */
    @objc func pauseAllPlayers() {
        
        for (key, node) in nodes {
            if let player = node.player {
                player.pause()
                notify(key: key, event: .pause)
            }
        }
    }
    
    /*!
     @method pauseAllPlayersExceptOneForKey:
     @abstract Pause all players except player for given key.
     */
    @objc func pauseAllPlayersExceptOne(forKey remainKey:String) {
        
        for (key, node) in nodes {
            if let player = node.player, key != remainKey  {
                player.pause()
                notify(key: key, event: .pause)
            }
        }
    }
    
    /*!
     @method setClosedCaptionDisplayEnabled:ForKey:
     @abstract Set closed caption display enabled of player for given key.
     @param forKey Key value that you want to set.
     @returns Succeed or not.
     */
    @objc @discardableResult func setClosedCaptionDisplay(enabled:Bool, forKey key:String) -> Bool {
        
        guard let player = nodes[key]?.player else {
            return false
        }
        
        if #available(iOS 11.0, *) {
            return false
        } else {
            player.isClosedCaptionDisplayEnabled = enabled
        }
        
        return true
    }
    
    /*!
     @method subtitleDisplayNamesOfPlayerForKey:
     @abstract Get subtitle display name list of of player for given key. Its' data only valid after ready to play.
     @param forKey Key value that you want to check.
     @returns Succeed or not.
     */
    @objc func subtitleDisplayNamesOfPlayer(forKey key:String) -> [String]? {
        
        guard let node = nodes[key] else {
            return nil
        }
        
        return node.subtitles
    }
    
    /*!
     @method selectSubtitleByDisplayName:displayName:ForKey:
     @abstract Select subtitle by display name of player for given key.
     @param byDisplayName display name of select subtitle. If display name is nil or not exist then subtitle deselected.
     @param forKey Key value that you want to set.
     @returns Succeed or not.
     */
    @objc @discardableResult func selectSubtitle(byDisplayName displayName:String?, forKey key:String) -> Bool {
        
        guard let node = nodes[key], let player = node.player, let item = node.mediaItem?.playerItem, playbackTimeObservers[player] != nil else {
            return false
        }
        guard let selectionGroup = item.asset.mediaSelectionGroup(forMediaCharacteristic: .legible), selectionGroup.options.count > 0 else {
            return false
        }
        
        for option in selectionGroup.options {
            if option.displayName == displayName {
                item.select(option, in: selectionGroup)
                return true
            }
        }
        item.select(nil, in: selectionGroup)
        
        return true
    }
    
    /*!
     @method seekTimeOfPlayerForKey:
     @abstract Get current time of player for given key.
     @param forKey Key value that you want to get current time.
     */
    @objc func seekTimeOfPlayer(forKey key:String) -> Int64 {
        
        guard let player = nodes[key]?.player else {
            return 0
        }
        
        return Int64(CMTimeGetSeconds(player.currentTime()))
    }
    
    /*!
     @method setSeekTimeOfPlayerForKey:seekTimeValue:seekTimeScale:
     @abstract Change Player's current play time to given time.
     @param seekTimeValue Second value
     @param seekTimeScale Scale value.
     @param forKey Key value that you want to seek.
     @returns Succeed or not.
     */
    @objc @discardableResult func setSeekTimeOfPlayer(seekTimeValue:Int64, seekTimeScale:Int32=1, forKey key:String) -> Bool {
        
        guard let node = nodes[key], let player = node.player, node.amountSeconds > 0 else {
            return false
        }
        
        let playing = isPlayingPlayer(forKey: key)
        var seekTime = CMTimeMake(value: seekTimeValue, timescale: seekTimeScale)
        if Int64(CMTimeGetSeconds(seekTime)) < 0 {
            seekTime = CMTimeMake(value: 0, timescale: 1)
        }
        if Int64(CMTimeGetSeconds(seekTime)) >  node.amountSeconds {
            seekTime = CMTimeMake(value: node.amountSeconds, timescale: 1)
        }
        let seekSeconds = Int64(CMTimeGetSeconds(seekTime))
        
        player.seek(to: seekTime) { (finished) in
            self.notify(key: key, event: .seek, parameters: [P9MediaManager.NotificationCurrentSeconds:seekSeconds, P9MediaManager.NotificationAmountSeconds:node.amountSeconds])
            if (playing == true) && (finished == false) {
                player.play()
            }
        }
        
        return true
    }
    
    /*!
     @method setSeekTimeOfPlayerForKey:rate:
     @abstract Change Player's current play time to given time.
     @param rate Rate value, from zero to one.
     @param forKey Key value that you want to seek.
     @returns Succeed or not.
     */
    @objc @discardableResult func setSeekTimeOfPlayer(rate:Float, forKey key:String) -> Bool {
        
        guard rate >= 0, rate <= 1, let node = nodes[key], node.amountSeconds > 0 else {
            return false
        }
        
        let seekTimeValue:Int64 = Int64(Float(node.amountSeconds)*rate)
        setSeekTimeOfPlayer(seekTimeValue: seekTimeValue, seekTimeScale: 1, forKey: key)
        
        return true
    }
    
    /*!
     @method isMutedPlayerForKey:
     @abstract Get mute status of the player for given key.
     @param forKey Key value that you want to check
     @returns muted or not.
     */
    func isMutedPlayer(forKey key:String) -> Bool {
        
        return nodes[key]?.player?.isMuted ?? false
    }
    
    /*!
     @method setMutePlayerMute:ForKey:
     @abstract Change mute status of the player for given key.
     @param mute set value of mute by bool
     @param forKey Key value that you want to check
     @returns succeed or not.
     */
    @objc @discardableResult func setMutePlayer(mute:Bool, forKey key:String) -> Bool {
        
        guard let player = nodes[key]?.player else {
            return false
        }
        
        player.isMuted = mute
        
        notify(key: key, event: .mute, parameters: [P9MediaManager.NotificationMute:player.isMuted])
        
        return true
    }
    
    /*!
     @method volumeOfPlayerForKey:
     @abstract Change mute status of the player for given key.
     @param forKey Key value that you want to check
     @returns volume value from zero to one.
     */
    @objc func volumeOfPlayer(forKey key:String) -> Float {
        
        return nodes[key]?.player?.volume ?? 0
    }
    
    /*!
     @method setVolumeOfPlayerVolume:ForKey:
     @abstract Change mute status of the player for given key.
     @param forKey Key value that you want to check
     @returns volume value from zero to one.
     */
    @objc @discardableResult func setVolumeOfPlayer(volume:Float, forKey key:String) -> Bool {
        
        guard let player = nodes[key]?.player else {
            return false
        }
        
        player.volume = volume
        
        notify(key: key, event: .mute, parameters: [P9MediaManager.NotificationVolumn:player.volume])
        
        return true
    }
    
    /*!
     @method havePlayerForKey:
     @abstract Check stanby status of the player for given key.
     @param forKey Key value that you want to check
     @returns exist or not.
     */
    @objc func havePlayer(forKey key:String) -> Bool {
        
        return (nodes[key]?.player != nil)
    }
    
    /*!
     @method resourceUrlOfPlayerForKey:
     @abstract Get resource url of the player for given key.
     @param forKey Key value that you want to check
     @returns URL or nil.
     */
    @objc func resourceUrlOfPlayer(forKey key:String) -> URL? {
        
        return nodes[key]?.mediaItem?.resourceUrl
    }
    
    /*!
     @method trackInfoOfPlayerForKey:
     @abstract Get track information of player for given key.
     @param forKey Key value that you want to check
     @returns Track information by NotificationHaveVideoTrack, NotificationHaveAudioTrack, NotificationHaveClosedCaptionTrack and NotificationHaveSubtitleTrack key/value.
     */
    @objc func trackInfoOfPlayer(forKey key:String) -> [String:Any]? {
        
        guard let node = nodes[key] else {
            return nil
        }
        
        return [P9MediaManager.NotificationHaveVideoTrack:node.haveVideoTrack,
                P9MediaManager.NotificationHaveAudioTrack:node.haveAudioTrack,
                P9MediaManager.NotificationHaveClosedCaptionTrack:node.haveClosedCaptionTrack,
                P9MediaManager.NotificationHaveSubtitleTrack:node.haveSubtitleTrack]
    }
    
    /*!
     @method isPlacedPlayerForKey:
     @abstract Check the player placed on view or not for given key.
     @param forKey Key value that you want to check.
     @returns placed or not.
     */
    @objc func isPlacedPlayer(forKey key:String) -> Bool {
        
        return (nodes[key]?.playerLayer != nil)
    }
    
    /*!
     @method isPlayingPlayerForKey:
     @abstract Check playing status of player that given key.
     @param forKey Key value that you want to check.
     @returns playing or not.
     */
    @objc func isPlayingPlayer(forKey key:String) -> Bool {
        
        guard let player = nodes[key]?.player else {
            return false
        }
        
        return (player.rate != 0) && (player.error == nil)
    }
    
    /*!
     @method amountSecondsOfPlayerForKey:
     @abstract Get amount time of player that given key.
     @param forKey Key value that you want to check.
     @returns Amount seconds.
     */
    @objc func amountSecondsOfPlayer(forKey key:String) -> Int64 {
        
        return nodes[key]?.amountSeconds ?? 0
    }
    
    /*!
     @method currentSecondsOfPlayerForKey:
     @abstract Get current time of player that given key.
     @param forKey Key value that you want to check.
     @returns Current seconds.
     */
    @objc func currentSecondsOfPlayer(forKey key:String) -> Int64 {
        
        guard let playerItem = nodes[key]?.mediaItem?.playerItem else {
            return 0
        }
        
        return Int64(CMTimeGetSeconds(playerItem.currentTime()))
    }
    
    /*!
     @method customValueForKey:ofPlayerKey:
     @abstract Get value of custom information of player that given key.
     @param forKey Custom key that you want to check.
     @param ofPlayerKey Player key that you want to check.
     @returns value
     */
    @objc func customValue(forKey customKey:String, ofPlayerKey playerKey:String) -> Any? {
        
        return nodes[playerKey]?.userInfo[customKey] ?? nil
    }
    
    /*!
     @method setCustomValueForKey:ofPlayerKey:
     @abstract Get value of custom information of player that given key.
     @param value Custom value that you want to store.
     @param forKey Custom key that you want to check.
     @param ofPlayerKey Player key that you want to check.
     @returns stored or not
     */
    @objc @discardableResult func setCustom(value:Any, forKey customKey:String, ofPlayerKey playerKey:String) -> Bool {
        
        guard let node = nodes[playerKey] else {
            return false
        }
        
        node.userInfo[customKey] = value
        
        return true
    }
    
    /*!
     @method removeCustomValueForKey:ofPlayerKey:
     @abstract Remove value of custom information of player that given key.
     @param forKey Custom key that you want to check.
     @param ofPlayerKey Player key that you want to check.
     @returns removed or not
     */
    @objc @discardableResult func removeCustomeValue(forKey customKey:String, ofPlayerKey playerKey:String) -> Bool {
        
        guard let node = nodes[playerKey] else {
            return false
        }
        
        node.userInfo.removeValue(forKey: customKey)
        
        return true
    }
    
    /*!
     @method snapshotImageOfResourceUrl:pickSecond:useMemoryCache:compeltion:
     @abstract Get snapshot of media resource that given url.
     @param ofResourceUrl Media resource url to take snapshot.
     @param pickSecond Second of media resource to take snapshot.
     @param useMemoryCache P9MediaManagaer make memory cache for given resource url and pick second automatically. If you want get cached snapshot image immediately, set it to true.
     @param completion Business code block to execute after get snapshot image.
     */
    @objc func snapshotImage(ofResourceUrl resourceUrl:URL, pickSecond:Int64, useMemoryCache:Bool, completion: @escaping ((URL, Int64, UIImage?) -> Void)) {
        
        let urlString = resourceUrl.absoluteString
        if useMemoryCache == true, let snapshot = snapshots[urlString], snapshot.pickSecond == pickSecond {
            DispatchQueue.main.async {
                completion(resourceUrl, pickSecond, snapshot.image)
            }
            return
        }
        
        if resourceUrl.isFileURL == true {
            let imageGenerator = AVAssetImageGenerator(asset: AVAsset(url: resourceUrl))
            imageGenerator.appliesPreferredTrackTransform = true
            let pickTime = CMTimeMake(value: pickSecond, timescale: 1)
            imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: pickTime)]) { (requestedTime, cgImage, actureTime, result, error) in
                let snapshotImage:UIImage? = (cgImage != nil) ? UIImage(cgImage: cgImage!) : nil
                if useMemoryCache == true {
                    self.snapshots[resourceUrl.absoluteString] = SnapshotNode(pickSecond: pickSecond, image: snapshotImage)
                }
                DispatchQueue.main.async {
                    completion(resourceUrl, pickSecond, snapshotImage)
                }
            }
            return
        }
        
        let key = "snapshot:\(resourceUrl.absoluteString)"
        let node = PlayNode()
        let event = setNode(node, withUrl: resourceUrl, key: key)
        node.snapshotRefer = (completion, pickSecond, useMemoryCache)
        notify(key: key, event: event, parameters: [P9MediaManager.NotificationResourceUrlString:resourceUrl.absoluteString])
    }
    
    /*!
     @method removeSnapshotCacheResourceUrl:
     @abstract Remove cached snapshot image for given media resource url.
     */
    @objc func removeSnapshotCache(resourceUrl:URL) {
        
        snapshots.removeValue(forKey: resourceUrl.absoluteString)
    }
    
    /*!
     @method removeAllSnapshotCache
     @abstract Remove all cached snapshot images.
     */
    @objc func removeAllSnapshotCache() {
        
        snapshots.removeAll()
    }
    
    /*!
     @method snapshotPlayerForKey:
     @abstract Get snapshot current frame of player for given key.
     */
    @objc func snapshotPlayer(forKey key:String) -> UIImage? {
        
        guard let node = nodes[key], let playerItem = node.mediaItem?.playerItem, let videoOutput = node.mediaItem?.playerItemVideoOutput else {
            return nil
        }

        let currentTime = playerItem.currentTime()
        if videoOutput.hasNewPixelBuffer(forItemTime: currentTime) == true, let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
            let image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))
            return image
        }
        
        return nil
    }
}

extension P9MediaManager {
    
    @discardableResult fileprivate func setNode(_ node:PlayNode, withUrl url:URL, key:String) -> Event {
        
        if let previousPlayerItem = node.mediaItem?.playerItem {
            releaseObserversOf(playerItem: previousPlayerItem)
            keyForPlayerItem.removeValue(forKey: previousPlayerItem)
        }
        let playerItem = AVPlayerItem(url: url)
        let videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange])
        playerItem.add(videoOutput)
        playerItem.addObserver(self, forKeyPath: keyPathLoadedTimeRanges, options: .new, context: nil)
        playerItem.addObserver(self, forKeyPath: keyPathStatus, options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.avPlayerItemDidPlayToEndTimeHandler(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        var replaced:Bool = false
        
        node.resetMediaHandlingValues()
        node.mediaItem = MediaItem(resourceUrl: url, playerItem: playerItem, playerItemVideoOutput: videoOutput)
        if let player = node.player {
            releaseObserversOf(player: player)
            player.replaceCurrentItem(with: nil)
            player.replaceCurrentItem(with: playerItem)
            replaced = true
        } else {
            node.player = AVPlayer(playerItem: playerItem)
        }
        
        nodes[key] = node
        keyForPlayerItem[playerItem] = key
        
        return (replaced == true ? .standbyAgain : .standby)
    }
    
    fileprivate func releaseObserversOf(playerItem:AVPlayerItem) {
        
        playerItem.removeObserver(self, forKeyPath: keyPathStatus, context: nil)
        playerItem.removeObserver(self, forKeyPath: keyPathLoadedTimeRanges, context: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    fileprivate func releaseObserversOf(player:AVPlayer) {
        
        if let observer = playbackTimeObservers[player] {
            player.removeTimeObserver(observer)
        }
        playbackTimeObservers.removeValue(forKey: player)
    }
    
    fileprivate func processSnapshotOfPlayer(forKey key:String) {
        
        guard let node = nodes[key], let mediaItem = node.mediaItem, let snapshotRefer = node.snapshotRefer, node.readyToPlay == true else {
            return
        }
        
        let pickSecond:Int64 = (snapshotRefer.pickSecond < node.amountSeconds) ? snapshotRefer.pickSecond : node.amountSeconds
        
        if node.availableSeconds >= pickSecond {
            let currentTime = CMTimeMake(value: pickSecond, timescale: 1)
            var snapshotImage:UIImage?
            if mediaItem.playerItemVideoOutput.hasNewPixelBuffer(forItemTime: currentTime) == true, let pixelBuffer = mediaItem.playerItemVideoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
                snapshotImage = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))
            }
            if snapshotRefer.useMemoryCache == true {
                snapshots[mediaItem.resourceUrl.absoluteString] = SnapshotNode(pickSecond: snapshotRefer.pickSecond, image: snapshotImage)
            }
            if let snapshotCompletion = snapshotRefer.completion {
                DispatchQueue.main.async {
                    snapshotCompletion(mediaItem.resourceUrl, pickSecond, snapshotImage)
                }
            }
            releasePlayer(forKey: key)
            node.snapshotRefer = nil
        }
    }
    
    fileprivate func notify(key:String, event:Event, parameters:[String:Any]?=nil) {
        
        var userInfo:[AnyHashable:Any] = [P9MediaManager.NotificationPlayerKey:key, P9MediaManager.NotificationEvent:event]
        parameters?.forEach({ (key, value) in
            userInfo[key] = value
        })
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .P9MediaManager, object: nil, userInfo: userInfo)
        }
    }
}

extension P9MediaManager {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let keyPath = keyPath, let item = object as? AVPlayerItem, let key = keyForPlayerItem[item], let node = nodes[key], let player = node.player else {
            return
        }
        
        switch keyPath {
        case keyPathStatus:
            switch item.status {
            case .readyToPlay:
                if node.readyToPlay == true {
                    break
                }
                node.readyToPlay = true
                node.amountSeconds = (CMTimeCompare(item.duration, CMTime.indefinite) != 0) ? Int64(Double(item.duration.value)/Double(item.duration.timescale)) : 0
                for track in item.tracks {
                    if let assetTrack = track.assetTrack, assetTrack.isEnabled == true {
                        switch assetTrack.mediaType {
                        case .video:
                            node.haveVideoTrack = true
                        case .audio:
                            node.haveAudioTrack = true
                        case .closedCaption:
                            node.haveClosedCaptionTrack = true
                        case .subtitle:
                            if let selectionGroup = item.asset.mediaSelectionGroup(forMediaCharacteristic: .legible), selectionGroup.options.count > 0 {
                                node.haveSubtitleTrack = true
                                for option in selectionGroup.options {
                                    node.subtitles.append(option.displayName)
                                }
                            }
                        default:
                            break
                        }
                    }
                }
                let observer = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: localQueue, using: { [weak self] time in
                    let currentSeconds = Int64(Double(item.currentTime().value)/Double((item.currentTime().timescale != 0) ? item.currentTime().timescale : 1))
                    if node.availableSeconds > 0, currentSeconds < node.availableSeconds {
                        self?.notify(key: key, event: .playing, parameters:[P9MediaManager.NotificationCurrentSeconds:currentSeconds,
                                                                            P9MediaManager.NotificationAmountSeconds:node.amountSeconds])
                    } else {
                        self?.notify(key: key, event: .pending)
                    }
                })
                self.playbackTimeObservers[player] = observer
                notify(key: key, event: .readyToPlay, parameters: [P9MediaManager.NotificationAmountSeconds:node.amountSeconds,
                                                                   P9MediaManager.NotificationHaveVideoTrack:node.haveVideoTrack,
                                                                   P9MediaManager.NotificationHaveAudioTrack:node.haveAudioTrack,
                                                                   P9MediaManager.NotificationHaveClosedCaptionTrack:node.haveClosedCaptionTrack,
                                                                   P9MediaManager.NotificationHaveSubtitleTrack:node.haveSubtitleTrack])
                if let snapshotRefer = node.snapshotRefer {
                    let pickSecond:Int64 = (snapshotRefer.pickSecond < node.amountSeconds) ? snapshotRefer.pickSecond : node.amountSeconds
                    if node.amountSeconds > 0, pickSecond > 1, pickSecond > node.availableSeconds {
                        player.seek(to: CMTimeMake(value: pickSecond, timescale: 1)) { (finished) in
                            self.processSnapshotOfPlayer(forKey: key)
                        }   
                    } else {
                        processSnapshotOfPlayer(forKey: key)
                    }
                }
                if node.autoPlayWhenReady == true {
                    player.play()
                    notify(key: key, event: .play)
                }
            case .failed:
                if let snapshotRefer = node.snapshotRefer, let mediaItem = node.mediaItem {
                    if snapshotRefer.useMemoryCache == true {
                        snapshots[mediaItem.resourceUrl.absoluteString] = SnapshotNode(pickSecond: snapshotRefer.pickSecond, image: nil)
                    }
                    if let snapshotCompletion = snapshotRefer.completion {
                        snapshotCompletion(mediaItem.resourceUrl, snapshotRefer.pickSecond, nil)
                    }
                    releasePlayer(forKey: key)
                    node.snapshotRefer = nil
                }
                notify(key: key, event: .fail)
            default :
                break
            }
        case keyPathLoadedTimeRanges :
            if let timeRange = player.currentItem?.loadedTimeRanges.first as? CMTimeRange  {
                node.availableSeconds = Int64(CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration))
                if node.snapshotRefer != nil, node.readyToPlay == true {
                    processSnapshotOfPlayer(forKey: key)
                }
                notify(key: key, event: .buffering, parameters: [P9MediaManager.NotificationAvailableSeconds:node.availableSeconds])
            }
        default:
            break
        }
    }
    
    @objc func avPlayerItemDidPlayToEndTimeHandler(notification:Notification) {
        
        guard let item = notification.object as? AVPlayerItem, let key = keyForPlayerItem[item], let node = nodes[key] else {
            return
        }
        
        if node.loop == true {
            notify(key: key, event: .playToEndAndWillRewind)
            setSeekTimeOfPlayer(rate: 0, forKey: key)
            playPlayer(forKey: key)
        } else {
            notify(key: key, event: .playToEnd)
        }
    }
}
