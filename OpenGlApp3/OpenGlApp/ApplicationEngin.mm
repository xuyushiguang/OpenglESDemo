//
//  ApplicationEngin.m
//  OpenGlApp
//
//  Created by xingye yang on 2021/12/26.
//

#import "ApplicationEngin.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#include <vector>
#include "Vector.hpp"
#include "Quaternion.hpp"
#include "Matrix.hpp"

#define STRINGIFY(A) #A
#include "../Shaders/Simple.frag"
#include "../Shaders/Simple.vert"

using namespace std;


static const int SurfaceCount = 6;
static const int ButtonCount = SurfaceCount - 1;


struct Visual {
    vec3 Color;
    ivec2 LowerLeft;
    ivec2 ViewportSize;
    Quaternion Orientation;
};

struct Animation {
    bool Active;
    float Elapsed;
    float Duration;
    Visual StartingVisuals[SurfaceCount];
    Visual EndingVisuals[SurfaceCount];
};
typedef Animation Animation;

struct ParametricInterval {
    ivec2 Divisions;
    vec2 UpperBound;
    vec2 TextureCount;
};
typedef ParametricInterval ParametricInterval;


enum VertexFlags {
    VertexFlagsNormals = 1 << 0,
    VertexFlagsTexCoords = 1 << 1,
};


class ParametricSurface
{
public:
    int GetVertexCount(){
        return m_divisions.x * m_divisions.y;
    }
    int GetLineIndexCount(){
        return 4 * m_slices.x * m_slices.x;
    }
    int GetTriangleIndexCount(){
        return 6 * m_slices.x * m_slices.y;
    }
    void GenerateVertices(vector<float>& vertices, unsigned char flags)
    {
        int floatsPerVertex = 3;
        if (flags & VertexFlagsNormals)
            floatsPerVertex += 3;
        if (flags & VertexFlagsTexCoords)
            floatsPerVertex += 2;

        vertices.resize(GetVertexCount() * floatsPerVertex);
        float* attribute = &vertices[0];

        for (int j = 0; j < m_divisions.y; j++) {
            for (int i = 0; i < m_divisions.x; i++) {

                // Compute Position
                vec2 domain = ComputeDomain(i, j);
                vec3 range = Evaluate(domain);
                attribute = range.Write(attribute);

                // Compute Normal
                if (flags & VertexFlagsNormals) {
                    float s = i, t = j;

                    // Nudge the point if the normal is indeterminate.
                    if (i == 0) s += 0.01f;
                    if (i == m_divisions.x - 1) s -= 0.01f;
                    if (j == 0) t += 0.01f;
                    if (j == m_divisions.y - 1) t -= 0.01f;
                    
                    // Compute the tangents and their cross product.
                    vec3 p = Evaluate(ComputeDomain(s, t));
                    vec3 u = Evaluate(ComputeDomain(s + 0.01f, t)) - p;
                    vec3 v = Evaluate(ComputeDomain(s, t + 0.01f)) - p;
                    vec3 normal = u.Cross(v).Normalized();
                    if (InvertNormal(domain))
                        normal = -normal;
                    attribute = normal.Write(attribute);
                }
                
                // Compute Texture Coordinates
                if (flags & VertexFlagsTexCoords) {
                    float s = m_textureCount.x * i / m_slices.x;
                    float t = m_textureCount.y * j / m_slices.y;
                    attribute = vec2(s, t).Write(attribute);
                }
            }
        }
    }
    void GenerateLineIndices(vector<unsigned short>& indices)
    {
        indices.resize(GetLineIndexCount());
        vector<unsigned short>::iterator index = indices.begin();
        for (int j = 0, vertex = 0; j < m_slices.y; j++) {
            for (int i = 0; i < m_slices.x; i++) {
                int next = (i + 1) % m_divisions.x;
                *index++ = vertex + i;
                *index++ = vertex + next;
                *index++ = vertex + i;
                *index++ = vertex + i + m_divisions.x;
            }
            vertex += m_divisions.x;
        }
    }
    void GenerateTriangleIndices(vector<unsigned short>& indices)
    {
        indices.resize(GetTriangleIndexCount());
        vector<unsigned short>::iterator index = indices.begin();
        for (int j = 0, vertex = 0; j < m_slices.y; j++) {
            for (int i = 0; i < m_slices.x; i++) {
                int next = (i + 1) % m_divisions.x;
                *index++ = vertex + i;
                *index++ = vertex + next;
                *index++ = vertex + i + m_divisions.x;
                *index++ = vertex + next;
                *index++ = vertex + next + m_divisions.x;
                *index++ = vertex + i + m_divisions.x;
            }
            vertex += m_divisions.x;
        }
    }
protected:
    void SetInterval(const ParametricInterval& interval)
    {
        m_divisions = interval.Divisions;
        m_upperBound = interval.UpperBound;
        m_textureCount = interval.TextureCount;
        m_slices = m_divisions - ivec2(1, 1);
    }
    virtual vec3 Evaluate(const vec2& domain) const = 0;
    virtual bool InvertNormal(const vec2& domain) const { return false; }
private:
    vec2 ComputeDomain(float x, float y){
        return vec2(x * m_upperBound.x / m_slices.x, y * m_upperBound.y / m_slices.y);
    }
    ivec2 m_slices;
    ivec2 m_divisions;
    vec2 m_upperBound;
    vec2 m_textureCount;
    
};

class Cone :public ParametricSurface{
public:
    Cone(float height,float radius): m_height(height), m_radius(radius)
    {
        ParametricInterval interval = { ivec2(20, 20), vec2(TwoPi, 1), vec2(30, 20) };
        SetInterval(interval);
    }
    vec3 Evaluate(const vec2& domain) const
    {
        float u = domain.x, v = domain.y;
        float x = m_radius * (1 - v) * cos(u);
        float y = m_height * (v - 0.5f);
        float z = m_radius * (1 - v) * -sin(u);
        return vec3(x, y, z);
    }
private:
    float m_height;
    float m_radius;
    
};

class Sphere : public ParametricSurface {
public:
    Sphere(float radius) : m_radius(radius)
    {
        ParametricInterval interval = { ivec2(20, 20), vec2(Pi, TwoPi), vec2(20, 35) };
        SetInterval(interval);
    }
    vec3 Evaluate(const vec2& domain) const
    {
        float u = domain.x, v = domain.y;
        float x = m_radius * sin(u) * cos(v);
        float y = m_radius * cos(u);
        float z = m_radius * -sin(u) * sin(v);
        return vec3(x, y, z);
    }
private:
    float m_radius;
};

class Torus : public ParametricSurface {
public:
    Torus(float majorRadius, float minorRadius) :
        m_majorRadius(majorRadius),
        m_minorRadius(minorRadius)
    {
        ParametricInterval interval = { ivec2(20, 20), vec2(TwoPi, TwoPi), vec2(40, 10) };
        SetInterval(interval);
    }
    vec3 Evaluate(const vec2& domain) const
    {
        const float major = m_majorRadius;
        const float minor = m_minorRadius;
        float u = domain.x, v = domain.y;
        float x = (major + minor * cos(v)) * cos(u);
        float y = (major + minor * cos(v)) * sin(u);
        float z = minor * sin(v);
        return vec3(x, y, z);
    }
private:
    float m_majorRadius;
    float m_minorRadius;
};

class TrefoilKnot : public ParametricSurface {
public:
    TrefoilKnot(float scale) : m_scale(scale)
    {
        ParametricInterval interval = { ivec2(60, 15), vec2(TwoPi, TwoPi), vec2(100, 8) };
        SetInterval(interval);
    }
    vec3 Evaluate(const vec2& domain) const
    {
        const float a = 0.5f;
        const float b = 0.3f;
        const float c = 0.5f;
        const float d = 0.1f;
        float u = (TwoPi - domain.x) * 2;
        float v = domain.y;
        
        float r = a + b * cos(1.5f * u);
        float x = r * cos(u);
        float y = r * sin(u);
        float z = c * sin(1.5f * u);
        
        vec3 dv;
        dv.x = -1.5f * b * sin(1.5f * u) * cos(u) -
               (a + b * cos(1.5f * u)) * sin(u);
        dv.y = -1.5f * b * sin(1.5f * u) * sin(u) +
               (a + b * cos(1.5f * u)) * cos(u);
        dv.z = 1.5f * c * cos(1.5f * u);
        
        vec3 q = dv.Normalized();
        vec3 qvn = vec3(q.y, -q.x, 0).Normalized();
        vec3 ww = q.Cross(qvn);
        
        vec3 range;
        range.x = x + d * (qvn.x * cos(v) + ww.x * sin(v));
        range.y = y + d * (qvn.y * cos(v) + ww.y * sin(v));
        range.z = z + d * ww.z * sin(v);
        return range * m_scale;
    }
private:
    float m_scale;
};

class MobiusStrip : public ParametricSurface {
public:
    MobiusStrip(float scale) : m_scale(scale)
    {
        ParametricInterval interval = { ivec2(40, 20), vec2(TwoPi, TwoPi), vec2(40, 15) };
        SetInterval(interval);
    }
    vec3 Evaluate(const vec2& domain) const
    {
        float u = domain.x;
        float t = domain.y;
        float major = 1.25;
        float a = 0.125f;
        float b = 0.5f;
        float phi = u / 2;
        
        // General equation for an ellipse where phi is the angle
        // between the major axis and the X axis.
        float x = a * cos(t) * cos(phi) - b * sin(t) * sin(phi);
        float y = a * cos(t) * sin(phi) + b * sin(t) * cos(phi);

        // Sweep the ellipse along a circle, like a torus.
        vec3 range;
        range.x = (major + x) * cos(u);
        range.y = (major + x) * sin(u);
        range.z = y;
        return range * m_scale;
    }
private:
    float m_scale;
};

class KleinBottle : public ParametricSurface {
public:
    KleinBottle(float scale) : m_scale(scale)
    {
        ParametricInterval interval = { ivec2(20, 20), vec2(TwoPi, TwoPi), vec2(15, 50) };
        SetInterval(interval);
    }
    vec3 Evaluate(const vec2& domain) const
    {
        float v = 1 - domain.x;
        float u = domain.y;
        
        float x0 = 3 * cos(u) * (1 + sin(u)) +
                   (2 * (1 - cos(u) / 2)) * cos(u) * cos(v);
        
        float y0  = 8 * sin(u) + (2 * (1 - cos(u) / 2)) * sin(u) * cos(v);
        
        float x1 = 3 * cos(u) * (1 + sin(u)) +
                   (2 * (1 - cos(u) / 2)) * cos(v + Pi);
        
        float y1 = 8 * sin(u);
        
        vec3 range;
        range.x = u < Pi ? x0 : x1;
        range.y = u < Pi ? -y0 : -y1;
        range.z = (-2 * (1 - cos(u) / 2)) * sin(v);
        return range * m_scale;
    }
    bool InvertNormal(const vec2& domain) const
    {
        return domain.y > 3 * Pi / 2;
    }
private:
    float m_scale;
};



//##############################################################################
//##############################################################################
//##############################################################################


struct UniformHandles {
    GLuint Modelview;
    GLuint Projection;
    GLuint NormalMatrix;
    GLuint LightPosition;
    GLint AmbientMaterial;
    GLint SpecularMaterial;
    GLint Shininess;
};
typedef UniformHandles UniformHandles;

struct AttributeHandles {
    GLint Position;
    GLint Normal;
    GLint DiffuseMaterial;
};
typedef AttributeHandles AttributeHandles;

struct Drawable {
    GLuint VertexBuffer;
    GLuint IndexBuffer;
    int IndexCount;
};
typedef Drawable Drawable;

@interface IRenderingEngine ()
{
    vector<Drawable> m_drawables;
    GLuint m_colorRenderbuffer;
    GLuint m_depthRenderbuffer;
    mat4 m_translation;
    UniformHandles m_uniforms;
    AttributeHandles m_attributes;
}

-(void) Initialize:(const vector<ParametricSurface*>& )surfaces;
-(void) Render:(const vector<Visual>& ) visuals;
@end

@implementation IRenderingEngine

- (instancetype)init
{
    self = [super init];
    if (self) {
        glGenRenderbuffers(1, &m_colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, m_colorRenderbuffer);
    }
    return self;
}


-(void) Initialize:(const vector<ParametricSurface*>& )surfaces
{
    vector<ParametricSurface*>::const_iterator surface;
    for (surface = surfaces.begin(); surface != surfaces.end(); ++surface) {
        
        // Create the VBO for the vertices.
        vector<float> vertices;
        (*surface)->GenerateVertices(vertices, VertexFlagsNormals);
        GLuint vertexBuffer;
        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER,
                     vertices.size() * sizeof(vertices[0]),
                     &vertices[0],
                     GL_STATIC_DRAW);
        
        // Create a new VBO for the indices if needed.
        int indexCount = (*surface)->GetTriangleIndexCount();
        GLuint indexBuffer;
        if (!m_drawables.empty() && indexCount == m_drawables[0].IndexCount) {
            indexBuffer = m_drawables[0].IndexBuffer;
        } else {
            vector<GLushort> indices(indexCount);
            (*surface)->GenerateTriangleIndices(indices);
            glGenBuffers(1, &indexBuffer);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
            glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                         indexCount * sizeof(GLushort),
                         &indices[0],
                         GL_STATIC_DRAW);
        }
        
        Drawable drawable = { vertexBuffer, indexBuffer, indexCount};
        m_drawables.push_back(drawable);
    }
    
    // Extract width and height.
    int width, height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_HEIGHT, &height);
    
    // Create a depth buffer that has the same size as the color buffer.
    glGenRenderbuffers(1, &m_depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, m_depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    
    // Create the framebuffer object.
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, m_colorRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
                              GL_RENDERBUFFER, m_depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, m_colorRenderbuffer);
    
    // Create the GLSL program.
    GLuint program = BuildProgram(SimpleVertexShader, SimpleFragmentShader);
    glUseProgram(program);

    // Extract the handles to attributes and uniforms.
    m_attributes.Position = glGetAttribLocation(program, "Position");
    m_attributes.Normal = glGetAttribLocation(program, "Normal");
    m_attributes.DiffuseMaterial = glGetAttribLocation(program, "DiffuseMaterial");
    m_uniforms.Projection = glGetUniformLocation(program, "Projection");
    m_uniforms.Modelview = glGetUniformLocation(program, "Modelview");
    m_uniforms.NormalMatrix = glGetUniformLocation(program, "NormalMatrix");
    m_uniforms.LightPosition = glGetUniformLocation(program, "LightPosition");
    m_uniforms.AmbientMaterial = glGetUniformLocation(program, "AmbientMaterial");
    m_uniforms.SpecularMaterial = glGetUniformLocation(program, "SpecularMaterial");
    m_uniforms.Shininess = glGetUniformLocation(program, "Shininess");
    
    // Set up some default material parameters.
    glUniform3f(m_uniforms.AmbientMaterial, 0.04f, 0.04f, 0.04f);
    glUniform3f(m_uniforms.SpecularMaterial, 0.5, 0.5, 0.5);
    glUniform1f(m_uniforms.Shininess, 50);

    // Initialize various state.
    glEnableVertexAttribArray(m_attributes.Position);
    glEnableVertexAttribArray(m_attributes.Normal);
    glEnable(GL_DEPTH_TEST);

    // Set up transforms.
    m_translation = mat4::Translate(0, 0, -7);
}

-(void) Render:(const vector<Visual>& ) visuals
{
    glClearColor(0.5f, 0.5f, 0.5f, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    vector<Visual>::const_iterator visual = visuals.begin();
    for (int visualIndex = 0; visual != visuals.end(); ++visual, ++visualIndex) {

        // Set the viewport transform.
        ivec2 size = visual->ViewportSize;
        ivec2 lowerLeft = visual->LowerLeft;
        glViewport(lowerLeft.x, lowerLeft.y, size.x, size.y);
        
        // Set the light position.
        vec4 lightPosition(0.25, 0.25, 1, 0);
        glUniform3fv(m_uniforms.LightPosition, 1, lightPosition.Pointer());

        // Set the model-view transform.
        mat4 rotation = visual->Orientation.ToMatrix();
        mat4 modelview = rotation * m_translation;
        glUniformMatrix4fv(m_uniforms.Modelview, 1, 0, modelview.Pointer());
        
        // Set the normal matrix.
        // It's orthogonal, so its Inverse-Transpose is itself!
        mat3 normalMatrix = modelview.ToMat3();
        glUniformMatrix3fv(m_uniforms.NormalMatrix, 1, 0, normalMatrix.Pointer());

        // Set the projection transform.
        float h = 4.0f * size.y / size.x;
        mat4 projectionMatrix = mat4::Frustum(-2, 2, -h / 2, h / 2, 5, 10);
        glUniformMatrix4fv(m_uniforms.Projection, 1, 0, projectionMatrix.Pointer());
        
        // Set the diffuse color.
        vec3 color = visual->Color * 0.75f;
        glVertexAttrib4f(m_attributes.DiffuseMaterial, color.x, color.y, color.z, 1);
        
        // Draw the surface.
        int stride = 2 * sizeof(vec3);
        const GLvoid* offset = (const GLvoid*) sizeof(vec3);
        GLint position = m_attributes.Position;
        GLint normal = m_attributes.Normal;
        const Drawable& drawable = m_drawables[visualIndex];
        glBindBuffer(GL_ARRAY_BUFFER, drawable.VertexBuffer);
        glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, stride, 0);
        glVertexAttribPointer(normal, 3, GL_FLOAT, GL_FALSE, stride, offset);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, drawable.IndexBuffer);
        glDrawElements(GL_TRIANGLES, drawable.IndexCount, GL_UNSIGNED_SHORT, 0);
    }
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
        exit(1);
    }
    
    return programHandle;
}

@end





@interface ApplicationEngin ()
{
    float m_trackballRadius;
    ivec2 m_screenSize;
    ivec2 m_centerPoint;
    ivec2 m_fingerStart;
    bool m_spinning;
    Quaternion m_orientation;
    Quaternion m_previousOrientation;
    int m_currentSurface;
    ivec2 m_buttonSize;
    int m_pressedButton;
    int m_buttonSurfaces[ButtonCount];
    Animation m_animation;
    IRenderingEngine * m_renderingEngine;
}
@end

@implementation ApplicationEngin



- (instancetype)initWithrender:(id)reder
{
    self = [super init];
    if (self) {
        m_spinning = NO;
        m_pressedButton = -1;
        m_renderingEngine = reder;
        m_animation.Active = false;
        m_buttonSurfaces[0] = 0;
        m_buttonSurfaces[1] = 2;
        m_buttonSurfaces[2] = 3;
        m_buttonSurfaces[3] = 4;
        m_buttonSurfaces[4] = 5;
        m_currentSurface = 1;
    }
    return self;
}


-(void) Initialize:(int)width height:(int)height
{
    m_trackballRadius = width / 3;
    m_buttonSize.y = height / 10;
    m_buttonSize.x = 4 * m_buttonSize.y / 3;
    m_screenSize = ivec2(width, height - m_buttonSize.y);
    m_centerPoint = m_screenSize / 2;

    vector<ParametricSurface*> surfaces(SurfaceCount);
    surfaces[0] = new Cone(3, 1);
    surfaces[1] = new Sphere(1.4f);
    surfaces[2] = new Torus(1.4f, 0.3f);
    surfaces[3] = new TrefoilKnot(1.8f);
    surfaces[4] = new KleinBottle(0.2f);
    surfaces[5] = new MobiusStrip(1);
    [m_renderingEngine Initialize:surfaces];
    for (int i = 0; i < SurfaceCount; i++)
        delete surfaces[i];
}
-(void) Render
{
    vector<Visual> visuals(SurfaceCount);
    
    if (!m_animation.Active) {
        [self PopulateVisuals:&visuals[0]];
    } else {
        float t = m_animation.Elapsed / m_animation.Duration;
        
        for (int i = 0; i < SurfaceCount; i++) {
            
            const Visual& start = m_animation.StartingVisuals[i];
            const Visual& end = m_animation.EndingVisuals[i];
            Visual& tweened = visuals[i];
            
            tweened.Color = start.Color.Lerp(t, end.Color);
            tweened.LowerLeft = start.LowerLeft.Lerp(t, end.LowerLeft);
            tweened.ViewportSize = start.ViewportSize.Lerp(t, end.ViewportSize);
            tweened.Orientation = start.Orientation.Slerp(t, end.Orientation);
        }
    }
    
    [m_renderingEngine Render:visuals];
}

-(void) UpdateAnimation:(float)dt
{
    if (m_animation.Active) {
        m_animation.Elapsed += dt;
        if (m_animation.Elapsed > m_animation.Duration)
            m_animation.Active = false;
    }
}

-(void) OnFingerUp:(CGPoint)rclocation
{
    ivec2 location = ivec2(rclocation.x,rclocation.y);
    
    m_spinning = false;
    
    if (m_pressedButton != -1 && m_pressedButton == [self MapToButton:location] &&
        !m_animation.Active)
    {
        m_animation.Active = true;
        m_animation.Elapsed = 0;
        m_animation.Duration = 0.25f;
        
        [self PopulateVisuals:&m_animation.StartingVisuals[0]];
        swap(m_buttonSurfaces[m_pressedButton], m_currentSurface);
        [self PopulateVisuals:&m_animation.EndingVisuals[0]];
    }
    
    m_pressedButton = -1;
}
-(void) OnFingerDown:(CGPoint)rclocation
{
    ivec2 location = ivec2(rclocation.x,rclocation.y);
    m_fingerStart = location;
    m_previousOrientation = m_orientation;
    m_pressedButton = [self MapToButton:location];
    if (m_pressedButton == -1)
        m_spinning = true;
}
-(void) OnFingerMove:(CGPoint) rcoldLocation newLocation:(CGPoint) rcnewLocation
{
    ivec2 oldLocation = ivec2(rcoldLocation.x,rcoldLocation.y);
    ivec2 location = ivec2(rcnewLocation.x,rcnewLocation.y);
    if (m_spinning) {
        vec3 start = [self MapToSphere:m_fingerStart];
        vec3 end = [self MapToSphere:location];
        Quaternion delta = Quaternion::CreateFromVectors(start, end);
        m_orientation = delta.Rotated(m_previousOrientation);
    }
    
    if (m_pressedButton != -1 && m_pressedButton != [self MapToButton:location])
        m_pressedButton = -1;
}

-(void) PopulateVisuals:(Visual* )visuals
{
    for (int buttonIndex = 0; buttonIndex < ButtonCount; buttonIndex++) {
        
        int visualIndex = m_buttonSurfaces[buttonIndex];
        visuals[visualIndex].Color = vec3(0.25f, 0.25f, 0.25f);
        if (m_pressedButton == buttonIndex)
            visuals[visualIndex].Color = vec3(0.5f, 0.5f, 0.5f);
        
        visuals[visualIndex].ViewportSize = m_buttonSize;
        visuals[visualIndex].LowerLeft.x = buttonIndex * m_buttonSize.x;
        visuals[visualIndex].LowerLeft.y = 0;
        visuals[visualIndex].Orientation = Quaternion();
    }
    
    visuals[m_currentSurface].Color = m_spinning ? vec3(1, 1, 0.75f) : vec3(1, 1, 0.5f);
    visuals[m_currentSurface].LowerLeft = ivec2(0, m_buttonSize.y);
    visuals[m_currentSurface].ViewportSize = ivec2(m_screenSize.x, m_screenSize.y);
    visuals[m_currentSurface].Orientation = m_orientation;
}
-(int) MapToButton:(ivec2 )touchpoint
{
    if (touchpoint.y  < m_screenSize.y - m_buttonSize.y)
        return -1;
    
    int buttonIndex = touchpoint.x / m_buttonSize.x;
    if (buttonIndex >= ButtonCount)
        return -1;
    
    return buttonIndex;
}
-(vec3) MapToSphere:(ivec2 )touchpoint
{
    vec2 p = touchpoint - m_centerPoint;
    
    // Flip the Y axis because pixel coords increase towards the bottom.
    p.y = -p.y;
    
    const float radius = m_trackballRadius;
    const float safeRadius = radius - 1;
    
    if (p.Length() > safeRadius) {
        float theta = atan2(p.y, p.x);
        p.x = safeRadius * cos(theta);
        p.y = safeRadius * sin(theta);
    }
    
    float z = sqrt(radius * radius - p.LengthSquared());
    vec3 mapped = vec3(p.x, p.y, z);
    return mapped / radius;
}


@end
