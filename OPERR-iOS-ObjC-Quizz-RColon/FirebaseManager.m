//
//  FirebaseManager.m
//  OPERR-iOS-ObjC-Quizz-RColon
//
//  Created by Rafael Colon on 12/14/18.
//  Copyright © 2018 rafaelColon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirebaseManager.h"

static FirebaseManager *shared = nil;

@implementation FirebaseManager
@synthesize dbRef;

- (instancetype)init
{
    self = [super init];
    if (self) {
       self.dbRef = [[FIRDatabase database] reference];
    }
    return self;
}

+ (id)shared{
    if (shared == nil) shared = [[FirebaseManager alloc] init];
    return shared;
}


@end
