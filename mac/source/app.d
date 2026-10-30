import raylib;
import std.stdio;
import std.string;
import std.conv;
import std.format;
import core.thread;

int amount_of_balls = 0;

int gravatarButtonTimeTilReset = 0;

int[] collisionBoxes = [0, 0, 0, 0, 0];
/**
first item 0: starting x position
second item 1: starting y position
third item 2: ending x position
fourth item 3: ending y position
**/

float[] balls = [0, 0, 0, 0, 0, 0, 0, 0];
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
    SetTargetFPS(200);

    float[] spawningBallsSettings = [0, 0, 0, 0.1, 0.995, 20];  // the spawning balls settings do not include x position or y position as it should spawn based on the user's mouse position

    int firstPointX, firstPointY;
    int scrollForSize = 20;
    int createBallTimeTilSpam = 0;

    bool drawingBox = false, drawingBall = false;

    collisionBoxes ~= [0, 0, 0, GetScreenHeight(), 1];
    collisionBoxes ~= [GetScreenWidth(), 0, GetScreenWidth(), GetScreenHeight(), 1];
    collisionBoxes ~= [0, 0, GetScreenWidth(), 0, 1];
    collisionBoxes ~= [0, GetScreenHeight(), GetScreenWidth(), GetScreenHeight(), 1];

    Font GemunuLibre = LoadFont("GemunuLibre-Bold.ttf");    // this is loading a font from a file and calling it "GemunuLibre," so "GemunuLibre" will be written in DrawTextEx() to use the font

    while (!WindowShouldClose())    // you can only draw in this statement and this is where all of the game code should typically go
    {
        if (IsKeyPressed(KeyboardKey.KEY_ONE))
        {
            ToggleFullscreen();
        }

        BeginDrawing();     // this will allow raylib to draw to the window

        if (!drawingBall  &&  IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_MIDDLE)  &&  !(IsMouseButtonDown(MouseButton.MOUSE_BUTTON_RIGHT)))
        {
            firstPointX = GetMouseX();
            firstPointY = GetMouseY();

            drawingBall = true;
        }
        else if (drawingBall  &&  IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)  &&  !(IsMouseButtonDown(MouseButton.MOUSE_BUTTON_RIGHT)))
        {
            drawingBall = false;

            spawningBallsSettings[5] = scrollForSize;

            balls ~= [firstPointX, firstPointY, (GetMouseX()-firstPointX)/(GetScreenWidth()/90), (GetMouseY()-firstPointY)/(GetScreenWidth()/35), spawningBallsSettings[2], spawningBallsSettings[3], spawningBallsSettings[4], spawningBallsSettings[5]];
            amount_of_balls += 1;

            createBallTimeTilSpam = 120;
        }
        else if (drawingBall  &&  !(IsMouseButtonDown(MouseButton.MOUSE_BUTTON_RIGHT)))
        {
            if (scrollForSize + to!int(GetMouseWheelMove())*2 > 0) { scrollForSize += to!int(GetMouseWheelMove())*2; }

            DrawLine(firstPointX, firstPointY, GetMouseX(), GetMouseY(), Colors.LIGHTGRAY);

            DrawCircle(firstPointX, firstPointY, scrollForSize, Colors.LIGHTGRAY);
            DrawCircle(firstPointX, firstPointY, scrollForSize-3, Colors.BLACK);
            DrawTextEx(GemunuLibre, toStringz("scroll to change\nsize: " ~ to!string(scrollForSize)), Vector2(firstPointX, firstPointY-ratpresV(12)-scrollForSize), ratpresV(6), 2, Colors.GRAY);

            DrawTextEx(GemunuLibre, toStringz("x vel: " ~ to!string( (GetMouseX()-firstPointX)/(GetScreenWidth()/90)) ), Vector2(GetMouseX(), GetMouseY()-40), ratpresV(6), 2, Colors.GRAY);
            DrawTextEx(GemunuLibre, toStringz("y vel: " ~ to!string( (GetMouseY()-firstPointY)/(GetScreenWidth()/35)) ), Vector2(GetMouseX(), GetMouseY()), ratpresV(6), 2, Colors.GRAY);

            DrawTextEx(GemunuLibre, "left click to release", Vector2((firstPointX+GetMouseX())/2, (firstPointY+GetMouseY())/2), ((ratpresV(5)/2)+mathAbsolute((firstPointX-GetMouseX())/50) + (ratpresV(5)/2)+mathAbsolute((firstPointY-GetMouseY())/50))/2, 2, Colors.GRAY);
        }

        if (IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT)  &&  !drawingBall)
        {   // spamming new ball system
            if (createBallTimeTilSpam == 0)
            {
                balls ~= [GetMouseX(), GetMouseY(), spawningBallsSettings[0], spawningBallsSettings[1], spawningBallsSettings[2], spawningBallsSettings[3], spawningBallsSettings[4], spawningBallsSettings[5]];
                amount_of_balls += 1;
            }
            else if (createBallTimeTilSpam > 0)
            {
                createBallTimeTilSpam -= 1;
            }
        }
        else if (createBallTimeTilSpam == 0)
        {
            createBallTimeTilSpam = 100;
        }

        if (IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)  &&  !drawingBall)
        {   // spawns a new ball or copies my gravatar link
            if ( (GetMouseX() > 0  &&  GetMouseX() < GetScreenWidth() / 8)  &&  (GetMouseY() > (GetScreenHeight() / 80) * 77  &&  GetMouseY() < GetScreenHeight() / 1))
            {   // copy my gravatar link
                SetClipboardText("https://gravatar.com/thingso1355be1e86");
                gravatarButtonTimeTilReset = 500;
            }
            else if (createBallTimeTilSpam > 0  &&  createBallTimeTilSpam <= 100)
            {   // spawn a new ball
                balls ~= [GetMouseX(), GetMouseY(), spawningBallsSettings[0], spawningBallsSettings[1], spawningBallsSettings[2], spawningBallsSettings[3], spawningBallsSettings[4], spawningBallsSettings[5]];
                amount_of_balls += 1;
            }
        }

        if (IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_RIGHT)  &&  !(IsMouseButtonDown(MouseButton.MOUSE_BUTTON_MIDDLE)))
        {   // starts drawing a collision box/rectangle and sets the first point to where the mouse position is
            firstPointX = GetMouseX();
            firstPointY = GetMouseY();

            drawingBox = true;
        }
        else if (drawingBox  &&  IsMouseButtonReleased(MouseButton.MOUSE_BUTTON_RIGHT))
        {   // this places the rectangle once you have released the right mouse button
            drawingBox = false;

            if (firstPointX < GetMouseX())
            {
                if (firstPointY < GetMouseY())
                {
                    collisionBoxes ~= [firstPointX, firstPointY, GetMouseX(), GetMouseY(), 1];
                }
                else if (firstPointY > GetMouseY())
                {
                    collisionBoxes ~= [firstPointX, GetMouseY(), GetMouseX(), firstPointY, 1];
                }
            }
            else if (firstPointX > GetMouseX())
            {
                if (firstPointY < GetMouseY())
                {
                    collisionBoxes ~= [GetMouseX(), firstPointY, firstPointX, GetMouseY(), 1];
                }
                else if (firstPointY > GetMouseY())
                {
                    collisionBoxes ~= [GetMouseX(), GetMouseY(), firstPointX, firstPointY, 1];
                }
            }
        }
        else if (IsMouseButtonDown(MouseButton.MOUSE_BUTTON_RIGHT)  &&  !(IsMouseButtonDown(MouseButton.MOUSE_BUTTON_MIDDLE)))
        {   // this draws the rectangle for visualization while you're placing the second point where you want
            if (firstPointX < GetMouseX())
            {
                if (firstPointY < GetMouseY())
                {
                    DrawRectangle(firstPointX, firstPointY, GetMouseX() - firstPointX, GetMouseY() - firstPointY, Colors.WHITE);
                }
                else if (firstPointY > GetMouseY())
                {
                    DrawRectangle(firstPointX, GetMouseY(), GetMouseX() - firstPointX, firstPointY - GetMouseY(), Colors.WHITE);
                }
            }
            else if (firstPointX > GetMouseX())
            {
                if (firstPointY < GetMouseY())
                {
                    DrawRectangle(GetMouseX(), firstPointY, firstPointX - GetMouseX(), GetMouseY() - firstPointY, Colors.WHITE);
                }
                else if (firstPointY > GetMouseY())
                {
                    DrawRectangle(GetMouseX(), GetMouseY(), firstPointX - GetMouseX(), firstPointY - GetMouseY(), Colors.WHITE);
                }
            }
        }

        if (IsKeyPressed(KeyboardKey.KEY_BACKSPACE))
        {   // deletes all the balls
            balls = [0, 0, 0, 0, 0, 0, 0, 0];
            amount_of_balls = 0;
        }

        if (IsKeyPressed(KeyboardKey.KEY_EQUAL))
        {
            collisionBoxes = [0, 0, 0, 0, 0];
            collisionBoxes ~= [0, 0, 0, GetScreenHeight(), 1];
            collisionBoxes ~= [GetScreenWidth(), 0, GetScreenWidth(), GetScreenHeight(), 1];
            collisionBoxes ~= [0, 0, GetScreenWidth(), 0, 1];
            collisionBoxes ~= [0, GetScreenHeight(), GetScreenWidth(), GetScreenHeight(), 1];
        }

        if (gravatarButtonTimeTilReset > 0)
        {
            gravatarButtonTimeTilReset -= 1;
        }

        if (IsWindowFullscreen())
        {
            renderAll(GemunuLibre);
        }
        else
        {
            ClearBackground(Colors.GRAY);

            DrawTextEx(GemunuLibre, "sorry, fullscreen is required! please press 1", Vector2(0, 0), 50, 2, Colors.BLACK);
            DrawTextEx(GemunuLibre, "or press escape to quit", Vector2(0, 50), 40, 2, Colors.DARKGRAY);
        }

        EndDrawing();   // this will stop allowing raylib to draw to the window

    }
    CloseWindow();
}

void renderAll(Font GemunuLibre)
{
    ClearBackground(Colors.BLACK);

    simulateBallsTick();
    renderBoxes();

    DrawTextEx(GemunuLibre, "press escape to quit", Vector2(0, 0), ratpresV(6), 2, Colors.GRAY);     // (font, text, position, size, letter-spacing, color) the position is put in Vector2() for DrawTextEx()
    DrawTextEx(GemunuLibre, "press 1 to toggle fullscreen", Vector2(0, ratpresV(5)), ratpresV(6), 2, Colors.GRAY);

    DrawTextEx(GemunuLibre, "press backspace to delete all of the balls", Vector2(0, ratpresV(15)), ratpresV(6), 2, Colors.GRAY);
    DrawTextEx(GemunuLibre, "press = to delete all of the boxes", Vector2(0, ratpresV(20)), ratpresV(6), 2, Colors.GRAY);
    DrawTextEx(GemunuLibre, "left click to spawn a ball", Vector2(0, ratpresV(25)), ratpresV(6), 2, Colors.GRAY);
    DrawTextEx(GemunuLibre, "right click to create a box", Vector2(0, ratpresV(30)), ratpresV(6), 2, Colors.GRAY);
    DrawTextEx(GemunuLibre, "middle click to create a ball with custom size and velocities", Vector2(0, ratpresV(35)), ratpresV(6), 2, Colors.GRAY);

    DrawTextEx(GemunuLibre, toStringz("FPS: " ~ to!string(GetFPS())), Vector2(0, ratpresV(45)), ratpresV(6), 2, Colors.GRAY);
    DrawTextEx(GemunuLibre, toStringz("SIMULATING " ~ to!string(amount_of_balls) ~ " BALLS"), Vector2(0, ratpresV(50)), ratpresV(6), 2, Colors.GRAY);

    DrawTextEx(GemunuLibre, toStringz("MOUSE X:  " ~ to!string(GetMouseX())), Vector2(0, ratpresV(60)), ratpresV(6), 2, Colors.GRAY);
    DrawTextEx(GemunuLibre, toStringz("MOUSE Y:  " ~ to!string(GetMouseY())), Vector2(0, ratpresV(65)), ratpresV(6), 2, Colors.GRAY);

    if (gravatarButtonTimeTilReset > 0)
    {
        DrawRectangle(0, 1386, 650, GetScreenHeight(), Colors.GRAY);
        DrawRectangle(2, 1388, 646, 50, Colors.BLACK);
        DrawTextEx(GemunuLibre, "Copied, paste it in your browser!", Vector2(25, (GetScreenHeight() / 80) * 77), (GetScreenHeight() / 26) - 4, 2, Colors.GRAY);
    }
    else
    {
        DrawRectangle(0, 1386, 442, GetScreenHeight(), Colors.GRAY);
        DrawRectangle(2, 1388, 438, 50, Colors.BLACK);
        DrawTextEx(GemunuLibre, "Elijah S. on Gravatar", Vector2(25, (GetScreenHeight() / 80) * 77), (GetScreenHeight() / 26) - 4, 2, Colors.GRAY);
    }
}

int ratpresH(int amount) { return (GetScreenWidth() / 200) * amount; }
int ratpresV(int amount) { return (GetScreenHeight() / 200) * amount; }

float mathAbsolute(float a)
{
    if (a < 0)
    {
        return 0-a;
    }

    return a;
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

void renderBoxes()
{
    for (int i = 1; i < collisionBoxes.length / 5; i++)
    {
        DrawRectangle(collisionBoxes[i * 5], collisionBoxes[(i * 5) + 1], collisionBoxes[(i * 5) + 2] - collisionBoxes[i * 5], collisionBoxes[(i * 5) + 3] - collisionBoxes[(i * 5) + 1], Colors.WHITE);
    }
}

void simulateBallsTick()
{
    if (balls.length == 0) {return;}

    for (int i = 1; i < balls.length / 8; i++) // this first creates int i for this loop, will repeat for as long as i is less than the amount of items in the balls array, and increase the i variable every loop around
    {
        balls[(i * 8) + 2] = balls[(i * 8) + 2] * balls[(i * 8) + 6];
        balls[(i * 8) + 3] = balls[(i * 8) + 3] * balls[(i * 8) + 6];

        balls[i * 8] += balls[(i * 8) + 2];
        balls[(i * 8) + 1] += balls[(i * 8) + 3];

        if (ballTouchingBox(i))
        {
            balls[i * 8] += 0 - balls[(i * 8) + 2];     // changes the x position by the opposite of the x velocity
            balls[(i * 8) + 2] = 0 - balls[(i * 8) + 2];    // sets x velocity to the opposite value of x velocity (5 = -5 or -12 = 12)
            balls[(i * 8) + 1] += 0 - balls[(i * 8) + 3];   // changes the y position by the opposite of the y velocity
            balls[(i * 8) + 3] = 0 - balls[(i * 8) + 3];    // sets the y velocity to the opposite of itself
        }
        else
        {
            balls[(i * 8) + 2] -= mathSign(balls[(i * 8) + 2]) / 90;
            balls[(i * 8) + 3] -= mathSign(balls[(i * 8) + 3]) / 90;
        }

        if (!ballTouchingBox(i))
        {
            balls[(i * 8) + 2] += balls[(i * 8) + 4];
            balls[(i * 8) + 3] += balls[(i * 8) + 5];
        }

        DrawCircle(to!int(balls[i * 8]), to!int(balls[(i * 8) + 1]), balls[(i * 8) + 7], Colors.MAROON);
    }
}

bool ballTouchingBox(int i)
{
    for (int boxNum = 1; boxNum < collisionBoxes.length / 5; boxNum++)
    {
        if (balls[i * 8] >= collisionBoxes[boxNum * 5] - balls[(i * 8) + 7]  &&  balls[i * 8] <= collisionBoxes[(boxNum * 5) + 2] + balls[(i * 8) + 7])   // checks if the ball is touching by the x position
        {
            if (balls[(i * 8) + 1] >= collisionBoxes[(boxNum * 5) + 1] - balls[(i * 8) + 7]  &&  balls[(i * 8) + 1] <= collisionBoxes[(boxNum * 5) + 3] + balls[(i * 8) + 7])   // checks if the ball is touching by the y position
            {
                return true;
            }
        }
    }

    return false;
}
