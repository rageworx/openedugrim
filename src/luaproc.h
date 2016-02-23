#ifndef __LUAPROC_H__
#define __LUAPROC_H__

class LuaHandler
{
    public:
        virtual int Handle( int id, void* parma );
};

class LuaProcContainer
{
    public:
        LuaProcContainer( LuaHandler* h );
        ~LuaProcContainer();

    public:
        bool LoadScript( const char* afile );
        bool LoadScript( const wchar_t* wfile );
        bool LoadBufferScript( const char* src );
        void Unload();

    public:
        void Debug( bool enable );
        int  Run();
        int  Stop();

    private:
        void registerAdditionalFunctions();

    private:
        LuaHandler*     handler;
        bool            loaded;
        char*           scripts;
        unsigned int    scripts_sz;
        int             debug_mode;
};

#endif /// of __LUAPROC_H__
