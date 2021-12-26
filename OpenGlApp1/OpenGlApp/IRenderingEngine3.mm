//
//  IRenderingEngine.m
//  OpenGlApp
//
//  Created by xingye yang on 2021/12/25.
//

#import "IRenderingEngine3.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define STRINGIFY(A) #A
#include "../Shaders/Simple.frag"
#include "../Shaders/Simple.vert"


static const float RevolutionsPerSecond = 1;


struct Vertex{
    float Position[2];
    float Color[4];
};

typedef struct Vertex Vertex;

const Vertex Vertices[] = {
    {{-0.5,-0.866},{1,1,0.5,1}},
    {{0.5,-0.866},{1,1,0.5,1}},
    {{0,1},{1,1,0.5,1}},
    {{-0.5,-0.866},{0.5,0.5,1}},
    {{0.5,-0.866},{0.5,0.5,1}},
    {{0,-0.4},{0.5,0.5,1}},
};


@implementation IRenderingEngine3

- (instancetype)init
{
    self = [super init];
    if (self) {
        glGenRenderbuffers(1, &m_renderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, m_renderbuffer);
    }
    return self;
}

-(void) Initialize:(int)width height:(int)height
{
    glGenFramebuffers(1, &m_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, m_framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, m_renderbuffer);
    glViewport(0, 0, width, height);
//    m_simpleProgram = [self BuildProgram:SimpleVertexShader fShader:SimpleFragmentShader];
    m_simpleProgram = BuildProgram(SimpleVertexShader, SimpleFragmentShader);
    glUseProgram(m_simpleProgram);
    [self AppleOrtho:2 maxY:3];
    [self OnRotate:UIDeviceOrientationPortrait];
    m_currentAngle = m_desiredAngle;
}


-(void) Render
{
    glClearColor(0.5f, 0.5f, 0.5f, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    [self ApplyRotation:m_currentAngle];
    GLuint positionSolt = glGetAttribLocation(m_simpleProgram, "Position");
    GLuint colorSolt = glGetAttribLocation(m_simpleProgram, "SourceColor");
    glEnableVertexAttribArray(positionSolt);
    glEnableVertexAttribArray(colorSolt);
    GLsizei stride = sizeof(Vertex);
    const GLvoid *pCoords = &Vertices[0].Position[0];
    const GLvoid *pColors = &Vertices[0].Color[0];
    glVertexAttribPointer(positionSolt, 2, GL_FLOAT, GL_FALSE, stride, pCoords);
    glVertexAttribPointer(colorSolt, 4, GL_FLOAT, GL_FALSE, stride, pColors);
    GLsizei vertexCount = sizeof(Vertices)/sizeof(Vertex);
    glDrawArrays(GL_TRIANGLES, 0, vertexCount);
    glDisableVertexAttribArray(positionSolt);
    glDisableVertexAttribArray(colorSolt);
}


-(void) UpdateAnimation:(float)timeStep
{
    float direaction = [self RotationDirection];
    if (direaction == 0) {
        return;
    }
    float degrees = timeStep * 360 * RevolutionsPerSecond;
    m_currentAngle += degrees * direaction;
    if (m_currentAngle >= 360) {
        m_currentAngle -= 360;
    }else if (m_currentAngle < 0){
        m_currentAngle += 360;
    }
    if ([self RotationDirection] != direaction) {
        m_currentAngle = m_desiredAngle;
    }
}
-(void) OnRotate:(UIDeviceOrientation)newOrientation
{
    float angle = 0;
    switch (newOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            angle = 270;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            angle = 180;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = 90;
            break;
        default:
            break;
    }
//    m_currentAngle = angle;
    m_desiredAngle = angle;
}

-(float)RotationDirection
{
    float delta = m_desiredAngle - m_currentAngle;
    if (delta == 0) {
        return 0;
    }
    bool count1 = ((delta > 0 && delta <= 180) || (delta < -180));
    return count1 ? + 1 : -1;
}

-(GLuint)BuildShader:(const char *)soure shaderType:(GLenum)shaderType
{
    GLuint shaderHandle = glCreateShader(shaderType);
    glShaderSource(shaderHandle, 1, &soure, 0);
    glCompileShader(shaderHandle);
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSLog(@"====BuildShader====000");
        exit(1);
    }
    
    return 0;
}

-(GLuint)BuildProgram:(const char*)vertexShaderSource fShader:(const char*)fragmentShaderSource
{
    GLuint vertexShader = [self BuildShader:vertexShaderSource shaderType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self BuildShader:fragmentShaderSource shaderType:GL_FRAGMENT_SHADER];
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if(linkSuccess == GL_FALSE){
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSLog(@"====BuildProgram====00");
        exit(1);
    }
    
    return programHandle;
}


GLuint BuildShader(const char* source, GLenum shaderType)
{
    GLuint shaderHandle = glCreateShader(shaderType);
    glShaderSource(shaderHandle, 1, &source, 0);
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
//        std::cout << messages;
        NSLog(@"=======%s",messages);
        exit(1);
    }
    
    return shaderHandle;
}

GLuint BuildProgram(const char* vertexShaderSource,
                                      const char* fragmentShaderSource)
{
    GLuint vertexShader = BuildShader(vertexShaderSource, GL_VERTEX_SHADER);
    GLuint fragmentShader = BuildShader(fragmentShaderSource, GL_FRAGMENT_SHADER);
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
//        std::cout << messages;
        NSLog(@"=======%s",messages);
        exit(1);
    }
    
    return programHandle;
}

-(void)AppleOrtho:(float)maxX maxY:(float)maxY
{
    float a = 1.0f / maxX;
    float b = 1.0f / maxY;
    float ortho[16] = {
        a, 0,  0, 0,
        0, b,  0, 0,
        0, 0, -1, 0,
        0, 0,  0, 1
    };
    
    GLint projectionUniform = glGetUniformLocation(m_simpleProgram, "Projection");
    glUniformMatrix4fv(projectionUniform, 1, 0, &ortho[0]);
}
-(void)ApplyRotation:(float)degrees
{
    float radians = degrees * 3.14159f / 180.0f;
    float s = sinf(radians);
    float c = cosf(radians);
    float zRotation[16] = {
        c, s, 0, 0,
        -s, c, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    };
    
    GLint modelviewUniform = glGetUniformLocation(m_simpleProgram, "Modelview");
    glUniformMatrix4fv(modelviewUniform, 1, 0, &zRotation[0]);
}


@end
