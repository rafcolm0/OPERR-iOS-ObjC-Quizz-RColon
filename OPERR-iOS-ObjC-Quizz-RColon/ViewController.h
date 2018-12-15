//
//  ViewController.h
//  OPERR-iOS-ObjC-Quizz-RColon
//
//  Created by Rafael Colon on 12/14/18.
//  Copyright © 2018 rafaelColon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *currentTasks;
    NSMutableDictionary *tasksKeyPositionDict;
}
@property (weak, nonatomic) IBOutlet UITextField *taskTextField;
@property (weak, nonatomic) IBOutlet UITableView *taskTableView;
@property (strong, nonatomic, readwrite) NSMutableArray *currentTasks;
@property (strong, nonatomic, readwrite) NSMutableDictionary *tasksKeyPositionDict;

@end

