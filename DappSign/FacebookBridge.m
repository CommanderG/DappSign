//
//  FacebookBridge.m
//  DappSign
//
//  Created by Leo on 2/4/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

#import "FacebookBridge.h"
#import <FacebookSDK/FBOpenGraphAction.h>


@implementation FacebookBridge

- (id<FBOpenGraphAction>) graphObject{
    return (id<FBOpenGraphAction>)[FBGraphObject graphObject];
}

@end
