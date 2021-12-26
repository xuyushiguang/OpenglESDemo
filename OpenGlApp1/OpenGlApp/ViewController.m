//
//  ViewController.m
//  OpenGlApp
//
//  Created by xingye yang on 2021/12/25.
//

#import "ViewController.h"
#import "YXYGlView.h"
#import "YXYGLView2.h"
#import "YXYGlView3.h"

@interface ViewController ()
{
    YXYGlView *glView;
    YXYGLView2 *glView2;
    YXYGlView3 *glView3;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    glView = [[YXYGlView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    [self.view addSubview:glView];
    
//    glView2 = [[YXYGLView2 alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    [self.view addSubview:glView2];
    
    glView3 = [[YXYGlView3 alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:glView3];
    
}


@end
