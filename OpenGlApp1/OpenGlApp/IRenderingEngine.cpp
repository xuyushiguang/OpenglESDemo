////
////  IRenderingEngine.cpp
////  OpenGlApp
////
////  Created by xingye yang on 2021/12/25.
////
//
//#include "IRenderingEngine.hpp"
//
//
//struct Vertex{
//    float Position[2];
//    float Color[4];
//};
//
//const Vertex Vertices[] = {
//    {{-0.5,-0.866},{1,1,0.5,1}},
//    {{0.5,-0.866},{1,1,0.5,1}},
//    {{0,1},{1,1,0.5,1}},
//    {{-0.5,-0.866},{0.5,0.5,0.5,0}},
//    {{0.5,-0.866},{0.5,0.5,0.5,0}},
//    {{0,-0.4},{0.5,0.5,0.5,0}},
//};
//IRenderingEngine::IRenderingEngine(){
//    glGenRenderbuffersOES(1, &m_renderbuffer);
//    glBindRenderbufferOES(GL_RENDERBUFFER_OES, m_renderbuffer);
//}
//void IRenderingEngine::Initialize(int width, int height){
//    glGenFramebuffersOES(1, &m_framebuffer);
//    glBindFramebufferOES(GL_FRAMEBUFFER_OES, m_framebuffer);
//    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, m_renderbuffer);
//    glViewport(0, 0, width, height);
//    glMatrixMode(GL_PROJECTION);
//    const float maxX = 2;
//    const float MaxY = 3;
//    glOrthof(-maxX, +maxX, -MaxY, +MaxY, -1, -1);
//    glMatrixMode(GL_MODELVIEW);
//    OnRotate(DeviceOrientationPortrait);
//    m_currentAngle = m_desiredAngle;
//}
//
//void IRenderingEngine::Render() const
//{
//    glClearColor(0.5, 0.5, 0.5, 1);
//    glClear(GL_COLOR_BUFFER_BIT);
//    glPushMatrix();
//    glRotatef(m_currentAngle, 0, 0, 1);
//    glEnableClientState(GL_VERTEX_ARRAY);
//    glEnableClientState(GL_COLOR_ARRAY);
//    glVertexPointer(2, GL_FLOAT, sizeof(Vertex), &Vertices[0].Position[0]);
//    glColorPointer(4, GL_FLOAT, sizeof(Vertex), &Vertices[0].Color[0]);
//    GLsizei vertexCount = sizeof(Vertices)/sizeof(Vertex);
//    glDrawArrays(GL_TRIANGLES, 0, vertexCount);
//    glDisableClientState(GL_VERTEX_ARRAY);
//    glDisableClientState(GL_COLOR_ARRAY);
//    glPopMatrix();
//    
//}
//
//void IRenderingEngine::OnRotate(DeviceOrientation newOrientation)
//{
//    float angle = 0;
//    switch (newOrientation) {
//        case DeviceOrientationLandscapeLeft:
//            angle = 270;
//            break;
//        case DeviceOrientationPortraitUpsideDown:
//            angle = 180;
//            break;
//        case DeviceOrientationLandscapeRight:
//            angle = 90;
//            break;
//        default:
//            break;
//    }
////    m_currentAngle = angle;
//    m_desiredAngle = angle;
//}
//
//float IRenderingEngine::RotationDirection() const
//{
//    float delta = m_desiredAngle - m_currentAngle;
//    if (delta == 0) {
//        return 0;
//    }
//    bool count1 = ((delta > 0 && delta <= 180) || (delta < -180));
//    return count1 ? + 1 : -1;
//}
//
//void IRenderingEngine::UpdateAnimation(float timeStep)
//{
//    float direaction = RotationDirection();
//    if (direaction == 0) {
//        return;
//    }
//    float degrees = timeStep * 360 * RevolutionsPerSecond;
//    m_currentAngle += degrees * direaction;
//    if (m_currentAngle >= 360) {
//        m_currentAngle -= 360;
//    }else if (m_currentAngle < 0){
//        m_currentAngle += 360;
//    }
//    if (RotationDirection() != direaction) {
//        m_currentAngle = m_desiredAngle;
//    }
//}
