//
//  MarshalLayer.m
//  Cocoas2dxSample
//
//  Created by Jared Jenkins on 8/15/13.
//
//
#import "Playnomics.h"
#import "MarshalLayer.h"

void pn_loadFrame(const char* frameId){
    NSString* utfFrameId = [[NSString alloc] initWithUTF8String:frameId];
    [Playnomics showFrameWithId:utfFrameId];
    [utfFrameId release];
}