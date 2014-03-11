title: Highlighting No Markdown
highlight:off
+++
Here's some code to highlight:

~~~ cpp
#include <AtlasUtils/Plugin.h>
#include <AtlasUtils/PluginRegistry.h>

#include "Cube.h"

class CUBE_Plugin: public AtlasUtils::Plugin<AtlasSG::NodePtr>
{
    public:
        // The constructor calls the super-class constructor
        // passing it the plug-in's name "cube"
        CUBE_Plugin():
            AtlasUtils::Plugin<AtlasSG::NodePtr>("cube")
        {
        }

        // The read method will be called whenever a request is
        // made to open a file with an extension ".cube"
        virtual AtlasSG::NodePtr read( const std::string &amp;filename )
        {
            // Since this is a pseudo-plug-in we can ignore the filename

            return AtlasSG::NodePtr( new Cube );
        }

        virtual bool write( AtlasSG::NodePtr, const std::string &amp;)
        { 
            return false;
        }
};


// The PLUGIN_PROXY macro instantiates an object of class CUBE_Plugin
// when the dynamic shared object is loaded.

PLUGIN_PROXY( CUBE_Plugin )
~~~

And here's an inline `def call; end`{: .language-ruby} Ruby code.

Here's one that's left untouched: `def call; end`{: #untouched1}

Here's another that's left untouched: <span id="untouched2" class="language-ruby">def call; end</span>
