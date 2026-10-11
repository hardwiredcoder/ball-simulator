import raylib;

void main()
{
    validateRaylibBinding();

    InitWindow(GetScreenWidth(), GetScreenHeight(), "Hello, Raylib-D!");
    MaximizeWindow();
    SetTargetFPS(60);
    Font GemunuLibre = LoadFont("GemunuLibre-Bold.ttf");
    while (!WindowShouldClose())
    {
        if(IsKeyPressed(KeyboardKey.KEY_ONE))
        {
            ToggleFullscreen();
        }
        
        BeginDrawing();

        ClearBackground(Colors.BLACK);
        DrawTextEx(GemunuLibre, "press escape to quit", Vector2(0, 0), 28, 2, Colors.DARKGRAY);
        DrawTextEx(GemunuLibre, "press 1 to toggle fullscreen", Vector2(0, 21), 28, 2, Colors.DARKGRAY);
        
        DrawCircle(400, 400, 16, Colors.MAROON);

        EndDrawing();
    }
    CloseWindow();
}