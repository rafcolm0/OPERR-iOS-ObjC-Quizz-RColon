//
//  FirebaseManager.m
//  OPERR-iOS-ObjC-Quizz-RColon
//
//  Created by Rafael Colon on 12/14/18.
//  Copyright © 2018 rafaelColon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirebaseManager.h"
#import <UIKit/UIKit.h>
#import "Task.h"

@implementation FirebaseManager

NSString *const NODE_MESSAGE = @"message";
NSString *const NODE_DATECREATED = @"dateCreated";
NSString *const NODE_TASKID = @"taskId";

@synthesize dbRef;
static FirebaseManager *shared = nil;

- (instancetype)init{
    self = [super init];
    if (self) {
        //offline mode: a local persistent copy of this database reference will be kept on the device for offline use
        [FIRDatabase database].persistenceEnabled = true;
        /**
         For the purpose of this exercise, we are treating UUID as the user's unique Firebase node identifier.
         
         Since our Firebase instance is setup with a test database, no Firebase authentication is required to read/write. However, in a real case scenario, the Firebase database would be secured and restrict access to each user's respective/relevant firebase nodes only. Thus, in this real scenario security, we would have used "[FIRAuth auth].currentUser.uid" as the authenticated user's unique identifier instead of UUID.
         
         See README.md file for more details on how Firebase nodes are structured.
         **/
        NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        self.dbRef = [[[[FIRDatabase database] reference] child:@"users"] child:uniqueIdentifier];
        //ensures local persistent firebase database is always updated and in-synced with the cloud Firebase instance
        [self.dbRef keepSynced:YES];
    }
    return self;
}

+ (id)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{  //thread safety when initializing static shared instance
        if (shared == nil) shared = [[FirebaseManager alloc] init];
    });
    return shared;
}

- (void)initializeTaskFirebaseObservers:(void(^)(Task* newTask))newTaskListener
                    deletedTaskListener:(void(^)(NSString* taskId))deletedTask
                     editedTaskListener:(void(^)(Task* editedTask))editedTask{
    [self.dbRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        if([snapshot exists]){  //if actual existent task data is found, handle it
            Task *newTask = [[Task alloc] initWithFirebaseSnapshot:snapshot];
            newTaskListener(newTask);
        }
        //normally when [snapshot exits] is false, we would send some error logging to Crashlytics and/or display a message if needed
    }];
    [self.dbRef observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot *snapshot) {
        deletedTask(snapshot.key);  //just pass key to delete callback
    }];
    [self.dbRef observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot) {
        if([snapshot exists]){  //if actual existent task data is found, handle it
            Task *updatedTask = [[Task alloc] initWithFirebaseSnapshot:snapshot];
            editedTask(updatedTask);
        }
        //normally when [snapshot exits] is false, we would send some error logging to Crashlytics and/or display a message if needed
    }];
}

- (void)queryCurrentTasks:(void(^)(NSMutableArray* tasks, NSMutableDictionary* tasksKeyPositionDict))completion{
    [[self.dbRef queryOrderedByKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        // enumerator to loop through all current user tasks nodes
        NSEnumerator *children = [snapshot children];
        FIRDataSnapshot *child;
        NSMutableArray *tasks = [[NSMutableArray alloc] init];
        NSMutableDictionary *tasksKeyToIndexDict = [[NSMutableDictionary alloc] init];
        int index = 0;
        while (child = [children nextObject]) {
            //serialized snapshot into a Task object
            Task *task = [[Task alloc] initWithFirebaseSnapshot:child];
            if(task != nil){  //if valid task, save it to data source
                [tasksKeyToIndexDict setValue:[NSNumber numberWithInteger:index] forKey:task.taskId];
                [tasks addObject:task];
                index++;
            }
        }
        completion(tasks, tasksKeyToIndexDict);
    }];
}

-(NSString*) getNewFirebaseTaskKey{
    return [[self.dbRef childByAutoId] key];
}

- (void)saveTaskToFirebase:(Task*)newTask withCompletion:(void(^)(NSError* error))completionListener{
    newTask.taskId = [self getNewFirebaseTaskKey];  //set unique key for new task
    //get task dictionary representation for Firebase
    //note: parameter newTask could have been directly a NSDictionary instead of a Task; but just for clarity we generate map
    NSDictionary *dict = [newTask getFirebaseDictionaryReprensentation];
    //set node value for new task and call to completion handler
    [[self.dbRef child:newTask.taskId] setValue:dict withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        completionListener(error);
    }];
}

- (void)modifyTask:(Task*)task withCompletion:(void(^)(NSError* error))completionListener{
    NSDictionary *dict = [task getFirebaseDictionaryReprensentation];
    //set node value for new task and call to completion handler
    [[self.dbRef child:task.taskId] setValue:dict withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        completionListener(error);
    }];
}

- (void)deleteTask:(Task*)task withCompletion:(void(^)(NSError* error))completionListener{
    [[self.dbRef child:task.taskId] removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        completionListener(error);
    }];
}

@end
