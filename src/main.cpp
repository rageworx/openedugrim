#include "main.h"
#include "mainWindow.h"

static MainWindow* mWindow = NULL;

int main( int argc, char** argv )
{
    mWindow = new MainWindow();

    if ( mWindow != NULL )
    {
        return mWindow->Run();
    }

    return 0;
}
