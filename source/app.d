import raylib;
import std.stdio;

void main()
{
    validateRaylibBinding();
    InitWindow(800, 600, "Hello, Raylib-D!");
    SetTargetFPS(60);
    while (!WindowShouldClose())
    {
        BeginDrawing();
        ClearBackground(Colors.RAYWHITE);
        EndDrawing();
    }
    CloseWindow();
}