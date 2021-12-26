//
//  YXYGLView.m
//  OpenGlApp
//
//  Created by xingye yang on 2021/12/25.
//

#import "YXYGLView.h"
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
//#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>


@interface YXYGLView ()

@end

@implementation YXYGLView

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
        CAEAGLLayer *eaglLayer = (CAEAGLLayer*)self.layer;
        eaglLayer.opaque = YES;
        m_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!m_context || ![EAGLContext setCurrentContext:m_context]) {
            return nil;
        }
        
        m_RenderingEngine = [[IRenderingEngine alloc] init];
        
        m_applicationEngine = [[ApplicationEngin alloc] initWithrender:m_RenderingEngine];
        

        [m_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
        
//        [m_RenderingEngine Initialize:CGRectGetWidth(frame) height:CGRectGetHeight(frame)];
        int width = CGRectGetWidth(frame);
        int height = CGRectGetHeight(frame);
        [m_applicationEngine Initialize:width height:height];
        
        [self drawView:nil];
        
        m_timestamp = CACurrentMediaTime();
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        
        
    }
    return self;
}


-(void)drawView:(CADisplayLink *)displayLink
{
//    glClearColor(0.5, 0.5, 0.5, 1);
//    glClear(GL_COLOR_BUFFER_BIT);
//    [m_context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
    if (displayLink != nil) {
        float elapsedSeconds = displayLink.timestamp - m_timestamp;
        m_timestamp = displayLink.timestamp;
        [m_applicationEngine UpdateAnimation:elapsedSeconds];
    }
    
    [m_applicationEngine Render];
    [m_context presentRenderbuffer:GL_RENDERBUFFER];
}



- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event
{
    UITouch* touch = [touches anyObject];
    CGPoint location  = [touch locationInView: self];
    [m_applicationEngine OnFingerDown:location];
}

- (void) touchesEnded: (NSSet*) touches withEvent: (UIEvent*) event
{
    UITouch* touch = [touches anyObject];
    CGPoint location  = [touch locationInView: self];
    [m_applicationEngine OnFingerUp:location];
}

- (void) touchesMoved: (NSSet*) touches withEvent: (UIEvent*) event
{
    UITouch* touch = [touches anyObject];
    CGPoint previous  = [touch previousLocationInView: self];
    CGPoint current = [touch locationInView: self];
    [m_applicationEngine OnFingerMove:previous newLocation:current];
}


@end
