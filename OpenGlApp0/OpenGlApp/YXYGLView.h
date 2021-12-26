//
//  YXYGlView.h
//  OpenGlApp
//
//  Created by xingye yang on 2021/12/25.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
//#import <OpenGLES/ES2/gl.h>
////#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>

#import "IRenderingEngine.h"


NS_ASSUME_NONNULL_BEGIN

@interface YXYGLView : UIView
{
    EAGLContext *m_context;
    
    IRenderingEngine * m_RenderingEngine;
    float m_timestamp;
}

-(void)drawView:(CADisplayLink *)displayLink;
-(void)didRotate:(NSNotification *)notifi;

@end

NS_ASSUME_NONNULL_END
