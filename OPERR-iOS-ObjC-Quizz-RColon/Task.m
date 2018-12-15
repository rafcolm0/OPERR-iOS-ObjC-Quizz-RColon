//
//  Task.m
//  OPERR-iOS-ObjC-Quizz-RColon
//
//  Created by Rafael Colon on 12/15/18.
//  Copyright © 2018 rafaelColon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"
#import "FirebaseManager.h"

@implementation Task

@synthesize message, dateCreated, taskId;

-(id)init {
    self = [super init];
    return self;
}

- (id)initWithFirebaseSnapshot:(FIRDataSnapshot *)snapshot {
    self = [super init];
    if (self) {
        self.taskId = snapshot.key;
        self.message = [snapshot.value valueForKey:NODE_MESSAGE];
        self.dateCreated = [snapshot.value valueForKey:NODE_DATECREATED];
    }
    return self;
}

- (id)initWithDescription:(NSString *)message andDate:(NSString*)formattedDate{
    self = [super init];
    if (self) {
        self.message = message;
        self.dateCreated = formattedDate;
    }
    return self;
}

-(NSDictionary*)getFirebaseDictionaryReprensentation{
    NSDictionary *dict = @{NODE_MESSAGE: self.message,
                           NODE_DATECREATED: self.dateCreated};
    return dict;
}

-(BOOL)setMessageIfDiff:(NSString*)msg{
    if(self.message != nil && msg != nil && ![message isEqualToString:msg]){
        self.message = [NSString stringWithString:msg];
        return true;
    }
    return false;
}

@end
