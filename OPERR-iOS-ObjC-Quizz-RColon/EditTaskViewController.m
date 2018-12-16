//
//  EditTaskViewController.m
//  OPERR-iOS-ObjC-Quizz-RColon
//
//  Created by Rafael Colon on 12/15/18.
//  Copyright © 2018 rafaelColon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EditTaskViewController.h"
#import "FirebaseManager.h"
#import <Toast/Toast.h>

@interface EditTaskViewController ()

@end

@implementation EditTaskViewController
@synthesize task;

- (void)viewDidLoad{
    [super viewDidLoad];
    self.taskMessageTextView.text = self.task.message;
}

- (IBAction)saveBtnClicked:(id)sender {
    if([self.task setMessageIfDiff:self.taskMessageTextView.text]){
        [[FirebaseManager sharedInstance] modifyTask:self.task withCompletion:^(NSError* error){
            if (error) {
                NSLog(@"Task could not be saved to Firebase: %@", error);
                [self.view makeToast:@"Error updating task!"];
            } else {
                [self.view makeToast:@"Task updated successfully."];
            }
        }];
    } else {
        [self.view makeToast:@"Nothing to save!"];
    }
}

- (IBAction)deleteBtnClicked:(id)sender {
    [[FirebaseManager sharedInstance] deleteTask:self.task withCompletion:^(NSError* error){
        if (error) {
            NSLog(@"Task could not be deleted from Firebase: %@", error);
            [self.view makeToast:@"Error deleting task!"];
        } else {
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }];
}



- (IBAction)doneBtnClicked:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
