//
//  PNFrameRequest.m
//  PlaynomicsSDK
//
//  Created by Jared Jenkins on 9/6/13.
//
//

#import "PNFrameRequest.h"
#import "PNFrameResponse.h"
#import "PNEventApiClient.h"

@implementation PNFrameRequest{
    PNFrame* _frame;
    NSString* _url;
    PNAssetRequest *_request;
}

-(id) initWithFrame:(PNFrame *) frame screenSize:(CGRect) screenSize session:(PNSession *) session{
    if((self = [super init])){
        _frame = [frame retain];
        
        long long timeInMilliseconds = ([[NSDate date] timeIntervalSince1970] * 1000);
        
        NSNumber *requestTime = [NSNumber numberWithLongLong: timeInMilliseconds];
        
        NSNumber * applicationId = [NSNumber numberWithUnsignedLongLong:session.applicationId];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:applicationId  forKey:@"a"];
        [params setObject:session.userId forKey:@"u"];
        [params setObject:requestTime forKey:@"t"];
        [params setObject:@"ios" forKey:@"esrc"];
        [params setObject:session.sdkVersion forKey:@"ever"];
        [params setObject:frame.frameId forKey:@"f"];
        [params setObject:[NSNumber numberWithInt: screenSize.size.height] forKey:@"c"];
        [params setObject:[NSNumber numberWithInt: screenSize.size.width] forKey:@"d"];
        
        _url = [PNEventApiClient buildUrlWithBase:[session getMessagingUrl]
                                         withPath:@"ads"
                                       withParams:params];
        [params release];
    }
    return self;
}

-(void) dealloc{
    [_url release];
    [_frame release];
    
    if(_request){
        [_request cancel];
        [_request release];
    }
    [super dealloc];
}

-(void) fetchFrameData{
    _frame.state = PNFrameStateLoadingStarted;
    [PNLogger log:PNLogLevelDebug format:@"Fetching ad at %@", _url];
    _request = [[PNAssetRequest alloc] initWithUrl:_url delegate:self useHttpCache:NO];
    [_request start];
}

-(void) requestDidCompleteWithData:(NSData *)data{
    @try{
        PNFrameResponse *response = [[[PNFrameResponse alloc] initWithJSONData:data] autorelease];
        [_frame updateFrameResponse:response];
        [PNLogger log:PNLogLevelVerbose
               format:@"Successfully fetched frame data. JSON response %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
    }
    @catch(NSException *ex) {
        [PNLogger log:PNLogLevelWarning
            exception:ex
               format:@"Could load frame %@. Got exception while deserializing JSON response."];
        _frame.state = PNFrameStateLoadingFailed;
    }
}

-(void) requestDidFailtWithStatusCode:(int)statusCode{
    [PNLogger log:PNLogLevelWarning format:@"Could not load frame %@. Received HTTP status code %d.", _frame.frameId, statusCode];
    _frame.state = PNFrameStateLoadingFailed;
}

-(void) requestDidFailWithError:(NSError *)error{
    @try{
        [PNLogger log:PNLogLevelWarning
                error:error
               format:@"Could not load frame %@. Received error.", _frame.frameId];
        _frame.state = PNFrameStateLoadingFailed;
    }
    @catch(NSException *ex){
        [PNLogger log:PNLogLevelWarning exception:ex format:@"Could not handle requestDidFailWithError callback."];
    }
}

-(void) connectionDidFail{
    @try{
        [PNLogger log:PNLogLevelWarning
               format:@"Could not load frame %@. Connection could not be open.", _frame.frameId];
        _frame.state = PNFrameStateLoadingFailed;
    }
    @catch(NSException *ex){
        [PNLogger log:PNLogLevelWarning exception:ex format:@"Could not handle connectionDidFail callback."];
    }
}
@end
