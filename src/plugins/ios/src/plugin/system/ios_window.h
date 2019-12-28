#pragma once

#include <halley/core/graphics/window.h>
#include <halley/maths/rect.h>
#include <UIKit/UIKit.h>

namespace Halley {
	class IOSWindow : public Window {
	public:
		IOSWindow(const WindowDefinition& definition, UIWindow* native_window);

		void update(const WindowDefinition& definition) override;
		void show() override;
		void hide() override;
		void setVsync(bool vsync) override;
		void swap() override;
		Rect4i getWindowRect() const override;
		const WindowDefinition& getDefinition() const override;

		void* getNativeHandle() override;
		String getNativeHandleType() override;

	private:
		WindowDefinition definition;
		UIWindow* native_window;
	};
}
