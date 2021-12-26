//
//  ApplicationEngin.h
//  OpenGlApp
//
//  Created by xingye yang on 2021/12/26.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ApplicationEngin : NSObject

- (instancetype)initWithrender:(id)reder;
-(void) Initialize:(int)width height:(int)height;
-(void) Render;
-(void) UpdateAnimation:(float)timeStep;
-(void) OnFingerUp:(CGPoint)location;
-(void) OnFingerDown:(CGPoint)location;
-(void) OnFingerMove:(CGPoint) oldLocation newLocation:(CGPoint) newLocation;

@end


@interface IRenderingEngine : NSObject
{
    
}

//-(void) Initialize:(int)width height:(int)height;
//-(void) Render;

@end

NS_ASSUME_NONNULL_END
