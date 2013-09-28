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
    id<PNFrameRequestDelegate> _delegate;
}

-(id) initWithFrame:(PNFrame *) frame
                url:(NSString *) requestUrl
           delegate:(id<PNFrameRequestDelegate>) delegate
{
    
    if((self = [super init])){
        _frame = [frame retain];
        _url = [requestUrl retain];
        _delegate = delegate;
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
    _request = [PNAssetRequest loadDataForUrl:_url delegate:self useHttpCache:NO];
    [_request start];
}

-(void) requestDidCompleteWithData:(NSData *)data{
    @try{
        PNFrameResponse *response = [[[PNFrameResponse alloc] initWithJSONData:data] autorelease];
        [_frame updateFrameResponse:response];
        [PNLogger log:PNLogLevelVerbose
               format:@"Successfully fetched frame data. JSON response %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
        [_delegate onFrameUrlCompleted: _url];
    }
    @catch(NSException *ex) {
        [PNLogger log:PNLogLevelWarning
            exception:ex
               format:@"Could load frame %@. Got exception while deserializing JSON response."];
        _frame.state = PNFrameStateLoadingFailed;
    }
   
}

-(void) requestDidFailWithStatusCode:(int)statusCode{
    [PNLogger log:PNLogLevelWarning format:@"Could not load frame %@. Received HTTP status code %d.", _frame.frameId, statusCode];
    _frame.state = PNFrameStateLoadingFailed;
    [_delegate onFrameUrlCompleted: _url];
}

-(void) requestDidFailWithError:(NSError *)error{
    @try{
        [PNLogger log:PNLogLevelWarning
                error:error
               format:@"Could not load frame %@. Received error.", _frame.frameId];
        _frame.state = PNFrameStateLoadingFailed;
        
        [_delegate onFrameUrlCompleted: _url];
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
        
        [_delegate onFrameUrlCompleted: _url];
    }
    @catch(NSException *ex){
        [PNLogger log:PNLogLevelWarning exception:ex format:@"Could not handle connectionDidFail callback."];
    }
}
@end
