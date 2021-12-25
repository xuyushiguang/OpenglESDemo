////
////  IRenderingEngine.hpp
////  OpenGlApp
////
////  Created by xingye yang on 2021/12/25.
////
//
//#ifndef IRenderingEngine_hpp
//#define IRenderingEngine_hpp
//
//#include <stdio.h>
//#include <stdlib.h>
//#include <string.h>
//#include <OpenGLES/ES1/gl.h>
//#include <OpenGLES/ES1/glext.h>
//
//static const float RevolutionsPerSecond = 1;
//
//enum  DeviceOrientation {
//    DeviceOrientationUnkonw,
//    DeviceOrientationPortrait,
//    DeviceOrientationPortraitUpsideDown,
//    DeviceOrientationLandscapeLeft,
//    DeviceOrientationLandscapeRight,
//    DeviceOrientationFaceUp,
//    DeviceOrientationFaceDown,
//} ;
//
////struct IRenderingEngine{
////   virtual void Initialize(int width,int height);
////    virtual void Render(void) ;
////    virtual void UpdateAnimation(float timeStep);
////    virtual  void OnRotate(enum DeviceOrientation newOrientation) ;
//////    virtual  ~IRenderingEngine();
////};
//
//class IRenderingEngine
//{
//public:
//    IRenderingEngine();
//    void Initialize(int width,int height);
//    void Render() const;
//    void UpdateAnimation(float timeStep);
//    void OnRotate(DeviceOrientation newOrientation);
//private:
//    GLuint m_framebuffer;
//    GLuint m_renderbuffer;
//    float m_currentAngle;
//    float RotationDirection()const;
//    float m_desiredAngle;
//};
//
//
////IRenderingEngine *CreateRender1(){
////    return new IRenderingEngine();
////}
//
//
//#endif /* IRenderingEngine_hpp */
