#include <halley/plugin/plugin.h>
#include "system/ios_system_api.h"
#include "input/ios_input.h"

namespace Halley {

	class IOSSystemPlugin : public Plugin {
		HalleyAPIInternal* createAPI(SystemAPI* system) override { return new IOSSystemAPI(); }
		PluginType getType() override { return PluginType::SystemAPI; }
		String getName() override { return "System/iOS"; }
		int getPriority() const override { return 1; }
	};

	class IOSInputPlugin : public Plugin {
		HalleyAPIInternal* createAPI(SystemAPI* system) override { return new IOSInputAPI(); }
		PluginType getType() override { return PluginType::InputAPI; }
		String getName() override { return "Input/iOS"; }
		int getPriority() const override { return 1; }
	};

}

void initIOSSystemPlugin(Halley::IPluginRegistry& registry)
{
	registry.registerPlugin(std::make_unique<Halley::IOSSystemPlugin>());
	registry.registerPlugin(std::make_unique<Halley::IOSInputPlugin>());
}
