//
//  ViewController.m
//  NSThreadDemo
//
//  Created by ChangChao-Tang on 2015/7/4.
//  Copyright (c) 2015年 ChangChao-Tang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UILabel *counter1Lb;

@property (strong, nonatomic) IBOutlet UILabel *counter2Lb;

@property (strong, nonatomic) IBOutlet UIButton *stop1Btn;

@property (strong, nonatomic) IBOutlet UIButton *stop2Btn;



@end

@implementation ViewController
{
    NSThread * _thread1;
    NSThread * _thread2;
    NSMutableArray *_arr;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     Setup _thread1 and _thread2 with their enter method
    */
    _thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(thread1Routine) object:nil];
    _thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(thread2Routine) object:nil];
    
    _arr = [NSMutableArray new];
}

-(void)thread1Routine{
    //Create a autoReleasePool for _thread1
    @autoreleasepool {
        //Hold the pointer of current thread, which means _thread1
        NSThread * curThread = [NSThread currentThread];
        //Hold the pointer of current runloop
        NSRunLoop * curRunloop = [NSRunLoop currentRunLoop];
        
        int counter = 0;
        //Run the loop while current thread is not cancelled
        while (curThread.isCancelled == NO) {
            counter += 1;
            
            //Back to main thread to update GUI
            dispatch_async(dispatch_get_main_queue(), ^{
                _counter1Lb.text = [NSString stringWithFormat:@"%d",(counter * 2) - 1];
            });
            
            //Force current thread to sleep 0.5 sec
            usleep(500000);
            
            //Wait input source
            if ([curRunloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
                
            }
        }
        [NSThread exit];
    }
}

-(void)thread2Routine{
    //Create a autoReleasePool for _thread2
    @autoreleasepool {
        //Hold the pointer of current thread, which means _thread2
        NSThread * curThread = [NSThread currentThread];
        //Hold the pointer of current runloop
        NSRunLoop * curRunloop = [NSRunLoop currentRunLoop];
        
        int counter;
        //Run the loop while current thread is not cancelled
        while (curThread.isCancelled == NO) {
            counter += 1;
            
            //Back to main thread to update GUI
            dispatch_async(dispatch_get_main_queue(), ^{
                _counter2Lb.text = [NSString stringWithFormat:@"%d",(counter * 2)];
            });
            //Force current thread to sleep 0.5 sec
            usleep(500000);
            //Wait input source
            if ([curRunloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
                
            }
        }
        [NSThread exit];
    }
}

-(void)thread1Job{
    
    NSDate * startDate = [NSDate date];
    while ([[NSDate date]timeIntervalSinceDate:startDate] < 10) {
        @synchronized(_arr){
            
            [_arr addObject:[NSNumber numberWithInt:10]];
            NSLog(@"%@", _arr);
            usleep(500000);
        }
    }
    
}

-(void)thread2Job{
    
    NSDate * startDate = [NSDate date];
    while ([[NSDate date]timeIntervalSinceDate:startDate] < 10) {
        @synchronized(_arr){
            
            [_arr insertObject:[NSNumber numberWithInt:0] atIndex:0];
            NSLog(@"%@", [_arr description]);
            usleep(500000);
        }
    }
    
}

- (IBAction)thread1Start:(UIButton*)sender {
    sender.enabled = NO;
    [_thread1 start];
    self.stop1Btn.enabled = YES;
}

- (IBAction)stop1:(UIButton *)sender {
    [_thread1 cancel];
}


- (IBAction)thread2Start:(UIButton*)sender {
    sender.enabled = NO;
    [_thread2 start];
    self.stop2Btn.enabled = YES;
}


- (IBAction)stop2:(UIButton *)sender {
    [_thread2 cancel];
}


- (IBAction)safetyBtnPressed:(id)sender {
    
    [self performSelector:@selector(thread1Job) onThread:_thread1 withObject:nil waitUntilDone:NO];
    [self performSelector:@selector(thread2Job) onThread:_thread2 withObject:nil waitUntilDone:NO];
}



@end
