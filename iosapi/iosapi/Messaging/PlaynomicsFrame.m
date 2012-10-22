//
// Created by jmistral on 10/3/12.
//
// To change the template use AppCode | Preferences | File Templates.
//
#import "PlaynomicsFrame+Exposed.h"
#import "PlaynomicsMessaging+Exposed.h"
#import "PNUtil.h"
#import "FSNConnection.h"
#import "BaseAdComponent.h"


#pragma mark - PlaynomicsFrame
typedef NS_ENUM(NSInteger, AdAction) {
    AdActionHTTP,            // Standard HTTP/HTTPS page to open in a browser
    AdActionDefinedAction,   // Defined selector to execute on a registered delegate
    AdActionExecuteCode,     // Submit the action on the delegate
    AdActionUnknown          // Unknown ad action specified
};


const NSString *HTTP_ACTION_PREFIX = @"http";
const NSString *HTTPS_ACTION_PREFIX = @"https";
const NSString *PNACTION_ACTION_PREFIX = @"pna";
const NSString *PNEXECUTE_ACTION_PREFIX = @"pnx";


@implementation PlaynomicsFrame {
  @private
    NSDictionary *_properties;
    BaseAdComponent *_background;
    BaseAdComponent *_adArea;
    BaseAdComponent *_closeButton;
    UIDeviceOrientation _currentOrientation;
}

@synthesize frameId = _frameId;


#pragma mark - Lifecycle/Memory management
- (id)initWithProperties:(NSDictionary *)properties forFrameId:(NSString *)frameId {
    if (self = [super init]) {
        _frameId = [frameId retain];
        _properties = [properties retain];

        [self _initOrientationChangeObservers];
        [self _initAdComponents];
    }
    return self;
}

- (void)dealloc {
    [_properties release];
    [_background release];
    [_adArea release];
    [_closeButton release];

    [super dealloc];
}

- (void)_initAdComponents {
    _background = [[BaseAdComponent alloc] initWithProperties:[_properties objectForKey:FrameResponseBackgroundInfo]
                                                     forFrame:self
                                             withTouchHandler:nil];

    _adArea = [[BaseAdComponent alloc] initWithProperties:[self _mergeAdInfoProperties]
                                                 forFrame:self
                                         withTouchHandler:@selector(_adClicked)];

    _closeButton = [[BaseAdComponent alloc] initWithProperties:[_properties objectForKey:FrameResponseCloseButtonInfo]
                                                      forFrame:self
                                              withTouchHandler:@selector(_stop)];

    [_background layoutComponent];
    [_adArea layoutComponent];
    [_closeButton layoutComponent];

    [_background addSubComponent:_adArea];
    [_background addSubComponent:_closeButton];
}

- (NSDictionary *)_mergeAdInfoProperties {
    NSDictionary *adInfo = [self _determineAdInfoToUse];
    NSDictionary *adLocationInfo = [_properties objectForKey:FrameResponseAdLocationInfo];

    NSMutableDictionary *mergedDict = [NSMutableDictionary dictionaryWithDictionary:adInfo];
    [mergedDict addEntriesFromDictionary:adLocationInfo];
    return mergedDict;
}

- (NSDictionary *)_determineAdInfoToUse {
    return [[_properties objectForKey:FrameResponseAds] objectAtIndex:0];
}


#pragma mark - Orientation handlers
- (void)_initOrientationChangeObservers {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object: nil];
}

- (void)_destroyOrientationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

- (void)_deviceOrientationDidChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = [PNUtil getCurrentOrientation];
    if (orientation == UIDeviceOrientationFaceUp
            || orientation == UIDeviceOrientationFaceDown
            || orientation == UIDeviceOrientationUnknown
            || _currentOrientation == orientation) {
        return;
    }
    _currentOrientation = orientation;

    NSLog(@"Orientation changed to: %i", orientation);
    [_background layoutComponent];
}


#pragma mark - Ad component click handlers
- (void)_stop {
    NSLog(@"Close button was pressed...");
    [self _closeAd];
    [self _submitAdImpressionToServer:[_adArea.properties objectForKey:FrameResponseAd_CloseUrl]];
}


- (void)_adClicked {
    NSString *clickTarget = [_adArea.properties objectForKey:FrameResponseAd_ClickTarget];
    NSURL *clickTargetUrl = [NSURL URLWithString:clickTarget];

    AdAction actionType = [self _determineActionType:clickTargetUrl];
    NSString *actionLabel = [self _determineActionLabel:clickTargetUrl];
    NSLog(@"Ad clicked with target (action type %i): %@", actionType, actionLabel);

    switch (actionType) {
        case AdActionHTTP: {
            [[UIApplication sharedApplication] openURL:clickTargetUrl];
            break;
        }
        case AdActionDefinedAction: {
            [[PlaynomicsMessaging sharedInstance] performActionForLabel:actionLabel];
            break;
        }
        case AdActionExecuteCode: {
            [[PlaynomicsMessaging sharedInstance] executeActionOnDelegate:actionLabel];
            break;
        }
        default: {
            NSLog(@"Unsupported ad action specified!");
            break;
        }
    }

    [self _closeAd];
}

- (AdAction)_determineActionType: (NSURL *)clickTargetUrl {
    NSString *protocol = clickTargetUrl.scheme;

    if ([protocol isEqualToString:HTTP_ACTION_PREFIX] || [protocol isEqualToString:HTTPS_ACTION_PREFIX]) {
        return AdActionHTTP;
    } else if ([protocol isEqualToString:PNACTION_ACTION_PREFIX]) {
        return AdActionDefinedAction;
    } else if ([protocol isEqualToString:PNEXECUTE_ACTION_PREFIX]) {
        return AdActionExecuteCode;
    } else {
        return AdActionUnknown;
    }
}

- (NSString *)_determineActionLabel:(NSURL *)url {
    NSString *resource = url.resourceSpecifier;
    return [resource stringByReplacingOccurrencesOfString:@"//" withString:@""];
}

- (void)_closeAd {
    [_background hide];
    [self _destroyOrientationObservers];
}


#pragma mark - Public Interface
- (DisplayResult)start {
    [_background display];
    [self _submitAdImpressionToServer:[_adArea.properties objectForKey:FrameResponseAd_ImpressionUrl]];

    if ([self _allComponentsLoaded]) {
        return DisplayResultDisplayed;
    } else {
        return DisplayResultDisplayPending;
    }
}

- (BOOL)_allComponentsLoaded {
    return (_background.status == AdComponentStatusCompleted
            && _adArea.status == AdComponentStatusCompleted
            && _closeButton.status == AdComponentStatusCompleted);
}

- (void)_submitAdImpressionToServer:(NSString *)impressionUrl {
    NSURL *url = [NSURL URLWithString:impressionUrl];
    NSLog(@"Submitting GET request to impression URL: %@", impressionUrl);

    FSNConnection *connection =
            [FSNConnection withUrl:url
                            method:FSNRequestMethodGET
                           headers:nil
                        parameters:nil
                        parseBlock:^id(FSNConnection *c, NSError **error) {
                            return [c.responseData stringFromUTF8];
                        }
                   completionBlock:^(FSNConnection *c) {
                       NSLog(@"Impression URL complete: error: %@, result: %@", c.error, c.parseResult);
                   }
                     progressBlock:nil];

    [connection start];
}


@end