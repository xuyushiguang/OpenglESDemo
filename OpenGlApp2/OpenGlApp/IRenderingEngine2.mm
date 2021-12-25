//
//  IRenderingEngine2.m
//  OpenGlApp
//
//  Created by xingye yang on 2021/12/25.
//

#import "IRenderingEngine2.h"
#include "Quaternion.hpp"
#include <vector>


struct Animation {
    Quaternion Start;
    Quaternion End;
    Quaternion Current;
    float Elapsed;
    float Duration;
};

typedef Animation Animation;


static const float RevolutionsPerSecond = 1;
static const float AnimationDuration = 0.25f;

struct Vertex{
    vec3 Position;
    vec4 Color;
};

typedef struct Vertex Vertex;

@interface IRenderingEngine2 ()
{
    std::vector<Vertex> m_cone;
    std::vector<Vertex> m_disk;
    Animation m_animation;
    
    GLfloat m_rotationAngle;
    GLfloat m_scale;
    ivec2 m_pivotPoint;
}
@end

@implementation IRenderingEngine2

- (instancetype)init
{
    self = [super init];
    if (self) {
        m_rotationAngle = 0;
        m_scale = 1;
        
        glGenRenderbuffersOES(1, &m_colorRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, m_colorRenderbuffer);
    }
    return self;
}

-(void) Initialize:(int)width height:(int)height
{
    m_pivotPoint = ivec2(width/2,height/2);
    
    const float coneRadius = 0.5f;
    const float coneHeight = 1.866f;
    const int coneSlices = 40;
    
    {
        // Allocate space for the cone vertices.
        m_cone.resize((coneSlices + 1) * 2);
        
        // Initialize the vertices of the triangle strip.
        std::vector<Vertex>::iterator vertex = m_cone.begin();
        const float dtheta = TwoPi / coneSlices;
        for (float theta = 0; vertex != m_cone.end(); theta += dtheta) {
            
            // Grayscale gradient
            float brightness = abs(sin(theta));
            vec4 color(brightness, brightness, brightness, 1);
            
            // Apex vertex
            vertex->Position = vec3(0, 1, 0);
            vertex->Color = color;
            vertex++;
            
            // Rim vertex
            vertex->Position.x = coneRadius * cos(theta);
            vertex->Position.y = 1 - coneHeight;
            vertex->Position.z = coneRadius * sin(theta);
            vertex->Color = color;
            vertex++;
        }
    }
    {
        // Allocate space for the disk vertices.
        m_disk.resize(coneSlices + 2);
        
        // Initialize the center vertex of the triangle fan.
        std::vector<Vertex>::iterator vertex = m_disk.begin();
        vertex->Color = vec4(0.75, 0.75, 0.75, 1);
        vertex->Position.x = 0;
        vertex->Position.y = 1 - coneHeight;
        vertex->Position.z = 0;
        vertex++;
        
        // Initialize the rim vertices of the triangle fan.
        const float dtheta = TwoPi / coneSlices;
        for (float theta = 0; vertex != m_disk.end(); theta += dtheta) {
            vertex->Color = vec4(0.75, 0.75, 0.75, 1);
            vertex->Position.x = coneRadius * cos(theta);
            vertex->Position.y = 1 - coneHeight;
            vertex->Position.z = coneRadius * sin(theta);
            vertex++;
        }
    }
    // Create the depth buffer.
    glGenRenderbuffersOES(1, &m_depthRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, m_depthRenderbuffer);
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES,
                             GL_DEPTH_COMPONENT16_OES,
                             width,
                             height);
    
    // Create the framebuffer object; attach the depth and color buffers.
    glGenFramebuffersOES(1, &m_framebuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, m_framebuffer);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES,
                                 GL_COLOR_ATTACHMENT0_OES,
                                 GL_RENDERBUFFER_OES,
                                 m_colorRenderbuffer);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES,
                                 GL_DEPTH_ATTACHMENT_OES,
                                 GL_RENDERBUFFER_OES,
                                 m_depthRenderbuffer);
    
    // Bind the color buffer for rendering.
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, m_colorRenderbuffer);
    
    glViewport(0, 0, width, height);
    glEnable(GL_DEPTH_TEST);
    
    glMatrixMode(GL_PROJECTION);
    glFrustumf(-1.6f, 1.6, -2.4, 2.4, 5, 10);
    
    glMatrixMode(GL_MODELVIEW);
    glTranslatef(0, 0, -7);
    
}

-(void) Render
{
    glClearColor(0.5f, 0.5f, 0.5f, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glPushMatrix();
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glRotatef(m_rotationAngle, 0, 0, 1);
    glScalef(m_scale, m_scale, m_scale);
    
    mat4 rotation(m_animation.Current.ToMatrix());
    glMultMatrixf(rotation.Pointer());
    
    // Draw the cone.
    glVertexPointer(3, GL_FLOAT, sizeof(Vertex), &m_cone[0].Position.x);
    glColorPointer(4, GL_FLOAT, sizeof(Vertex),  &m_cone[0].Color.x);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, m_cone.size());

    // Draw the disk that caps off the base of the cone.
    glVertexPointer(3, GL_FLOAT, sizeof(Vertex), &m_disk[0].Position.x);
    glColorPointer(4, GL_FLOAT, sizeof(Vertex), &m_disk[0].Color.x);
    glDrawArrays(GL_TRIANGLE_FAN, 0, m_disk.size());
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glPopMatrix();
}


-(void) UpdateAnimation:(float)timeStep
{
    if (m_animation.Current == m_animation.End)
        return;
    
    m_animation.Elapsed += timeStep;
    if (m_animation.Elapsed >= AnimationDuration) {
        m_animation.Current = m_animation.End;
    } else {
        float mu = m_animation.Elapsed / AnimationDuration;
        m_animation.Current = m_animation.Start.Slerp(mu, m_animation.End);
    }
}

-(void) OnRotate:(UIDeviceOrientation)newOrientation
{
    vec3 direction;
    
    switch (newOrientation) {
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationPortrait:
            direction = vec3(0, 1, 0);
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            direction = vec3(0, -1, 0);
            break;
            
        case UIDeviceOrientationFaceDown:
            direction = vec3(0, 0, -1);
            break;
            
        case UIDeviceOrientationFaceUp:
            direction = vec3(0, 0, 1);
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            direction = vec3(+1, 0, 0);
            break;
            
        case UIDeviceOrientationLandscapeRight:
            direction = vec3(-1, 0, 0);
            break;
    }
    
    m_animation.Elapsed = 0;
    m_animation.Start = m_animation.Current = m_animation.End;
    m_animation.End = Quaternion::CreateFromVectors(vec3(0, 1, 0), direction);
}

-(float)RotationDirection
{
    return 0;
}

-(void)OnFindUp:(CGPoint)point
{
//    ivec2 vec = ivec2((int)point.x,(int)point.y);
    m_scale = 1.0;
}
-(void)OnFindDown:(CGPoint)point
{
    m_scale = 1.5f;
    ivec2 vec = ivec2((int)point.x,(int)point.y);
    
}
-(void)OnFindMove:(CGPoint)point point2:(CGPoint)point2
{
    ivec2 previous = ivec2((int)point.x,(int)point.y);
    ivec2 location = ivec2((int)point2.x,(int)point2.y);
    
    vec2 direction = vec2(location - m_pivotPoint).Normalized();
    direction.y = -direction.y;
    m_rotationAngle = std::acos(direction.y) * 180.0f/3.14159f;
    if (direction.x > 0) {
        m_rotationAngle = -m_rotationAngle;
    }
    
}

@end
