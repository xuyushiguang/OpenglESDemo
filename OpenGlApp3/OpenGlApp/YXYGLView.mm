//
//  YXYGLView.m
//  OpenGlApp
//
//  Created by xingye yang on 2021/12/26.
//

#import "YXYGLView.h"
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>
//#import <OpenGLES/ES2/gl.h>
////#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>

#import "Interfaces.hpp"


//#import <OpenGLES/ES2/gl.h>
//#import <OpenGLES/ES1/glext.h>
//#import <QuartzCore/QuartzCore.h>


#define GL_RENDERBUFFER 0x8d41

@interface YXYGLView ()
{
    EAGLContext *m_context;
    IApplicationEngine* m_applicationEngine;
    IRenderingEngine* m_renderingEngine;
    float m_timestamp;
}
@end


@implementation YXYGLView

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CAEAGLLayer* eaglLayer = (CAEAGLLayer*) self.layer;
        eaglLayer.opaque = YES;

        EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
        m_context = [[EAGLContext alloc] initWithAPI:api];
        
        if (!m_context) {
            api = kEAGLRenderingAPIOpenGLES1;
            m_context = [[EAGLContext alloc] initWithAPI:api];
        }
        
        if (!m_context || ![EAGLContext setCurrentContext:m_context]) {
            
            return nil;
        }

        if (api == kEAGLRenderingAPIOpenGLES1) {
            NSLog(@"Using OpenGL ES 1.1");
            m_renderingEngine = SolidES1::CreateRenderingEngine();
        } else {
            NSLog(@"Using OpenGL ES 2.0");
            m_renderingEngine = SolidES2::CreateRenderingEngine();
        }

       m_applicationEngine = ParametricViewer::CreateApplicationEngine(m_renderingEngine);

        [m_context
            renderbufferStorage:GL_RENDERBUFFER
            fromDrawable: eaglLayer];
                
        int width = CGRectGetWidth(frame);
        int height = CGRectGetHeight(frame);
        m_applicationEngine->Initialize(width, height);
        
        [self drawView: nil];
        m_timestamp = CACurrentMediaTime();
        
        CADisplayLink* displayLink;
        displayLink = [CADisplayLink displayLinkWithTarget:self
                                     selector:@selector(drawView:)];
        
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                     forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (void) drawView: (CADisplayLink*) displayLink
{
    if (displayLink != nil) {
        float elapsedSeconds = displayLink.timestamp - m_timestamp;
        m_timestamp = displayLink.timestamp;
        m_applicationEngine->UpdateAnimation(elapsedSeconds);
    }
    
    m_applicationEngine->Render();
    [m_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event
{
    UITouch* touch = [touches anyObject];
    CGPoint location  = [touch locationInView: self];
    m_applicationEngine->OnFingerDown(ivec2(location.x, location.y));
}

- (void) touchesEnded: (NSSet*) touches withEvent: (UIEvent*) event
{
    UITouch* touch = [touches anyObject];
    CGPoint location  = [touch locationInView: self];
    m_applicationEngine->OnFingerUp(ivec2(location.x, location.y));
}

- (void) touchesMoved: (NSSet*) touches withEvent: (UIEvent*) event
{
    UITouch* touch = [touches anyObject];
    CGPoint previous  = [touch previousLocationInView: self];
    CGPoint current = [touch locationInView: self];
    m_applicationEngine->OnFingerMove(ivec2(previous.x, previous.y),
                                      ivec2(current.x, current.y));
}

@end

namespace FacetedES2 { IRenderingEngine* CreateRenderingEngine() { return 0; } }
namespace SolidGL2 { IRenderingEngine* CreateRenderingEngine() { return 0; } }
namespace TexturedGL2 { IRenderingEngine* CreateRenderingEngine() { return 0; } }

namespace SolidES1 { IRenderingEngine* CreateRenderingEngine() { return 0; } }
