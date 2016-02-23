#include <FL/x.H>
#include <FL/Fl.H>
#include <FL/Fl_Double_Window.H>

#include "FL/Fl_Highlight_Editor.H"


class MainWindow
{
    public:
        MainWindow();
        virtual ~MainWindow();

    public:
        int Run();
        void RepaintSHE();

    protected:
        void createcomponents();

    protected:
        Fl_Double_Window*       mwindow;
        Fl_Highlight_Editor*    sheditor;
        Fl_Text_Buffer*         shbuffer;
};
