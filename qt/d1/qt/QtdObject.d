/**
*
*  Copyright: Copyright QtD Team, 2008-2009
*  License: <a href="http://www.boost.org/LICENSE_1_0.txt>Boost License 1.0</a>
*
*  Copyright QtD Team, 2008-2009
*  Distributed under the Boost Software License, Version 1.0.
*  (See accompanying file boost-license-1.0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
*
*/

module qt.QtdObject;

import qt.Signal;

enum QtdObjectFlags : ubyte
{
    none,
    nativeOwnership           = 0x1,
    dOwnership                = 0x2,
    //gcManaged               = 0x4
}

package abstract class QtdObject
{
private:
    QtdObjectFlags __flags_;

public:
    void* __nativeId;
    
    mixin SignalHandlerOps;
    
    this(void* nativeId, QtdObjectFlags flags = QtdObjectFlags.none)
    {
        __nativeId = nativeId;
        __flags_ = flags;
    }

    final QtdObjectFlags __flags()
    {
        return __flags_;
    }

    /+ final +/ void __setFlags(QtdObjectFlags flags, bool value)
    {
        if (value)
            __flags_ |= flags;
        else
            __flags_ &= ~flags;
    }

    // COMPILER BUG: 3206
    protected void __deleteNative()
    {
        assert(false);
    }

    ~this()
    {
        if (!(__flags_ & QtdObjectFlags.nativeOwnership))
        {
            // avoid deleting D object twice.
            __flags_ |= QtdObjectFlags.dOwnership;
            __deleteNative;
        }
    }
}