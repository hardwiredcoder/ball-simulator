import raylib;
import std.stdio;
import std.string;
import std.conv;
import std.format;
import core.thread;

int amount_of_balls = 0;

int gravatarButtonTimeTilReset = 0;

string alphabet = "abcdefghijklmnopqrstuvwxyz";

float[] balls = [-0, -0, -0, -0, -0, -0, -0, -0];
/**
first item 0: x position
second item 1: y position
third item 2: x velocity
fourth item 3: y velocity
fifth item 4: x gravity
sixth item 5: y gravity
seventh item 6: drag
eight item 7: radius/size
**/

void main()     // this is the main function that connects all of the runtime code together and it's automatically ran after compiling
{
    validateRaylibBinding();

    InitWindow(0, 0, "Ball Simulator by Elijah S.");   // the "0, 0" would be the width by height, but it's not affecting anything for some reason

    MaximizeWindow();
    SetTargetFPS(150);

    float[] spawningBallsSettings = [0, 0, 0, 0.1, 0.994, GetScreenHeight() / 500];  // the spawning balls settings do not include x position or y position as it spawns based on the user's mouse position
    float[] min_spawningBallsSettings = [0 - ((GetScreenWidth() / 3) * 2), 0 - ((GetScreenHeight() / 3) * 2), 0 - (GetScreenWidth() / 100), 0 - (GetScreenHeight() / 100), 1, GetScreenHeight() / 100];

    Font GemunuLibre = LoadFont("GemunuLibre-Bold.ttf");    // this is loading a font from a file and calling it "GemunuLibre," so "GemunuLibre" will be written in DrawTextEx() to use the font

    while (!WindowShouldClose())    // you can only draw in this statement and this is where all of the game code should typically go
    {
        if (IsKeyPressed(KeyboardKey.KEY_ONE))
        {
            ToggleFullscreen();
        }
        
        BeginDrawing();     // this will allow raylib to draw to the window

        if (IsWindowFullscreen())
        {   // this gets the background
            render(GemunuLibre);
        }
        else
        {        
            ClearBackground(Colors.GRAY);

            DrawTextEx(GemunuLibre, "sorry, fullscreen is required! please press 1", Vector2(0, 0), 50, 2, Colors.BLACK);
            DrawTextEx(GemunuLibre, "or press escape to quit", Vector2(0, 50), 40, 2, Colors.DARKGRAY);
        }

        if (IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT))
        {   // spawns a new ball or copies my gravatar link
            if ( (GetMouseX() > 0  &&  GetMouseX() < GetScreenWidth() / 8)  &&  (GetMouseY() > (GetScreenHeight() / 80) * 77  &&  GetMouseY() < GetScreenHeight() / 1))
            {   // copy my gravatar link
                gravatarButtonTimeTilReset = 100;
            }
            else
            {   // spawn a new ball
                balls ~= [GetMouseX(), GetMouseY(), spawningBallsSettings[0], spawningBallsSettings[1], spawningBallsSettings[2], spawningBallsSettings[3], spawningBallsSettings[4], spawningBallsSettings[5]];
                amount_of_balls += 1;
            }
        }

        if (IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_MIDDLE))
        {   // changes settings for new balls

        }

        if (IsKeyPressed(KeyboardKey.KEY_DELETE))
        {   // deletes all the balls
            balls = [-0, -0, -0, -0, -0, -0, -0];
            amount_of_balls = 0;
        }

        if (gravatarButtonTimeTilReset > 0)
        {
            gravatarButtonTimeTilReset -= 1;
        }

        EndDrawing();   // this will stop allowing raylib to draw to the window

    }
    CloseWindow();
}

void render(Font GemunuLibre)
{
    ClearBackground(Colors.BLACK);

    DrawLineEx(Vector2(( (GetScreenWidth() / 2) - 800 ), ( (GetScreenHeight() / 2) + 350 )), Vector2((( GetScreenWidth() / 2) + 800 ), ( (GetScreenHeight() / 2) + 350 )), 3, Colors.LIGHTGRAY);

    //left-aligned
    DrawTextEx(GemunuLibre, "press escape to quit", Vector2(0, 0), GetScreenWidth() / 80, 2, Colors.GRAY);     // (font, text, position, size, letter-spacing, color) the position is put in Vector2() for DrawTextEx()
    DrawTextEx(GemunuLibre, "press 1 to toggle fullscreen", Vector2(0, GetScreenHeight() / 45), GetScreenWidth() / 80, 2, Colors.GRAY);

    DrawTextEx(GemunuLibre, "press delete to kill all of the balls", Vector2(0, GetScreenHeight() / 15), GetScreenWidth() / 80, 2, Colors.GRAY);

    if (gravatarButtonTimeTilReset > 0)
    {
        DrawRectangle(0, (GetScreenHeight() / 80) * 77, (GetScreenWidth() / 10) * 2, GetScreenHeight() / 1, Colors.GRAY);
        DrawRectangle(2, ((GetScreenHeight() / 80) * 77) + 2, ((GetScreenWidth() / 10) * 2) - 4, (GetScreenHeight() / 26) - 4, Colors.BLACK);
        DrawTextEx(GemunuLibre, "Copied, paste it in your browser!", Vector2(25, (GetScreenHeight() / 80) * 77), (GetScreenHeight() / 26) - 4, 2, Colors.GRAY);
    }
    else
    {
        DrawRectangle(0, (GetScreenHeight() / 80) * 77, GetScreenWidth() / 8, GetScreenHeight() / 1, Colors.GRAY);
        DrawRectangle(2, ((GetScreenHeight() / 80) * 77) + 2, (GetScreenWidth() / 8) - 4, (GetScreenHeight() / 26) - 4, Colors.BLACK);
        DrawTextEx(GemunuLibre, "Elijah S. on Gravatar", Vector2(25, (GetScreenHeight() / 80) * 77), (GetScreenHeight() / 26) - 4, 2, Colors.GRAY);
    }

    //right-aligned
    DrawTextEx(GemunuLibre, ("SIMULATING " ~ to!string(amount_of_balls) ~ " BALLS").toStringz(), Vector2( ( ( (GetScreenWidth() / 80) * 72.3 ) - ( to!string(amount_of_balls).length * ( GetScreenWidth() / 80) /2 ) ), 0), GetScreenWidth()/80, 2, Colors.GRAY);   // a big chunk of this is doing the math to right-align it on the right side of the screen because it's automatically left-aligned

    DrawTextEx(GemunuLibre, ("MOUSE X: " ~ to!string(GetMouseX())).toStringz(), Vector2( ( ( (GetScreenWidth() / 80) * 76 ) - ( to!string(GetMouseX()).length * (GetScreenWidth() / 80) / 2 ) ), (GetScreenHeight() / 80) * 4), GetScreenWidth() / 80, 2, Colors.GRAY);

    simulateBallsTick();
}

int mathSign(float a)
{
    if (a > 0)
    {
        return 1;
    }
    else if (a < 0)
    {
        return -1;
    }
    else
    {
        return 0;
    }
}

void simulateBallsTick()
{
    if (balls.length == 0) {return;}

    for (int i = 1; i < balls.length / 8; i++) // this first creates int i for this loop, will repeat for as long as i is less than the amount of items in the balls array, and increase the i variable every loop around
    {
        balls[(i * 8) + 2] = balls[(i * 8) + 2] * balls[(i * 8) + 5];
        balls[(i * 8) + 3] = balls[(i * 8) + 3] * balls[(i * 8) + 6];

        balls[i * 8] += balls[(i * 8) + 2];
        balls[(i * 8) + 1] += balls[(i * 8) + 3];

        DrawCircle(to!int(balls[i * 8]), to!int(balls[(i * 8) + 1]), balls[(i * 8) + 7], Colors.MAROON);

        if (balls[(i * 8) + 1] >= (GetScreenHeight() / 2) + 320)
        {
            balls[(i * 8) + 2] = 0 - balls[(i * 8) + 2];    // sets x velocity to the opposite value of x velocity (5 = -5 or -12 = 12)
            balls[i * 8] += balls[(i * 8) + 2];     // changes the x position by the x velocity
            balls[(i * 8) + 1] += 0 - balls[(i * 8) + 3];   // changes the y position by the opposite of the y velocity
            balls[(i * 8) + 3] = 0 - balls[(i * 8) + 3];    // sets the y velocity to the opposite of itself
        }
        else
        {
            balls[(i * 8) + 2] -= mathSign(balls[(i * 8) + 2]) / 90;
            balls[(i * 8) + 3] -= mathSign(balls[(i * 8) + 3]) / 90;
        }

        if (balls[(i * 8) + 1] < (GetScreenHeight() / 2) + 320)
        {
            balls[(i * 8) + 2] += balls[(i * 8) + 4];
            balls[(i * 8) + 3] += balls[(i * 8) + 5];
        }
    }
}