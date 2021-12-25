//
//  YXYGlView.m
//  OpenGlApp
//
//  Created by xingye yang on 2021/12/25.
//

#import "YXYGlView.h"
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
//#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>

//#import "IRenderingEngine.hpp"
//#include "IRenderingEngine1.cpp"

@interface YXYGlView ()

@end

@implementation YXYGlView

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (void)dealloc
{
    if ([EAGLContext currentContext] == m_context) {
        [EAGLContext setCurrentContext:nil];
    }
//    [m_context release];
//    [super dealloc];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer*)super.layer;
        eaglLayer.opaque = YES;
        m_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        if (!m_context || ![EAGLContext setCurrentContext:m_context]) {
            return nil;
        }
        
        m_RenderingEngine = [[IRenderingEngine alloc] init];
        
//        GLuint framebuffer,renderbuffer;
//        glGenFramebuffersOES(1, &framebuffer);
//        glGenRenderbuffersOES(1, &renderbuffer);
//
//        glBindFramebufferOES(GL_FRAMEBUFFER_OES, framebuffer);
//        glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderbuffer);
        [m_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:eaglLayer];
        [m_RenderingEngine Initialize:CGRectGetWidth(frame) height:CGRectGetHeight(frame)];
        [self drawView:nil];
        m_timestamp = CACurrentMediaTime();
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
//        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, renderbuffer);
//        glViewport(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
//        [self drawView];
        
    }
    return self;
}


-(void)drawView:(CADisplayLink *)displayLink
{
//    glClearColor(0.5, 0.5, 0.5, 1);
//    glClear(GL_COLOR_BUFFER_BIT);
//    [m_context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
    if (displayLink != nil) {
        float elapsedSecond = displayLink.timestamp - m_timestamp;
        m_timestamp = displayLink.timestamp;
        [m_RenderingEngine UpdateAnimation:elapsedSecond];
    }
    [m_RenderingEngine Render];
    [m_context presentRenderbuffer:GL_RENDERBUFFER_OES];
}
-(void)didRotate:(NSNotification *)notifi
{
    UIDeviceOrientation oriention = [[UIDevice currentDevice] orientation];
    [m_RenderingEngine OnRotate:oriention];
    [self drawView:nil];
}

@end
