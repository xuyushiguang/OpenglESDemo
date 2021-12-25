//
//  IRenderingEngine.h
//  OpenGlApp
//
//  Created by xingye yang on 2021/12/25.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

NS_ASSUME_NONNULL_BEGIN





@interface IRenderingEngine : NSObject
{
    GLuint m_framebuffer;
    GLuint m_renderbuffer;
    float m_currentAngle;
    
    float m_desiredAngle;
}

-(void) Initialize:(int)width height:(int)height;
-(void) Render;
-(void) UpdateAnimation:(float)timeStep;
-(void) OnRotate:(UIDeviceOrientation)newOrientation;

-(float)RotationDirection;

@end

NS_ASSUME_NONNULL_END
