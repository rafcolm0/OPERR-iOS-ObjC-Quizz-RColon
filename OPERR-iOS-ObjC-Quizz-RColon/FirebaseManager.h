//
//  FirebaseManager.h
//  OPERR-iOS-ObjC-Quizz-RColon
//
//  Created by Rafael Colon on 12/14/18.
//  Copyright © 2018 rafaelColon. All rights reserved.
//

#ifndef FirebaseManager_h
#define FirebaseManager_h

#import "Task.h"
@import Firebase;
extern NSString *const NODE_MESSAGE;
extern NSString *const NODE_DATECREATED;
extern NSString *const NODE_TASKID;
@interface FirebaseManager : NSObject{
    FIRDatabaseReference *dbRef;
}

@property (strong, nonatomic, readwrite) FIRDatabaseReference *dbRef;

/**
 Initializes a FirebaseManager static shared instance.
 @return reference to static shared instance
 */
+ (id)sharedInstance;

/**
 Queries and returns through the completion block all current Tasks object from Firebase.
 @param completion completion block that returns an array with all the tasks and a {task_id, task_position} dictionary to be used in the ViewController to prevent duplicates and handle task modifications and deletion
 */
- (void)queryCurrentTasks:(void(^)(NSMutableArray* tasks, NSMutableDictionary* tasksKeyPositionDict))completion;

/**
 Initializes firebase data child observers to handle new data coming in, current data modification or deletion.
 @param newTaskListener callback for when a new task was added to firebase
 @param deletedTask callback for when a task was deleted from firebase
 @param editedTask callback for when a task was modified
 */
- (void)initializeTaskFirebaseObservers:(void(^)(Task* newTask))newTaskListener
                    deletedTaskListener:(void(^)(NSString* taskId))deletedTask
                    editedTaskListener:(void(^)(Task* editedTask))editedTask;

/**
 Pops and returns a new random key from the Firebase instance.  This key is used to uniquely indentify tasks.
 @return NSString with new Firebase key
 */
-(NSString*) getNewFirebaseTaskKey;

/**
 Sets a new node for the new parameter task and saves it to firebase.
 @param newTask new task to be saved
 @param completionListener callback after task was saved or if any error occurred
 */
- (void)saveTaskToFirebase:(Task*)newTask withCompletion:(void(^)(NSError* error))completionListener;

/**
 Overwrites existing task on Firebase with parameter task
 @param task Task to overwrite Firebase task with
 @param completionListener callback after task was updated or if any error occurred
 */
- (void)modifyTask:(Task*)task withCompletion:(void(^)(NSError* error))completionListener;

/**
 Deletes existing parameter task from Firebase
 @param task Task to delete from Firebase
 @param completionListener callback after task was deleted or if any error occurred
 */
- (void)deleteTask:(Task*)task withCompletion:(void(^)(NSError* error))completionListener;
@end
#endif /* FirebaseManager_h */
