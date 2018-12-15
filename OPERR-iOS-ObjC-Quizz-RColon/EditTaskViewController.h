//
//  EditTaskViewController.h
//  OPERR-iOS-ObjC-Quizz-RColon
//
//  Created by Rafael Colon on 12/15/18.
//  Copyright © 2018 rafaelColon. All rights reserved.
//

#ifndef EditTaskViewController_h
#define EditTaskViewController_h
#import <UIKit/UIKit.h>
#import "Task.h"

@interface EditTaskViewController : UIViewController <UITextViewDelegate>{
    Task *task;
}

@property (weak, nonatomic) IBOutlet UITextView *taskMessageTextView;
@property (strong, nonatomic, readwrite) Task *task;

@end

#endif /* EditTaskViewController_h */
