//
//  ViewController.m
//  OpenGlApp
//
//  Created by xingye yang on 2021/12/25.
//

#import "ViewController.h"

#import "YXYGLView.h"


@interface ViewController ()
{
    
    YXYGLView *glView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    glView = [[YXYGLView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:glView];
    
}


@end
