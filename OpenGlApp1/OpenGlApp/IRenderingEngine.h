//
//  IRenderingEngine.h
//  OpenGlApp
//
//  Created by xingye yang on 2021/12/25.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    DeviceOrientationUnkonw,
    DeviceOrientationPortrait,
    DeviceOrientationPortraitUpsideDown,
    DeviceOrientationLandscapeLeft,
    DeviceOrientationLandscapeRight,
    DeviceOrientationFaceUp,
    DeviceOrientationFaceDown,
} DeviceOrientation;


static const float RevolutionsPerSecond = 1;


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
-(void) OnRotate:(DeviceOrientation)newOrientation;

-(float)RotationDirection;

@end

NS_ASSUME_NONNULL_END
