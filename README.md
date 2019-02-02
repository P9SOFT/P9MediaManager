P9MediaManager
============

Media managing library to handling play and manage resources easily, based on AVFoundation.

# Installation

You can download the latest framework files from our Release page.
P9MediaManager also available through CocoaPods. To install it simply add the following line to your Podfile.
pod ‘P9MediaManager’

# Setup

There is no need setup to use P9MediaManager. :)
If you using Objective-C then, import generated header for Swift interface like <ProductModuleName>-Swift.h as usually do.

# Play

There is two way to play media by P9MediaManager that using P9MediaView and UIImageView.

Using P9MediaView,

declare P9MediaView somewhere you want(also can use on XIB by setting custom class).

```swift
let playView = P9MediaView(frame: CGRect(x: 0, y: 0, width: 640, height: 480))
```

```swift
@IBOutlet weak var playView: P9MediaView!
```

Set player by resource url and key, and place to playView.

```swift
let myResourceUrl = URL(string: "https://sample-videos.com/video123/mp4/480/big_buck_bunny_480p_10mb.mp4")!
let myResourceKey = "MyUniqueResourceKeyToHandlingGivenResourceUrl"

if P9MediaManager.shared.setPlayer(resourceUrl: myResourceUrl, force: false, forKey: myResourceKey) == true {
    P9MediaManager.shared.placePlayer(forKey: myResourceKey, toView: playView, mute: false, loop: false, autoPlayWhenReadyFlag: true)
}
```

If you don't need display video, you can just call play without place player.

```swift
if P9MediaManager.shared.setPlayer(resourceUrl: myResourceUrl, force: false, forKey: myResourceKey) == true {
    P9MediaManager.shared.playPlayerWhenReady(loop:false, forKey: myResourceKey)
}
```

P9MediaManager support UIImageView extension.
So, you can play media resource simply by setting only resource url and you don't need to care resource of it, like using UIImage on UIImageView.


```swift
imageView.p9MediaPlay(resourceUrl: myResourceUrl, mute: true, loop: true, autoPlayWhenReady: true, rewindIfPlaying: false)
```

You can also observe P9MediaManager event to deal with business logic.

```swift
NotificationCenter.default.addObserver(self, selector: #selector(self.p9MediaManagerNotificationHandler(notification:)), name: .P9MediaManager, object: nil)
```

```swift
@objc func p9MediaManagerNotificationHandler(notification:Notification) {

    guard let userInfo = notification.userInfo, let key = userInfo[P9MediaManagerNotificationKey] as? String, let event = userInfo[P9MediaManagerNotificationEvent] as? P9MediaManagerEvent else {
        return
    }

    switch event {
    case standby, standbyAgain, standbyAlready:
        print("standby \(key).")
        let resourceUrl = userInfo[P9MediaManagerNotificationResourceUrlString] as? String ?? ""
    case .place, .placeAgain, .placeAlready:
        print("place \(key).")
    case .displace:
        print("displace \(key).")
    case .fail:
        print("fail \(key).")
    case .readyToPlay:
        print("ready to play \(key).")
        let haveVideoTrack = userInfo[P9MediaManagerNotificationHaveVideoTrack] as? Bool ?? false
        let haveAudioTrack = userInfo[P9MediaManagerNotificationHaveAudioTrack] as? Bool ?? false
        let currentSeconds = userInfo[P9MediaManagerNotificationCurrentSeconds] as? Int64 ?? 0
        let amountSeconds = userInfo[P9MediaManagerNotificationAmountSeconds] as? Int64 ?? 0
    case .play:
        print("play \(key).")
    case .playing, .seek:
        print("playing \(key).")
        let currentSeconds = userInfo[P9MediaManagerNotificationCurrentSeconds] as? Int64 ?? 0
        let amountSeconds = userInfo[P9MediaManagerNotificationAmountSeconds] as? Int64 ?? 0
    case .pause:
        print("pause \(key).")
    case .mute:
        print("mute \(key).")
        let mute = userInfo[P9MediaManagerNotificationMute] as? Bool ?? false
    case .volumn:
        print("volumn \(key).")
        let volumn = userInfo[P9MediaManagerNotificationVolumn] as? Float ?? 0
    case .buffering:
        print("buffering \(key).")
        let availableSeconds = userInfo[P9MediaManagerNotificationAvailableSeconds] as? Int64 ?? 0
    case .pending:
        print("pending \(key).")
    case .playToEnd, .playToEndAndWillRewind:
        print("play to end \(key).")
    default:
        break
    }
}
```

And, you can get snapshot image from media resource url, without making player.

```swift
P9MediaManager.shared.snapshotImage(ofResourceUrl: url, pickSecond: 2, useMemoryCache: true) { (resourceUrl, pickedSecond, snapshotImage) in
    self.imageView.image = snapshotImage
}
```

You can also get snapshot image of current frame from playing media.

```swift
if let snapshotImage = P9MediaManager.shared.snapshotPlayer(forKey: myResourceKey) {
    self.imageView.image = snapshotImage
}
```

# License

MIT License, where applicable. http://en.wikipedia.org/wiki/MIT_License
