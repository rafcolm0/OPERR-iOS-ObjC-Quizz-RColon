//
//  Task.h
//  OPERR-iOS-ObjC-Quizz-RColon
//
//  Created by Rafael Colon on 12/15/18.
//  Copyright © 2018 rafaelColon. All rights reserved.
//

#ifndef Task_h
#define Task_h
@import Firebase;
@interface Task:NSObject {
    NSString *message;
    NSString *dateCreated;
    NSString *taskId;
}

- (id)initWithFirebaseSnapshot:(FIRDataSnapshot *)snapshot;
- (id)initWithDescription:(NSString *)message andDate:(NSString*)formattedDate;
-(NSDictionary*)getFirebaseDictionaryReprensentation;

/**
 Custom setter for message field, that returns boolean for whether message was updated or not.
 @return BOOL YES iff self.message and parameter msg are diff and self.message was updated; NO, otherwise.
 */
-(BOOL)setMessageIfDiff:(NSString*)msg;
@property(nonatomic, readwrite) NSString *message;
@property(nonatomic, readwrite) NSString *dateCreated;
@property(nonatomic, readwrite) NSString *taskId;
@end

#endif /* Task_h */
