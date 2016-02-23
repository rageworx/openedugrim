#include "mainWindow.h"

#define DEFAULT_MWINDOW_WIDTH       640
#define DEFAULT_MWINDOW_HEIGHT      480
#define DEFAULT_MWINDOW_TITLE       "EduGrim"

void wcb( Fl_Widget* w, void* p )
{
    if ( ( w != NULL ) && ( p != NULL ) )
    {
        MainWindow* mw = (MainWindow*)p;
        mw->RepaintSHE();
    }
}

MainWindow::MainWindow()
{
    createcomponents();
}

MainWindow::~MainWindow()
{

}


int MainWindow::Run()
{
    if ( mwindow != NULL )
    {
        return Fl::run();
    }

    return 0;
}

void MainWindow::RepaintSHE()
{
    if ( sheditor != NULL )
    {
        sheditor->repaint( Fl_Highlight_Editor::REPAINT_ALL );
    }
}

void MainWindow::createcomponents()
{
    mwindow = new Fl_Double_Window( DEFAULT_MWINDOW_WIDTH,
                                    DEFAULT_MWINDOW_HEIGHT,
                                    DEFAULT_MWINDOW_TITLE );
    if ( mwindow != NULL )
    {
        mwindow->begin();

        sheditor = new Fl_Highlight_Editor(0,0,DEFAULT_MWINDOW_WIDTH,DEFAULT_MWINDOW_HEIGHT);
        if ( sheditor != NULL )
        {
            shbuffer = new Fl_Text_Buffer( 0, 1024*1024 );
            if ( shbuffer != NULL )
            {
                sheditor->buffer( shbuffer );
            }

            //sheditor->expand_tabs( 4 );
            sheditor->callback( wcb, this );
            sheditor->init_interpreter("./scheme");

        }

        mwindow->resizable( sheditor );
        mwindow->end();
        mwindow->show();

        RepaintSHE();
    }
}
