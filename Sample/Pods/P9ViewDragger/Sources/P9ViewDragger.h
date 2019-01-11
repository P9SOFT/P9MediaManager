//
//  P9ViewDragger.h
//
//
//  Created by Tae Hyun Na on 2016. 3. 4.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

@import UIKit;
@import QuartzCore;

/*!
 Set this key to avoid translate action when tracking.
 */
#define     P9ViewDraggerLockTranslateKey           @"P9ViewDraggerLockTranslateKey"
/*!
 Set this key to avoid scale action when tracking.
 */
#define     P9ViewDraggerLockScaleKey               @"P9ViewDraggerLockScaleKey"
/*!
 Set this key to avoid rotate action when tracking.
 */
#define     P9ViewDraggerLockRotateKey              @"P9ViewDraggerLockRotateKey"
/*!
 Set this key with UIImage object then setted image will use preview image when tracking by decoy mode.
 */
#define     P9ViewDraggerSnapshotImageKey           @"P9ViewDraggerSnapshotImageKey"
/*!
 Set this key with UIView object then given view will use when tracking by decoy mode.
 */
#define     P9ViewDraggerDecoyViewKey               @"P9ViewDraggerDecoyViewKey"
/*!
 Set this key to avoid removing from stage that given decoy view after dragging action.
 */
#define     P9ViewDraggerRemainDecoyViewOnStageKey  @"P9ViewDraggerRemainDecoyViewOnStageKey"
/*!
 Set this key to start handling when touch down. If not, event will start when start finger moving.
 */
#define     P9ViewDraggerStartWhenTouchDownKey  @"P9ViewDraggerStartWhenTouchDownKey"

/*!
 Block code definition to handling when tracking view begin, doing and end.
 Parameter UIView is actual moving view object when tracking.
 */
typedef void(^P9ViewDraggerBlock)(UIView * _Nonnull);

/*!
 P9ViewDragger
 
 Helper module to tracking view with general touch gestures.
 */
@interface P9ViewDragger : NSObject

/*!
 Get shared default singleton module.
 @returns Return singleton P9ViewDragger object
 */
+ (P9ViewDragger * _Nonnull)defaultP9ViewDragger;

/*!
 Register view to P9ViewDragger. After then it'll move with touch gesture.
 Registered view will tracking automatically until untracking call.
 If call this method with already registed view then its' parameters will be update.
 @param trackingView View object to tracking.
 @param parameters Options for tracking.
 @param ready This block will call when tracking begin, once.
 @param trackingHandler This block will call when tracking all the time.
 @param completion This block will call when tracking end once.
 @returns Return the result of register succeed or not.
 */
- (BOOL)trackingView:(UIView * _Nullable)trackingView parameters:(NSDictionary * _Nullable)parameters ready:(P9ViewDraggerBlock _Nullable)ready trackingHandler:(P9ViewDraggerBlock _Nullable)trackingHandler completion:(P9ViewDraggerBlock _Nullable)completion;

/*!
 Register view to P9ViewDragger. After then it'll move with touch gesture.
 This method will move similar with trackingView method but only different thing is make decoy view of regsitered view and tracking it.
 A Decoy view of registered view will tracking automatically until untracking call.
 If call this method with already registed view then its' parameters will be update.
 @param trackingView View object to tracking.
 @param stageView Decoy view will create suggested stageView. if stageView is nil then use defaultStageView.
 @param parameters Options for tracking.
 @param ready This block will call when tracking begin, once.
 @param trackingHandler This block will call when tracking all the time.
 @param completion This block will call when tracking end once.
 @returns Return the result of register succeed or not.
 */
- (BOOL)trackingDecoyView:(UIView * _Nullable)trackingView stageView:(UIView * _Nullable)stageView parameters:(NSDictionary * _Nullable)parameters ready:(P9ViewDraggerBlock _Nullable)ready trackingHandler:(P9ViewDraggerBlock _Nullable)trackingHandler completion:(P9ViewDraggerBlock _Nullable)completion;

/*!
 Unregister view from tracking.
 @param trackingView View object to untracking.
 */
- (void)untrackingView:(UIView * _Nullable)trackingView;

/*!
 Unregister all tracking views on P9ViewDragger.
 */
- (void)untrackingAllViews;

/*!
 Decoy view will create on defaultStageView if not specified directly when it call.
 */
@property (nonatomic, strong) UIView * _Nullable defaultStageView;

@end
