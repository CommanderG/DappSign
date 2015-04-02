//
//  FacebookBridge.h
//  DappSign
//
//  Created by Leo on 2/4/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FBOpenGraphAction.h>


@interface FacebookBridge : NSObject

- (id<FBOpenGraphAction>) graphObject;

@end
