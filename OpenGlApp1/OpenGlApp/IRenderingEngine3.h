//
//  IRenderingEngine.h
//  OpenGlApp
//
//  Created by xingye yang on 2021/12/25.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

@interface IRenderingEngine3 : NSObject
{
    GLuint m_framebuffer;
    GLuint m_renderbuffer;
    float m_currentAngle;
    float m_desiredAngle;
    GLuint m_simpleProgram;
}

-(void) Initialize:(int)width height:(int)height;
-(void) Render;
-(void) UpdateAnimation:(float)timeStep;
-(void) OnRotate:(UIDeviceOrientation)newOrientation;
-(float)RotationDirection;

-(GLuint)BuildShader:(const char *)soure shaderType:(GLenum)shaderType;
-(GLuint)BuildProgram:(const char*)vShader fShader:(char*)fShader;
-(void)AppleOrtho:(float)maxX maxY:(float)maxY;
-(void)ApplyRotation:(float)degrees;



@end

NS_ASSUME_NONNULL_END
