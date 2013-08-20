//
//  MarshalLayer.m
//  Cocoas2dxSample
//
//  Created by Jared Jenkins on 8/15/13.
//
//

#import "PlaynomicsMessaging.h"
#import "PlaynomicsFrame.h"
#import "MarshalLayer.h"

void pn_loadFrame(const char* frameId){
    NSString* utfFrameId = [[NSString alloc] initWithUTF8String:frameId];
    PlaynomicsMessaging* messaging = [PlaynomicsMessaging sharedInstance];
    PlaynomicsFrame* frame = [messaging createFrameWithId: utfFrameId];
    [frame start];
    [utfFrameId release];
}