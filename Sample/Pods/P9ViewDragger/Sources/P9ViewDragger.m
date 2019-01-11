//
//  P9ViewDragger.m
//
//
//  Created by Tae Hyun Na on 2016. 3. 4.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import "P9ViewDragger.h"

#define     kTrackingViewKey                @"trackingViewKey"
#define     kStageViewKey                   @"stageViewKey"
#define     kTrackingUnderstudyViewKey      @"trackingUnderstudyViewKey"
#define     kTrackingSnapshotImageKey       @"trackingSnapshotImageKey"
#define     kTrackingDecoyViewKey           @"trackingDecoyViewKey"
#define     kRemainDecoyViewKey             @"remainDecoyViewKey"
#define     kReadyBlockKey                  @"readyBlockKey"
#define     kTrackingHandlerBlockKey        @"trackingHandlerBlockKey"
#define     kCompletionBlockKey             @"completionBlockKey"
#define     kPressGestureKey                @"pressGestureKey"
#define     kPanGestureKey                  @"panGestureKey"
#define     kPinchGestureKey                @"pinchGestureKey"
#define     kRotationGestureKey             @"roationGestureKey"
#define     kOriginalUserInteractionKey     @"originalUserInteractionKey"
#define     kActiveGestureCountKey          @"activeGestureCountKey"

@interface P9ViewDragger () <UIGestureRecognizerDelegate>
{
    NSMutableDictionary *_trackingViewForKey;
}

- (NSString *)keyForView:(UIView *)view;
- (void)addP9ViewDraggerGesturesFortrackingTargetInfoDict:(NSMutableDictionary *)trackingTargetInfoDict fromParameters:(NSDictionary *)parameters;
- (void)removeP9ViewDraggerGesturesFortrackingTargetInfoDict:(NSMutableDictionary *)trackingTargetInfoDict;
- (void)transformTarget:(id)gestureRecognizer;

@end

@implementation P9ViewDragger

- (instancetype)init
{
    if( (self = [super init]) != nil ) {
        if( (_trackingViewForKey = [NSMutableDictionary new]) == nil ) {
            return nil;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [self untrackingAllViews];
}

- (NSString *)keyForView:(UIView *)view
{
    if( view == nil ) {
        return nil;
    }
    return [NSString stringWithFormat:@"%p", view];
}

- (void)addP9ViewDraggerGesturesFortrackingTargetInfoDict:(NSMutableDictionary *)trackingTargetInfoDict fromParameters:(NSDictionary *)parameters
{
    UIView *trackingView = trackingTargetInfoDict[kTrackingViewKey];
    if( [parameters[P9ViewDraggerStartWhenTouchDownKey] boolValue] == YES ) {
        UILongPressGestureRecognizer *pressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(transformTarget:)];
        pressGestureRecognizer.minimumPressDuration = 0;
        pressGestureRecognizer.delegate = self;
        [trackingView addGestureRecognizer:pressGestureRecognizer];
        trackingTargetInfoDict[kPressGestureKey] = pressGestureRecognizer;
    }
    if( [parameters[P9ViewDraggerLockTranslateKey] boolValue] == NO ) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(transformTarget:)];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        panGestureRecognizer.delegate = self;
        [trackingView addGestureRecognizer:panGestureRecognizer];
        trackingTargetInfoDict[kPanGestureKey] = panGestureRecognizer;
    }
    if( [parameters[P9ViewDraggerLockScaleKey] boolValue] == NO ) {
        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(transformTarget:)];
        pinchGestureRecognizer.delegate = self;
        [trackingView addGestureRecognizer:pinchGestureRecognizer];
        trackingTargetInfoDict[kPinchGestureKey] = pinchGestureRecognizer;
    }
    if( [parameters[P9ViewDraggerLockRotateKey] boolValue] == NO ) {
        UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(transformTarget:)];
        rotationGestureRecognizer.delegate = self;
        [trackingView addGestureRecognizer:rotationGestureRecognizer];
        trackingTargetInfoDict[kRotationGestureKey] = rotationGestureRecognizer;
    }
}

- (void)removeP9ViewDraggerGesturesFortrackingTargetInfoDict:(NSMutableDictionary *)trackingTargetInfoDict
{
    UIView *trackingView = trackingTargetInfoDict[kTrackingViewKey];
    if( trackingView == nil ) {
        return;
    }
    UILongPressGestureRecognizer *pressGestureRecognizer = trackingTargetInfoDict[kPressGestureKey];
    if( pressGestureRecognizer != nil ) {
        [trackingView removeGestureRecognizer:pressGestureRecognizer];
    }
    UIPanGestureRecognizer *panGestureRecognizer = trackingTargetInfoDict[kPanGestureKey];
    if( panGestureRecognizer != nil ) {
        [trackingView removeGestureRecognizer:panGestureRecognizer];
    }
    UIPinchGestureRecognizer *pinchGestureRecognizer = trackingTargetInfoDict[kPinchGestureKey];
    if( pinchGestureRecognizer != nil ) {
        [trackingView removeGestureRecognizer:pinchGestureRecognizer];
    }
    UIRotationGestureRecognizer *rotationGestureRecognizer = trackingTargetInfoDict[kRotationGestureKey];
    if( rotationGestureRecognizer != nil ) {
        [trackingView removeGestureRecognizer:rotationGestureRecognizer];
    }
}

- (void)transformTarget:(id)gestureRecognizer
{
    UIView *targetView = [gestureRecognizer view];
    NSString *key = [self keyForView:targetView];
    if( key == nil ) {
        return;
    }
    P9ViewDraggerBlock ready = nil;
    P9ViewDraggerBlock trackingHandler = nil;
    P9ViewDraggerBlock completion = nil;
    UIView *stageView = nil;
    UIView *understudyView = nil;
    UIImage *snapshotImage = nil;
    BOOL usingDecoyView = NO;
    BOOL remainDecoyView = NO;
    @synchronized(self) {
        NSMutableDictionary *trackingTargetDictInfo = _trackingViewForKey[key];
        if( trackingTargetDictInfo != nil ) {
            ready = trackingTargetDictInfo[kReadyBlockKey];
            trackingHandler = trackingTargetDictInfo[kTrackingHandlerBlockKey];
            completion = trackingTargetDictInfo[kCompletionBlockKey];
            stageView = trackingTargetDictInfo[kStageViewKey];
            understudyView = trackingTargetDictInfo[kTrackingUnderstudyViewKey];
            if( understudyView == nil ) {
                understudyView = trackingTargetDictInfo[kTrackingDecoyViewKey];
            }
            snapshotImage = trackingTargetDictInfo[kTrackingSnapshotImageKey];
            usingDecoyView = (trackingTargetDictInfo[kTrackingDecoyViewKey] != nil);
            remainDecoyView = [trackingTargetDictInfo[kRemainDecoyViewKey] boolValue];
        }
    }
    NSNumber *activeGestureCount = _trackingViewForKey[key][kActiveGestureCountKey];
    UIView *trackingView = (understudyView != nil) ? understudyView : targetView;;
    CATransform3D transform;
    switch( (UIGestureRecognizerState)[gestureRecognizer state] ) {
        case UIGestureRecognizerStateBegan :
            if( activeGestureCount.integerValue <= 0 ) {
                _trackingViewForKey[key][kActiveGestureCountKey] = @(1);
            } else {
                _trackingViewForKey[key][kActiveGestureCountKey] = @(activeGestureCount.integerValue+1);
                break;
            }
            if( stageView != nil ) {
                if( understudyView == nil ) {
                    UIImageView *imageView = [[UIImageView alloc] init];
                    imageView.userInteractionEnabled = NO;
                    if( snapshotImage == nil ) {
                        UIGraphicsBeginImageContextWithOptions(targetView.bounds.size, false, [UIScreen mainScreen].scale);
                        [targetView drawViewHierarchyInRect:targetView.bounds afterScreenUpdates:YES];
                        snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                    }
                    imageView.image = snapshotImage;
                    understudyView = imageView;
                }
                if( understudyView != nil ) {
                    understudyView.bounds = targetView.bounds;
                    understudyView.center = [stageView convertPoint:targetView.center fromView:((targetView.superview != nil) ? targetView.superview : targetView)];
                    understudyView.layer.transform = targetView.layer.transform;
                    [stageView addSubview:understudyView];
                    @synchronized(self) {
                        _trackingViewForKey[key][kTrackingUnderstudyViewKey] = understudyView;
                    }
                }
                trackingView = understudyView;
            }
            if( ready != nil ) {
                ready(trackingView);
            }
            break;
        case UIGestureRecognizerStateChanged :
            if( [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] == YES ) {
                CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:targetView.superview];
                trackingView.layer.transform = CATransform3DConcat(trackingView.layer.transform, CATransform3DMakeTranslation(translation.x, translation.y, 0.0));
                [(UIPanGestureRecognizer *)gestureRecognizer setTranslation:CGPointZero inView:targetView.superview];
            } else {
                transform = CATransform3DConcat(trackingView.layer.transform, CATransform3DInvert(trackingView.layer.transform));
                if( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] == YES ) {
                    CGFloat scale = ((UIPinchGestureRecognizer *)gestureRecognizer).scale;
                    transform = CATransform3DConcat(transform, CATransform3DMakeScale(scale, scale, 1));
                    ((UIPinchGestureRecognizer *)gestureRecognizer).scale = 1.0;
                }
                if( [gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]] == YES ) {
                    CGFloat rotation = ((UIRotationGestureRecognizer *)gestureRecognizer).rotation;
                    transform = CATransform3DConcat(transform, CATransform3DMakeRotation(rotation, 0.0, 0.0, 1.0));
                    ((UIRotationGestureRecognizer *)gestureRecognizer).rotation = 0.0;
                }
                transform = CATransform3DConcat(transform, trackingView.layer.transform);
                trackingView.layer.transform = transform;
            }
            if( trackingHandler != nil ) {
                trackingHandler(trackingView);
            }
            break;
        case UIGestureRecognizerStateEnded :
        case UIGestureRecognizerStateFailed :
            if( activeGestureCount.integerValue <= 0 ) {
                break;
            }
            activeGestureCount = @(activeGestureCount.integerValue - 1);
            _trackingViewForKey[key][kActiveGestureCountKey] = activeGestureCount;
            if( activeGestureCount.integerValue > 0 ) {
                break;
            }
            if( completion != nil ) {
                completion(trackingView);
            }
            if( understudyView != nil ) {
                if( usingDecoyView == YES ) {
                    if( remainDecoyView == NO ) {
                        [understudyView removeFromSuperview];
                    }
                } else {
                    [understudyView removeFromSuperview];
                    understudyView.layer.transform = CATransform3DIdentity;
                }
            }
            @synchronized(self) {
                [_trackingViewForKey[key] removeObjectForKey:kTrackingUnderstudyViewKey];
            }
            break;
        default :
            break;
    }
}

+ (P9ViewDragger *)defaultP9ViewDragger
{
    static dispatch_once_t once;
    static P9ViewDragger *sharedInstance;
    dispatch_once(&once, ^{sharedInstance = [[self alloc] init];});
    return sharedInstance;
}

- (BOOL)trackingView:(UIView *)trackingView parameters:(NSDictionary *)parameters ready:(P9ViewDraggerBlock)ready trackingHandler:(P9ViewDraggerBlock)trackingHandler completion:(P9ViewDraggerBlock)completion
{
    if( trackingView == nil ) {
        return NO;
    }
    BOOL userInteraction = trackingView.userInteractionEnabled;
    trackingView.userInteractionEnabled = YES;
    
    NSString *key = [self keyForView:trackingView];
    NSMutableDictionary *trackingTargetInfoDict = [NSMutableDictionary new];
    if( (key == nil) || (trackingTargetInfoDict == nil) ) {
        return NO;
    }
    
    trackingTargetInfoDict[kTrackingViewKey] = trackingView;
    trackingTargetInfoDict[kOriginalUserInteractionKey] = @(userInteraction);
    [self addP9ViewDraggerGesturesFortrackingTargetInfoDict:trackingTargetInfoDict fromParameters:parameters];
    if( ready != nil ) {
        trackingTargetInfoDict[kReadyBlockKey] = ready;
    }
    if( trackingHandler != nil ) {
        trackingTargetInfoDict[kTrackingHandlerBlockKey] = trackingHandler;
    }
    if( completion != nil ) {
        trackingTargetInfoDict[kCompletionBlockKey] = completion;
    }
    
    @synchronized(self) {
        _trackingViewForKey[key] = trackingTargetInfoDict;
    }
    
    return YES;
}

- (BOOL)trackingDecoyView:(UIView *)trackingView stageView:(UIView *)stageView parameters:(NSDictionary *)parameters ready:(P9ViewDraggerBlock)ready trackingHandler:(P9ViewDraggerBlock)trackingHandler completion:(P9ViewDraggerBlock)completion
{
    UIView *currentStageView = (stageView != nil) ? stageView : self.defaultStageView;
    if( (currentStageView == nil) || (trackingView == nil) ) {
        return NO;
    }
    BOOL userInteraction = trackingView.userInteractionEnabled;
    trackingView.userInteractionEnabled = YES;
    
    NSString *key = [self keyForView:trackingView];
    NSMutableDictionary *trackingTargetInfoDict = [NSMutableDictionary new];
    if( (key == nil) || (trackingTargetInfoDict == nil) ) {
        return NO;
    }
    
    trackingTargetInfoDict[kTrackingViewKey] = trackingView;
    trackingTargetInfoDict[kOriginalUserInteractionKey] = @(userInteraction);
    trackingTargetInfoDict[kStageViewKey] = currentStageView;
    if( parameters[P9ViewDraggerSnapshotImageKey] != nil ) {
        trackingTargetInfoDict[kTrackingSnapshotImageKey] = parameters[P9ViewDraggerSnapshotImageKey];
    }
    if( parameters[P9ViewDraggerDecoyViewKey] != nil ) {
        trackingTargetInfoDict[kTrackingDecoyViewKey] = parameters[P9ViewDraggerDecoyViewKey];
    }
    if( parameters[P9ViewDraggerRemainDecoyViewOnStageKey] != nil ) {
        trackingTargetInfoDict[kRemainDecoyViewKey] = ([parameters[P9ViewDraggerRemainDecoyViewOnStageKey] boolValue] == YES) ? @"Y" : @"N";
    }
    [self addP9ViewDraggerGesturesFortrackingTargetInfoDict:trackingTargetInfoDict fromParameters:parameters];
    if( ready != nil ) {
        trackingTargetInfoDict[kReadyBlockKey] = ready;
    }
    if( trackingHandler != nil ) {
        trackingTargetInfoDict[kTrackingHandlerBlockKey] = trackingHandler;
    }
    if( completion != nil ) {
        trackingTargetInfoDict[kCompletionBlockKey] = completion;
    }
    
    @synchronized(self) {
        _trackingViewForKey[key] = trackingTargetInfoDict;
    }
    
    return YES;
}

- (void)untrackingView:(UIView *)trackingView
{
    NSString *key = [self keyForView:trackingView];
    if( key == nil ) {
        return;
    }
    NSMutableDictionary *trackingTargetInfoDict = nil;
    @synchronized(self) {
        if( (trackingTargetInfoDict = _trackingViewForKey[key]) != nil ) {
            [_trackingViewForKey removeObjectForKey:key];
        }
    }
    [trackingTargetInfoDict[kTrackingViewKey] setUserInteractionEnabled:[trackingTargetInfoDict[kOriginalUserInteractionKey] boolValue]];
    [self removeP9ViewDraggerGesturesFortrackingTargetInfoDict:trackingTargetInfoDict];
}

- (void)untrackingAllViews
{
    NSArray *allTargets = nil;
    @synchronized(self) {
        if( (allTargets = _trackingViewForKey.allValues) != nil ) {
            [_trackingViewForKey removeAllObjects];
        }
    }
    for( NSMutableDictionary *trackingTargetInfoDict in allTargets ) {
        [trackingTargetInfoDict[kTrackingViewKey] setUserInteractionEnabled:[trackingTargetInfoDict[kOriginalUserInteractionKey] boolValue]];
        [self removeP9ViewDraggerGesturesFortrackingTargetInfoDict:trackingTargetInfoDict];
    }
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
