//
//  FirebaseManager.h
//  OPERR-iOS-ObjC-Quizz-RColon
//
//  Created by Rafael Colon on 12/14/18.
//  Copyright © 2018 rafaelColon. All rights reserved.
//

#ifndef FirebaseManager_h
#define FirebaseManager_h

@import Firebase;
@interface FirebaseManager : NSObject{
    FIRDatabaseReference *dbRef;
}

@property (strong, nonatomic) FIRDatabaseReference *dbRef;
+ (id)shared;

@end
#endif /* FirebaseManager_h */
