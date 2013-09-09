//
//  PNFrameRequest.m
//  PlaynomicsSDK
//
//  Created by Jared Jenkins on 9/6/13.
//
//

#import "PNFrameRequest.h"
#import "PNFrameResponse.h"

@implementation PNFrameRequest{
    PNFrame* _frame;
    NSString* _url;
    NSMutableDictionary *_params;
    PNAssetRequest *_request;
}

-(id) initWithFrame:(PNFrame *) frame screenSize:(CGRect) screenSize session:(PNSession *) session{
    if((self = [super init])){
        _frame = [frame retain];
        
        long long timeInMilliseconds = ([[NSDate date] timeIntervalSince1970] * 1000);
        
        NSNumber *requestTime = [NSNumber numberWithLongLong: timeInMilliseconds];
        
        NSNumber * applicationId = [NSNumber numberWithUnsignedLongLong:session.applicationId];
        
        _params = [[NSMutableDictionary alloc] init];
        [_params setObject:applicationId  forKey:@"a"];
        [_params setObject:session.userId forKey:@"u"];
        [_params setObject:requestTime forKey:@"t"];
        [_params setObject:@"ios" forKey:@"esrc"];
        [_params setObject:session.sdkVersion forKey:@"ever"];
        [_params setObject:frame.frameId forKey:@"f"];
        [_params setObject:[NSNumber numberWithInt: screenSize.size.height] forKey:@"c"];
        [_params setObject:[NSNumber numberWithInt: screenSize.size.width] forKey:@"d"];
    }
    return self;
}

-(void) dealloc{
    [_params release];
    [_url release];
    [_frame release];
    
    if(_request){
        [_request release];
    }
    [super dealloc];
}

-(void) fetchFrameData{
    _frame.state = PNFrameStateLoadingStarted;
    _request = [[PNAssetRequest alloc] initWithUrl:_url delegate:self];
}

-(void) requestDidCompleteWithData:(NSData *)data{
    @try{
        PNFrameResponse *response = [[[PNFrameResponse alloc] initWithJSONData:data] autorelease];
        [_frame updateFrameResponse:response];
        _frame.state = PNFrameStateLoadingComplete;
        
        [PNLogger log:PNLogLevelVerbose format:@"Successfully fetched frame data. JSON response @%", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
    }
    @catch(NSException *ex) {
        [PNLogger log:PNLogLevelWarning exception:ex format:@"Could load frame @%. Got exception while deserializing JSON response"];
        _frame.state = PNFrameStateLoadingFailed;
    }
}

-(void) requestDidFailtWithStatusCode:(int)statusCode{
    [PNLogger log:PNLogLevelWarning format:@"Could not load frame @%. Received HTTP status code %d", _frame.frameId, statusCode];
    _frame.state = PNFrameStateLoadingFailed;
}

-(void) requestDidFailWithError:(NSError *)error{
    [PNLogger log:PNLogLevelWarning error:error format:@"Could not load frame @%. Received error.", _frame.frameId];
    _frame.state = PNFrameStateLoadingFailed;
}

-(void) connectionDidFail{
    [PNLogger log:PNLogLevelWarning format:@"Could not load frame @%. Connection could not be uoen", _frame.frameId];
    _frame.state = PNFrameStateLoadingFailed;
}
@end
