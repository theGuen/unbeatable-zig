
#ifndef raylibwrapper_h
#define raylibwrapper_h
#include <raylib.h>
// TODO: I am not able to pass a rectangle struct so here is a little helper to pass a pointer
void WrapDrawRectangleRec(Rectangle* rect, Color color);
bool WrapCheckCollisionPointRec(Vector2* vec, Rectangle* rect);
#endif