/*****************************************************************\
           __
          / /
		 / /                     __  __
		/ /______    _______    / / / / ________   __       __
	   / ______  \  /_____  \  / / / / / _____  | / /      / /
	  / /      | / _______| / / / / / / /____/ / / /      / /
	 / /      / / / _____  / / / / / / _______/ / /      / /
	/ /      / / / /____/ / / / / / / |______  / |______/ /
   /_/      /_/ |________/ / / / /  \_______/  \_______  /
                          /_/ /_/                     / /
			                                         / /
		       High Level Game Framework            /_/

  ---------------------------------------------------------------

  Copyright (c) 2007-2011 - Rodrigo Braz Monteiro.
  This file is subject to the terms of halley_license.txt.

\*****************************************************************/

#ifdef __APPLE__
#include <TargetConditionals.h>
#if TARGET_OS_IPHONE

#include "os_ios.h"
#include <stdlib.h>
#include <stdio.h>    
#include <pwd.h>
#include <unistd.h>

using namespace Halley;

Halley::OSiOS::OSiOS()
{
}

Halley::String Halley::OSiOS::getUserDataDir()
{
	return "";
}

Halley::String Halley::OSiOS::makeDataPath(String, String)
{
	return "";
}

#endif
#endif
