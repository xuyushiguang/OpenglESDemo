//
//  ViewController.m
//  OpenGlApp
//
//  Created by xingye yang on 2021/12/25.
//

#import "ViewController.h"
#import "YXYGlView.h"

@interface ViewController ()
{
    YXYGlView *glView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    glView = [[YXYGlView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:glView];
    
}


@end
