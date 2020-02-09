#include "avf_movie_api.h"
#include "avf_audio.h"
#include <halley/plugin/plugin.h>

namespace Halley {

	class AVFPlugin : public Plugin {
		HalleyAPIInternal* createAPI(SystemAPI* system) override { return new AVFMovieAPI(*system); }
		PluginType getType() override { return PluginType::MovieAPI; }
		String getName() override { return "Movie/AVFoundation"; }
		int getPriority() const override { return 1; }
	};

	class AVFAudioPlugin : public Plugin {
		HalleyAPIInternal* createAPI(SystemAPI* system) override { return new AVFAudioAPI(); }
		PluginType getType() override { return PluginType::AudioOutputAPI; }
		String getName() override { return "Audio/AVFoundation"; }
		int getPriority() const override { return 1; }
	};

}

void initAVFPlugin(Halley::IPluginRegistry& registry)
{
	registry.registerPlugin(std::make_unique<Halley::AVFPlugin>());
}

void initAVFAudioPlugin(Halley::IPluginRegistry& registry)
{
	registry.registerPlugin(std::make_unique<Halley::AVFAudioPlugin>());
}
