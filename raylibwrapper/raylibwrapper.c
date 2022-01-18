#include "raylibwrapper.h"

void WrapDrawRectangleRec(Rectangle* rect, Color color){
    DrawRectangleRec(*rect, color);
}

bool WrapCheckCollisionPointRec(Vector2* vec, Rectangle* rect){
    return CheckCollisionPointRec(*vec, *rect);
}