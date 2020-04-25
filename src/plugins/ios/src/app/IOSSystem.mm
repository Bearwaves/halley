#include "IOSSystem.h"
#include <halley/core/entry/game_loader.h>
#include <halley/core/entry/entry_point.h>
#include <string>

using namespace Halley;

IHalleyEntryPoint* getHalleyEntry();

static IOSSystem* sys = nullptr;

IOSSystem::IOSSystem()
{
	sys = this;

	auto entry = getHalleyEntry();
	std::vector<std::string> args = { "halleygame" };
	core = entry->createCore(args);
	input = IOSInputAPI::get();
	did_setup = false;
}

IOSSystem::~IOSSystem()
{
	sys = nullptr;
}

IOSSystem& IOSSystem::get()
{
	return *sys;
}

void IOSSystem::run()
{
	try {
		core->transitionStage();
		constexpr Time fixedDelta = 1.0 / 60.0;
		core->onVariableUpdate(fixedDelta);
		core->onFixedUpdate(fixedDelta);
	} catch (std::exception& e) {
		if (core) {
				core->onTerminatedInError(e.what());
		} else {
				NSLog(@"Exception initialising core: %s", e.what());
		}
	} catch(...) {
		if (core) {
				core->onTerminatedInError("");
		} else {
				NSLog(@"Unknown exception initialising core.");
		}
	}
}

void IOSSystem::handleAppear()
{
	if (!did_setup) {
		did_setup = true;
		core->init();
	}
}

void IOSSystem::handleTouch(UITouch* touch)
{
	if (input) {
		input->onTouchEvent(touch);
	}
}
