module opengl.glfuncs;

private import opengl.gltypes;


extern (C)
{
void glVertexPointer(GLint,GLenum,GLsizei,GLvoid*);
void glNormalPointer(GLenum,GLsizei,GLvoid*);
void glColorPointer(GLint,GLenum,GLsizei,GLvoid*);
void glIndexPointer(GLenum,GLsizei,GLvoid*);
void glTexCoordPointer(GLint,GLenum,GLsizei,GLvoid*);
void glEdgeFlagPointer(GLsizei,GLvoid*);
void glGetPointerv(GLenum,GLvoid**);
void glArrayElement(GLint);
void glDrawArrays(GLenum,GLint,GLsizei);
void glDrawElements(GLenum,GLsizei,GLenum,GLvoid*);
void glInterleavedArrays(GLenum,GLsizei,GLvoid*);
}


/*
extern (C)
{
	void glEnable(GLenum);
	void glEnableClientState(GLenum);
	void glDisableClientState(GLenum);
	void glClear(GLbitfield);
	void glLoadIdentity();
	void glBegin(GLenum);
	void glColor3f(GLfloat,GLfloat,GLfloat);
	void glVertex3f(GLfloat,GLfloat,GLfloat);
	void glEnd();
	void glViewport(GLint,GLint,GLsizei,GLsizei);
	void glMatrixMode(GLenum);
	void glGetDoublev(GLenum,GLdouble*);
	void glGetFloatv(GLenum,GLfloat*);
	void glGetIntegerv(GLenum,GLint*);
	void glScalef(GLfloat,GLfloat,GLfloat);
	void glDeleteLists(GLuint, GLsizei);
	void glShadeModel(GLenum);
	void glTranslated(GLdouble, GLdouble, GLdouble);
	void glTranslatef(GLfloat, GLfloat, GLfloat);
	void glRotated(GLdouble, GLdouble, GLdouble, GLdouble);
	void glCallList(GLuint);
	void glOrtho (GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar);
	GLuint glGenLists (GLsizei range);
}
*/
alias ptrdiff_t GLintptrARB;
alias ptrdiff_t GLsizeiptrARB;

enum : GLenum
{
    GL_BUFFER_SIZE_ARB                             = 0x8764,
    GL_BUFFER_USAGE_ARB                            = 0x8765,
    GL_ARRAY_BUFFER_ARB                            = 0x8892,
    GL_ELEMENT_ARRAY_BUFFER_ARB                    = 0x8893,
    GL_ARRAY_BUFFER_BINDING_ARB                    = 0x8894,
    GL_ELEMENT_ARRAY_BUFFER_BINDING_ARB            = 0x8895,
    GL_VERTEX_ARRAY_BUFFER_BINDING_ARB             = 0x8896,
    GL_NORMAL_ARRAY_BUFFER_BINDING_ARB             = 0x8897,
    GL_COLOR_ARRAY_BUFFER_BINDING_ARB              = 0x8898,
    GL_INDEX_ARRAY_BUFFER_BINDING_ARB              = 0x8899,
    GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING_ARB      = 0x889A,
    GL_EDGE_FLAG_ARRAY_BUFFER_BINDING_ARB          = 0x889B,
    GL_SECONDARY_COLOR_ARRAY_BUFFER_BINDING_ARB    = 0x889C,
    GL_FOG_COORDINATE_ARRAY_BUFFER_BINDING_ARB     = 0x889D,
    GL_WEIGHT_ARRAY_BUFFER_BINDING_ARB             = 0x889E,
    GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING_ARB      = 0x889F,
    GL_READ_ONLY_ARB                               = 0x88B8,
    GL_WRITE_ONLY_ARB                              = 0x88B9,
    GL_READ_WRITE_ARB                              = 0x88BA,
    GL_BUFFER_ACCESS_ARB                           = 0x88BB,
    GL_BUFFER_MAPPED_ARB                           = 0x88BC,
    GL_BUFFER_MAP_POINTER_ARB                      = 0x88BD,
    GL_STREAM_DRAW_ARB                             = 0x88E0,
    GL_STREAM_READ_ARB                             = 0x88E1,
    GL_STREAM_COPY_ARB                             = 0x88E2,
    GL_STATIC_DRAW_ARB                             = 0x88E4,
    GL_STATIC_READ_ARB                             = 0x88E5,
    GL_STATIC_COPY_ARB                             = 0x88E6,
    GL_DYNAMIC_DRAW_ARB                            = 0x88E8,
    GL_DYNAMIC_READ_ARB                            = 0x88E9,
    GL_DYNAMIC_COPY_ARB                            = 0x88EA,
}

extern (C)
{
	void glBindBufferARB (GLenum target, GLuint buffer);
	void glDeleteBuffersARB (GLsizei n, GLuint *buffers);
	void glGenBuffersARB (GLsizei n, GLuint *buffers);
	GLboolean glIsBufferARB (GLuint buffer);
	void glBufferDataARB (GLenum target, GLsizeiptrARB size, GLvoid *data, GLenum usage);
	void glBufferSubDataARB (GLenum target, GLintptrARB offset, GLsizeiptrARB size, GLvoid *data);
	void glGetBufferSubDataARB (GLenum target, GLintptrARB offset, GLsizeiptrARB size, GLvoid *data);
	GLvoid* glMapBufferARB (GLenum target, GLenum access);
	GLboolean glUnmapBufferARB (GLenum target);
	void glGetBufferParameterivARB (GLenum target, GLenum pname, GLint *params);
	void glGetBufferPointervARB (GLenum target, GLenum pname, GLvoid* *params);
}

extern (C)
{
	void glAccum (GLenum op, GLfloat value);
	void glAlphaFunc (GLenum func, GLclampf ref_);
	GLboolean glAreTexturesResident (GLsizei n, GLuint *textures, GLboolean *residences);
	void glArrayElement (GLint i);
	void glBegin (GLenum mode);
	void glBindTexture (GLenum target, GLuint texture);
	void glBitmap (GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig, GLfloat xmove, GLfloat ymove, GLubyte *bitmap);
	void glBlendFunc (GLenum sfactor, GLenum dfactor);
	void glCallList (GLuint list);
	void glCallLists (GLsizei n, GLenum type, GLvoid *lists);
	void glClear (GLbitfield mask);
	void glClearAccum (GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);
	void glClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);
	void glClearDepth (GLclampd depth);
	void glClearIndex (GLfloat c);
	void glClearStencil (GLint s);
	void glClipPlane (GLenum plane, GLdouble *equation);
	void glColor3b (GLbyte red, GLbyte green, GLbyte blue);
	void glColor3bv (GLbyte *v);
	void glColor3d (GLdouble red, GLdouble green, GLdouble blue);
	void glColor3dv (GLdouble *v);
	void glColor3f (GLfloat red, GLfloat green, GLfloat blue);
	void glColor3fv (GLfloat *v);
	void glColor3i (GLint red, GLint green, GLint blue);
	void glColor3iv (GLint *v);
	void glColor3s (GLshort red, GLshort green, GLshort blue);
	void glColor3sv (GLshort *v);
	void glColor3ub (GLubyte red, GLubyte green, GLubyte blue);
	void glColor3ubv (GLubyte *v);
	void glColor3ui (GLuint red, GLuint green, GLuint blue);
	void glColor3uiv (GLuint *v);
	void glColor3us (GLushort red, GLushort green, GLushort blue);
	void glColor3usv (GLushort *v);
	void glColor4b (GLbyte red, GLbyte green, GLbyte blue, GLbyte alpha);
	void glColor4bv (GLbyte *v);
	void glColor4d (GLdouble red, GLdouble green, GLdouble blue, GLdouble alpha);
	void glColor4dv (GLdouble *v);
	void glColor4f (GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);
	void glColor4fv (GLfloat *v);
	void glColor4i (GLint red, GLint green, GLint blue, GLint alpha);
	void glColor4iv (GLint *v);
	void glColor4s (GLshort red, GLshort green, GLshort blue, GLshort alpha);
	void glColor4sv (GLshort *v);
	void glColor4ub (GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha);
	void glColor4ubv (GLubyte *v);
	void glColor4ui (GLuint red, GLuint green, GLuint blue, GLuint alpha);
	void glColor4uiv (GLuint *v);
	void glColor4us (GLushort red, GLushort green, GLushort blue, GLushort alpha);
	void glColor4usv (GLushort *v);
	void glColorMask (GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha);
	void glColorMaterial (GLenum face, GLenum mode);
	void glColorPointer (GLint size, GLenum type, GLsizei stride, GLvoid *pointer);
	void glCopyPixels (GLint x, GLint y, GLsizei width, GLsizei height, GLenum type);
	void glCopyTexImage1D (GLenum target, GLint level, GLenum internalFormat, GLint x, GLint y, GLsizei width, GLint border);
	void glCopyTexImage2D (GLenum target, GLint level, GLenum internalFormat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border);
	void glCopyTexSubImage1D (GLenum target, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width);
	void glCopyTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height);
	void glCullFace (GLenum mode);
	void glDeleteLists (GLuint list, GLsizei range);
	void glDeleteTextures (GLsizei n, GLuint *textures);
	void glDepthFunc (GLenum func);
	void glDepthMask (GLboolean flag);
	void glDepthRange (GLclampd zNear, GLclampd zFar);
	void glDisable (GLenum cap);
	void glDisableClientState (GLenum array);
	void glDrawArrays (GLenum mode, GLint first, GLsizei count);
	void glDrawBuffer (GLenum mode);
	void glDrawElements (GLenum mode, GLsizei count, GLenum type, GLvoid *indices);
	void glDrawPixels (GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels);
	void glEdgeFlag (GLboolean flag);
	void glEdgeFlagPointer (GLsizei stride, GLvoid *pointer);
	void glEdgeFlagv (GLboolean *flag);
	void glEnable (GLenum cap);
	void glEnableClientState (GLenum array);
	void glEnd ();
	void glEndList ();
	void glEvalCoord1d (GLdouble u);
	void glEvalCoord1dv (GLdouble *u);
	void glEvalCoord1f (GLfloat u);
	void glEvalCoord1fv (GLfloat *u);
	void glEvalCoord2d (GLdouble u, GLdouble v);
	void glEvalCoord2dv (GLdouble *u);
	void glEvalCoord2f (GLfloat u, GLfloat v);
	void glEvalCoord2fv (GLfloat *u);
	void glEvalMesh1 (GLenum mode, GLint i1, GLint i2);
	void glEvalMesh2 (GLenum mode, GLint i1, GLint i2, GLint j1, GLint j2);
	void glEvalPoint1 (GLint i);
	void glEvalPoint2 (GLint i, GLint j);
	void glFeedbackBuffer (GLsizei size, GLenum type, GLfloat *buffer);
	void glFinish ();
	void glFlush ();
	void glFogf (GLenum pname, GLfloat param);
	void glFogfv (GLenum pname, GLfloat *params);
	void glFogi (GLenum pname, GLint param);
	void glFogiv (GLenum pname, GLint *params);
	void glFrontFace (GLenum mode);
	void glFrustum (GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar);
	GLuint glGenLists (GLsizei range);
	void glGenTextures (GLsizei n, GLuint *textures);
	void glGetBooleanv (GLenum pname, GLboolean *params);
	void glGetClipPlane (GLenum plane, GLdouble *equation);
	void glGetDoublev (GLenum pname, GLdouble *params);
	GLenum glGetError ();
	void glGetFloatv (GLenum pname, GLfloat *params);
	void glGetIntegerv (GLenum pname, GLint *params);
	void glGetLightfv (GLenum light, GLenum pname, GLfloat *params);
	void glGetLightiv (GLenum light, GLenum pname, GLint *params);
	void glGetMapdv (GLenum target, GLenum query, GLdouble *v);
	void glGetMapfv (GLenum target, GLenum query, GLfloat *v);
	void glGetMapiv (GLenum target, GLenum query, GLint *v);
	void glGetMaterialfv (GLenum face, GLenum pname, GLfloat *params);
	void glGetMaterialiv (GLenum face, GLenum pname, GLint *params);
	void glGetPixelMapfv (GLenum map, GLfloat *values);
	void glGetPixelMapuiv (GLenum map, GLuint *values);
	void glGetPixelMapusv (GLenum map, GLushort *values);
	void glGetPointerv (GLenum pname, GLvoid* *params);
	void glGetPolygonStipple (GLubyte *mask);
	GLubyte * glGetString (GLenum name);
	void glGetTexEnvfv (GLenum target, GLenum pname, GLfloat *params);
	void glGetTexEnviv (GLenum target, GLenum pname, GLint *params);
	void glGetTexGendv (GLenum coord, GLenum pname, GLdouble *params);
	void glGetTexGenfv (GLenum coord, GLenum pname, GLfloat *params);
	void glGetTexGeniv (GLenum coord, GLenum pname, GLint *params);
	void glGetTexImage (GLenum target, GLint level, GLenum format, GLenum type, GLvoid *pixels);
	void glGetTexLevelParameterfv (GLenum target, GLint level, GLenum pname, GLfloat *params);
	void glGetTexLevelParameteriv (GLenum target, GLint level, GLenum pname, GLint *params);
	void glGetTexParameterfv (GLenum target, GLenum pname, GLfloat *params);
	void glGetTexParameteriv (GLenum target, GLenum pname, GLint *params);
	void glHint (GLenum target, GLenum mode);
	void glIndexMask (GLuint mask);
	void glIndexPointer (GLenum type, GLsizei stride, GLvoid *pointer);
	void glIndexd (GLdouble c);
	void glIndexdv (GLdouble *c);
	void glIndexf (GLfloat c);
	void glIndexfv (GLfloat *c);
	void glIndexi (GLint c);
	void glIndexiv (GLint *c);
	void glIndexs (GLshort c);
	void glIndexsv (GLshort *c);
	void glIndexub (GLubyte c);
	void glIndexubv (GLubyte *c);
	void glInitNames ();
	void glInterleavedArrays (GLenum format, GLsizei stride, GLvoid *pointer);
	GLboolean glIsEnabled (GLenum cap);
	GLboolean glIsList (GLuint list);
	GLboolean glIsTexture (GLuint texture);
	void glLightModelf (GLenum pname, GLfloat param);
	void glLightModelfv (GLenum pname, GLfloat *params);
	void glLightModeli (GLenum pname, GLint param);
	void glLightModeliv (GLenum pname, GLint *params);
	void glLightf (GLenum light, GLenum pname, GLfloat param);
	void glLightfv (GLenum light, GLenum pname, GLfloat *params);
	void glLighti (GLenum light, GLenum pname, GLint param);
	void glLightiv (GLenum light, GLenum pname, GLint *params);
	void glLineStipple (GLint factor, GLushort pattern);
	void glLineWidth (GLfloat width);
	void glListBase (GLuint base);
	void glLoadIdentity ();
	void glLoadMatrixd (GLdouble *m);
	void glLoadMatrixf (GLfloat *m);
	void glLoadName (GLuint name);
	void glLogicOp (GLenum opcode);
	void glMap1d (GLenum target, GLdouble u1, GLdouble u2, GLint stride, GLint order, GLdouble *points);
	void glMap1f (GLenum target, GLfloat u1, GLfloat u2, GLint stride, GLint order, GLfloat *points);
	void glMap2d (GLenum target, GLdouble u1, GLdouble u2, GLint ustride, GLint uorder, GLdouble v1, GLdouble v2, GLint vstride, GLint vorder, GLdouble *points);
	void glMap2f (GLenum target, GLfloat u1, GLfloat u2, GLint ustride, GLint uorder, GLfloat v1, GLfloat v2, GLint vstride, GLint vorder, GLfloat *points);
	void glMapGrid1d (GLint un, GLdouble u1, GLdouble u2);
	void glMapGrid1f (GLint un, GLfloat u1, GLfloat u2);
	void glMapGrid2d (GLint un, GLdouble u1, GLdouble u2, GLint vn, GLdouble v1, GLdouble v2);
	void glMapGrid2f (GLint un, GLfloat u1, GLfloat u2, GLint vn, GLfloat v1, GLfloat v2);
	void glMaterialf (GLenum face, GLenum pname, GLfloat param);
	void glMaterialfv (GLenum face, GLenum pname, GLfloat *params);
	void glMateriali (GLenum face, GLenum pname, GLint param);
	void glMaterialiv (GLenum face, GLenum pname, GLint *params);
	void glMatrixMode (GLenum mode);
	void glMultMatrixd (GLdouble *m);
	void glMultMatrixf (GLfloat *m);
	void glNewList (GLuint list, GLenum mode);
	void glNormal3b (GLbyte nx, GLbyte ny, GLbyte nz);
	void glNormal3bv (GLbyte *v);
	void glNormal3d (GLdouble nx, GLdouble ny, GLdouble nz);
	void glNormal3dv (GLdouble *v);
	void glNormal3f (GLfloat nx, GLfloat ny, GLfloat nz);
	void glNormal3fv (GLfloat *v);
	void glNormal3i (GLint nx, GLint ny, GLint nz);
	void glNormal3iv (GLint *v);
	void glNormal3s (GLshort nx, GLshort ny, GLshort nz);
	void glNormal3sv (GLshort *v);
	void glNormalPointer (GLenum type, GLsizei stride, GLvoid *pointer);
	void glOrtho (GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar);
	void glPassThrough (GLfloat token);
	void glPixelMapfv (GLenum map, GLsizei mapsize, GLfloat *values);
	void glPixelMapuiv (GLenum map, GLsizei mapsize, GLuint *values);
	void glPixelMapusv (GLenum map, GLsizei mapsize, GLushort *values);
	void glPixelStoref (GLenum pname, GLfloat param);
	void glPixelStorei (GLenum pname, GLint param);
	void glPixelTransferf (GLenum pname, GLfloat param);
	void glPixelTransferi (GLenum pname, GLint param);
	void glPixelZoom (GLfloat xfactor, GLfloat yfactor);
	void glPointSize (GLfloat size);
	void glPolygonMode (GLenum face, GLenum mode);
	void glPolygonOffset (GLfloat factor, GLfloat units);
	void glPolygonStipple (GLubyte *mask);
	void glPopAttrib ();
	void glPopClientAttrib ();
	void glPopMatrix ();
	void glPopName ();
	void glPrioritizeTextures (GLsizei n, GLuint *textures, GLclampf *priorities);
	void glPushAttrib (GLbitfield mask);
	void glPushClientAttrib (GLbitfield mask);
	void glPushMatrix ();
	void glPushName (GLuint name);
	void glRasterPos2d (GLdouble x, GLdouble y);
	void glRasterPos2dv (GLdouble *v);
	void glRasterPos2f (GLfloat x, GLfloat y);
	void glRasterPos2fv (GLfloat *v);
	void glRasterPos2i (GLint x, GLint y);
	void glRasterPos2iv (GLint *v);
	void glRasterPos2s (GLshort x, GLshort y);
	void glRasterPos2sv (GLshort *v);
	void glRasterPos3d (GLdouble x, GLdouble y, GLdouble z);
	void glRasterPos3dv (GLdouble *v);
	void glRasterPos3f (GLfloat x, GLfloat y, GLfloat z);
	void glRasterPos3fv (GLfloat *v);
	void glRasterPos3i (GLint x, GLint y, GLint z);
	void glRasterPos3iv (GLint *v);
	void glRasterPos3s (GLshort x, GLshort y, GLshort z);
	void glRasterPos3sv (GLshort *v);
	void glRasterPos4d (GLdouble x, GLdouble y, GLdouble z, GLdouble w);
	void glRasterPos4dv (GLdouble *v);
	void glRasterPos4f (GLfloat x, GLfloat y, GLfloat z, GLfloat w);
	void glRasterPos4fv (GLfloat *v);
	void glRasterPos4i (GLint x, GLint y, GLint z, GLint w);
	void glRasterPos4iv (GLint *v);
	void glRasterPos4s (GLshort x, GLshort y, GLshort z, GLshort w);
	void glRasterPos4sv (GLshort *v);
	void glReadBuffer (GLenum mode);
	void glReadPixels (GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels);
	void glRectd (GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2);
	void glRectdv (GLdouble *v1, GLdouble *v2);
	void glRectf (GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2);
	void glRectfv (GLfloat *v1, GLfloat *v2);
	void glRecti (GLint x1, GLint y1, GLint x2, GLint y2);
	void glRectiv (GLint *v1, GLint *v2);
	void glRects (GLshort x1, GLshort y1, GLshort x2, GLshort y2);
	void glRectsv (GLshort *v1, GLshort *v2);
	GLint glRenderMode (GLenum mode);
	void glRotated (GLdouble angle, GLdouble x, GLdouble y, GLdouble z);
	void glRotatef (GLfloat angle, GLfloat x, GLfloat y, GLfloat z);
	void glScaled (GLdouble x, GLdouble y, GLdouble z);
	void glScalef (GLfloat x, GLfloat y, GLfloat z);
	void glScissor (GLint x, GLint y, GLsizei width, GLsizei height);
	void glSelectBuffer (GLsizei size, GLuint *buffer);
	void glShadeModel (GLenum mode);
	void glStencilFunc (GLenum func, GLint ref_, GLuint mask);
	void glStencilMask (GLuint mask);
	void glStencilOp (GLenum fail, GLenum zfail, GLenum zpass);
	void glTexCoord1d (GLdouble s);
	void glTexCoord1dv (GLdouble *v);
	void glTexCoord1f (GLfloat s);
	void glTexCoord1fv (GLfloat *v);
	void glTexCoord1i (GLint s);
	void glTexCoord1iv (GLint *v);
	void glTexCoord1s (GLshort s);
	void glTexCoord1sv (GLshort *v);
	void glTexCoord2d (GLdouble s, GLdouble t);
	void glTexCoord2dv (GLdouble *v);
	void glTexCoord2f (GLfloat s, GLfloat t);
	void glTexCoord2fv (GLfloat *v);
	void glTexCoord2i (GLint s, GLint t);
	void glTexCoord2iv (GLint *v);
	void glTexCoord2s (GLshort s, GLshort t);
	void glTexCoord2sv (GLshort *v);
	void glTexCoord3d (GLdouble s, GLdouble t, GLdouble r);
	void glTexCoord3dv (GLdouble *v);
	void glTexCoord3f (GLfloat s, GLfloat t, GLfloat r);
	void glTexCoord3fv (GLfloat *v);
	void glTexCoord3i (GLint s, GLint t, GLint r);
	void glTexCoord3iv (GLint *v);
	void glTexCoord3s (GLshort s, GLshort t, GLshort r);
	void glTexCoord3sv (GLshort *v);
	void glTexCoord4d (GLdouble s, GLdouble t, GLdouble r, GLdouble q);
	void glTexCoord4dv (GLdouble *v);
	void glTexCoord4f (GLfloat s, GLfloat t, GLfloat r, GLfloat q);
	void glTexCoord4fv (GLfloat *v);
	void glTexCoord4i (GLint s, GLint t, GLint r, GLint q);
	void glTexCoord4iv (GLint *v);
	void glTexCoord4s (GLshort s, GLshort t, GLshort r, GLshort q);
	void glTexCoord4sv (GLshort *v);
	void glTexCoordPointer (GLint size, GLenum type, GLsizei stride, GLvoid *pointer);
	void glTexEnvf (GLenum target, GLenum pname, GLfloat param);
	void glTexEnvfv (GLenum target, GLenum pname, GLfloat *params);
	void glTexEnvi (GLenum target, GLenum pname, GLint param);
	void glTexEnviv (GLenum target, GLenum pname, GLint *params);
	void glTexGend (GLenum coord, GLenum pname, GLdouble param);
	void glTexGendv (GLenum coord, GLenum pname, GLdouble *params);
	void glTexGenf (GLenum coord, GLenum pname, GLfloat param);
	void glTexGenfv (GLenum coord, GLenum pname, GLfloat *params);
	void glTexGeni (GLenum coord, GLenum pname, GLint param);
	void glTexGeniv (GLenum coord, GLenum pname, GLint *params);
	void glTexImage1D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLint border, GLenum format, GLenum type, GLvoid *pixels);
	void glTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, GLvoid *pixels);
	void glTexParameterf (GLenum target, GLenum pname, GLfloat param);
	void glTexParameterfv (GLenum target, GLenum pname, GLfloat *params);
	void glTexParameteri (GLenum target, GLenum pname, GLint param);
	void glTexParameteriv (GLenum target, GLenum pname, GLint *params);
	void glTexSubImage1D (GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, GLvoid *pixels);
	void glTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels);
	void glTranslated (GLdouble x, GLdouble y, GLdouble z);
	void glTranslatef (GLfloat x, GLfloat y, GLfloat z);
	void glVertex2d (GLdouble x, GLdouble y);
	void glVertex2dv (GLdouble *v);
	void glVertex2f (GLfloat x, GLfloat y);
	void glVertex2fv (GLfloat *v);
	void glVertex2i (GLint x, GLint y);
	void glVertex2iv (GLint *v);
	void glVertex2s (GLshort x, GLshort y);
	void glVertex2sv (GLshort *v);
	void glVertex3d (GLdouble x, GLdouble y, GLdouble z);
	void glVertex3dv (GLdouble *v);
	void glVertex3f (GLfloat x, GLfloat y, GLfloat z);
	void glVertex3fv (GLfloat *v);
	void glVertex3i (GLint x, GLint y, GLint z);
	void glVertex3iv (GLint *v);
	void glVertex3s (GLshort x, GLshort y, GLshort z);
	void glVertex3sv (GLshort *v);
	void glVertex4d (GLdouble x, GLdouble y, GLdouble z, GLdouble w);
	void glVertex4dv (GLdouble *v);
	void glVertex4f (GLfloat x, GLfloat y, GLfloat z, GLfloat w);
	void glVertex4fv (GLfloat *v);
	void glVertex4i (GLint x, GLint y, GLint z, GLint w);
	void glVertex4iv (GLint *v);
	void glVertex4s (GLshort x, GLshort y, GLshort z, GLshort w);
	void glVertex4sv (GLshort *v);
	void glVertexPointer (GLint size, GLenum type, GLsizei stride, GLvoid *pointer);
	void glViewport (GLint x, GLint y, GLsizei width, GLsizei height);
}