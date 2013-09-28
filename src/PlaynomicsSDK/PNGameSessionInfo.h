//
//  PNPlayerSessionInfo.h
//  iosapi
//
//  Created by Jared Jenkins on 8/28/13.
//
//

#import <Foundation/Foundation.h>
#import "PNGeneratedHexId.h"

@interface PNGameSessionInfo : NSObject

@property (nonatomic, readonly) NSNumber *applicationId;
@property (nonatomic, readonly) NSString *userId;
@property (nonatomic, readonly) NSString *breadcrumbId;
@property (nonatomic, readonly) PNGeneratedHexId *sessionId;

-(id) initWithApplicationId:(unsigned long long)applicationId
                     userId:(NSString *) userId
               breadcrumbId:(NSString *) breadcrumbId
                  sessionId:(PNGeneratedHexId *)sessionId;

@end
