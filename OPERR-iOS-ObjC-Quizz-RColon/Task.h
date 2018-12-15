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
@property(nonatomic, readwrite) NSString *message;
@property(nonatomic, readwrite) NSString *dateCreated;
@property(nonatomic, readwrite) NSString *taskId;
@end

#endif /* Task_h */
