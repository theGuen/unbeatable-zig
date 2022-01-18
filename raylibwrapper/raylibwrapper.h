
#ifndef raylibwrapper_h
#define raylibwrapper_h
#include <raylib.h>
void WrapDrawRectangleRec(Rectangle* rect, Color color);
bool WrapCheckCollisionPointRec(Vector2* vec, Rectangle* rect);
#endif