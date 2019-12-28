#include "ios_window.h"

using namespace Halley;

IOSWindow::IOSWindow(const WindowDefinition& definition, UIWindow* native_window)
	: definition(definition.withSize(
		Vector2i(native_window.screen.nativeBounds.size.width, native_window.screen.nativeBounds.size.height)))
	, native_window(native_window)
{
	auto bounds = native_window.screen.nativeBounds;
	if (UIInterfaceOrientationIsLandscape(native_window.windowScene.interfaceOrientation)) {
		this->definition = definition.withSize(Vector2i(bounds.size.height, bounds.size.width));
	} else {
		this->definition = definition.withSize(Vector2i(bounds.size.width, bounds.size.height));
	}
}

void IOSWindow::update(const WindowDefinition& definition)
{

}

void IOSWindow::show()
{

}

void IOSWindow::hide()
{

}

void IOSWindow::setVsync(bool vsync)
{

}

void IOSWindow::swap()
{

}

Rect4i IOSWindow::getWindowRect() const
{
	return Rect4i(Vector2i(), definition.getSize());
}

const WindowDefinition& IOSWindow::getDefinition() const
{
	return definition;
}

void* IOSWindow::getNativeHandle()
{
	return native_window;
}

String IOSWindow::getNativeHandleType()
{
	return "iOS";
}
