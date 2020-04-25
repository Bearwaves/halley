#pragma once

#include "../plugin/input/ios_input.h"
#include <halley/core/game/main_loop.h>
#include <memory>
#include <UIKit/UIKit.h>

namespace Halley {
	class IOSSystem {
	public:
		IOSSystem();
		~IOSSystem();

		static IOSSystem& get();

		void run();
		void handleAppear();
		void setInputAPI(IOSInputAPI* inputAPI);
		void handleTouch(UITouch* touch);
	private:
		std::unique_ptr<IMainLoopable> core;
		bool did_setup;
		IOSInputAPI* input;
	};
}
