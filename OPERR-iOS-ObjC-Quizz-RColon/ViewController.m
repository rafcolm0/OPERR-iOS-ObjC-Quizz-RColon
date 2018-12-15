//
//  ViewController.m
//  OPERR-iOS-ObjC-Quizz-RColon
//
//  Created by Rafael Colon on 12/14/18.
//  Copyright © 2018 rafaelColon. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"
#import "FirebaseManager.h"
#import "Task.h"
#import <Toast/Toast.h>
#import "EditTaskViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize currentTasks, tasksKeyPositionDict;

/*
 We implemented 2 METHODS for quering task data from our Firebase database below on viewDidLoad:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     METHOD 1: query tasks one by one, and load them into the tableview one by one, asynchronously
     */
    [SVProgressHUD show];  //show minimalistic HUD progress indicator for when loading data
    self.currentTasks = [[NSMutableArray alloc] init];  //init task data sources
    self.tasksKeyPositionDict = [[NSMutableDictionary alloc] init];
    [self initTaskListSyncing];  //initialize task firebase observers for .childAdded, .childRemoved & .childModified
    [SVProgressHUD dismiss];  //hide progress indicator
    
    /*
     METHOD 2: query all tasks currently in the database first, and THEN initialize firebase data child observers to handle new data coming in, current data modification or deletion.  Commented code snippet below, calls the query method to get all tasks, populates the tableview once with all the data, and then initializes the data change observers.
     
     A problem with this method is that it technically has twice the running time of METHOD 1.  However, since all the callback procedures run in the background, the main UI thread is not affecred, and the HUD loading indicator will actually bee shown to let the user know that data is been handled.
     */
//    [SVProgressHUD show];
//    [[FirebaseManager sharedInstance] queryCurrentTasks:^(NSMutableArray* tasks, NSMutableDictionary* tasksKeyPositionDict) {
//        self.currentTasks = tasks;
//        self.tasksKeyPositionDict = tasksKeyPositionDict;
//        if(tasks.count > 0){
//            [self.taskTableView reloadData];
//        } else {
//            [self.view makeToast:@"No tasks have been created yet!"];
//        }
//        [SVProgressHUD dismiss];
//        [self initTaskListSyncing];
//    }];
}

-(void) initTaskListSyncing{
    [[FirebaseManager sharedInstance] initializeTaskFirebaseObservers:^(Task* newTask){  //callback for new task added
        //if statement below is needed for METHOD 2: prevents duplicate tasks from been listed when viewDidLoad is called
        if([self.tasksKeyPositionDict valueForKey:newTask.taskId] == nil){
            [self.currentTasks addObject:newTask];  //add task to data sources and tableview
            NSInteger index = self.currentTasks.count-1;  //new task position is always last
            [self.tasksKeyPositionDict setValue:[NSNumber numberWithInteger:index] forKey:newTask.taskId];
            [self.taskTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.currentTasks.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } deletedTaskListener:^(NSString* deletedTaskId){  //callback for when a task is deleted
        //get tableview position for task with id deletedTaskId from datasource dictionary
        NSNumber *position = [self.tasksKeyPositionDict valueForKey:deletedTaskId];
        if(position != nil){  //if task with id found, delete it
            [self.currentTasks removeObjectAtIndex:position.integerValue];
            [self.taskTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:position.intValue inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } editedTaskListener:^(Task* editedTask){  //callback for when a task is modified
        //get tableview position for editedTask
        NSNumber *position = [self.tasksKeyPositionDict valueForKey:editedTask.taskId];
        if(position != nil){ //if task with id found, replace it with editedTask
            [self.currentTasks replaceObjectAtIndex:position.intValue withObject:editedTask];
            [self.taskTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:position.integerValue inSection:0]] withRowAnimation: UITableViewRowAnimationNone];
        }
    }];
}

- (IBAction)addTaskBtnClicked:(id)sender {
    if([self.taskTextField hasText]){  //checks textfield is not empty
        NSString *taskText = [NSString stringWithString:self.taskTextField.text];
        //init now date and time in string format
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
        NSDate *currentDate = [NSDate date];
        NSString *dateString = [formatter stringFromDate:currentDate];
        //creates task with message and formatted date
        Task *task = [[Task alloc] initWithDescription:taskText andDate:dateString];
        //saves task to Firebase, and handle any error (if any)
        [[FirebaseManager sharedInstance] saveTaskToFirebase:task withCompletion:^(NSError* error){
            if (error) {
                NSLog(@"Task could not be saved to Firebase: %@", error);
                [self.view makeToast:@"Error creating task!"];
            } else {
                [self.view makeToast:@"Task created successfully."];
            }
        }];
    } else {
        [self.view makeToast:@"Task description cannot be empty!"];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"taskCell";
    Task *task = [self.currentTasks objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:cellId];
    }
    cell.textLabel.text = task.message;
    cell.detailTextLabel.text = task.dateCreated;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.currentTasks != nil ? self.currentTasks.count : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showEditTaskView" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showEditTaskView"]){
        EditTaskViewController *editTaskVC = (EditTaskViewController*) segue.destinationViewController;
        editTaskVC.task = [self.currentTasks objectAtIndex:((NSIndexPath*)sender).row];
    }
}

@end
