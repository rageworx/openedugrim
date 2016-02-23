#include <cstdio>
#include <cstdlib>
#include <cstring>

#include "lua.hpp"
#include "luaproc.h"

LuaProcContainer::LuaProcContainer( LuaHandler* h )
 : handler( h ),
   loaded( false ),
   scripts( NULL ),
   scripts_sz( 0 ),
   debug_mode( 0 )
{
}

LuaProcContainer::~LuaProcContainer()
{

}

bool LuaProcContainer::LoadScript( const char* afile )
{
    if ( loaded == false )
    {

    }

    return false;
}

bool LuaProcContainer::LoadScript( const wchar_t* wfile )
{
    if ( loaded == false )
    {

    }

    return false;
}

bool LuaProcContainer::LoadBufferScript( const char* src )
{
    if ( loaded == false )
    {
        scripts_sz = strlen( src );
        if ( scripts_sz > 0 )
        {
            if ( scripts != NULL )
            {
                delete[] scripts;
                scripts = NULL;
            }

            scripts = new char[ scripts_sz ];
            if ( scripts != NULL )
            {
                memcpy( scripts, src, scripts_sz );
                loaded = true;

                return loaded;
            }
        }
    }

    return false;
}

void LuaProcContainer::Unload()
{
    if ( loaded == true )
    {
        Stop();

        if ( scripts != NULL )
        {
            delete[] scripts;
            scripts = NULL;

            loaded = false;
        }
    }
}

void LuaProcContainer::Debug( bool enable )
{
    if ( enable == true )
    {
        debug_mode = 1;
    }
    else
    {
        debug_mode = 0;
    }
}

int LuaProcContainer::Run()
{
    if ( loaded == true )
    {

    }

    return -1;
}

int LuaProcContainer::Stop()
{

    return -1;
}

void LuaProcContainer::registerAdditionalFunctions()
{

}
