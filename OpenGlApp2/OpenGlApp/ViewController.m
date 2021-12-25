//
//  ViewController.m
//  OpenGlApp
//
//  Created by xingye yang on 2021/12/25.
//

#import "ViewController.h"
#import "YXYGlView.h"
#import "YXYGLView2.h"

@interface ViewController ()
{
    YXYGlView *glView;
    YXYGLView2 *glView2;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    glView = [[YXYGlView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    [self.view addSubview:glView];
    
    glView2 = [[YXYGLView2 alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:glView2];
    
}


@end
