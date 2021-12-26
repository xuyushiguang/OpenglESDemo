//
//  IRenderingEngine2.h
//  OpenGlApp
//
//  Created by xingye yang on 2021/12/25.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


NS_ASSUME_NONNULL_BEGIN

@interface IRenderingEngine2 : NSObject
{
    GLuint m_framebuffer;
    GLuint m_colorRenderbuffer;
    GLuint m_depthRenderbuffer;
}

-(void) Initialize:(int)width height:(int)height;
-(void) Render;
-(void) UpdateAnimation:(float)timeStep;
-(void) OnRotate:(UIDeviceOrientation)newOrientation;

-(float)RotationDirection;

-(void)OnFindUp:(CGPoint)point;
-(void)OnFindDown:(CGPoint)point;
-(void)OnFindMove:(CGPoint)point point2:(CGPoint)point2;

@end

NS_ASSUME_NONNULL_END
