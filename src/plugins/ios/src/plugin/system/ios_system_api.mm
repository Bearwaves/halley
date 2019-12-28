#include "ios_system_api.h"
#include "ios_save_data.h"
#include "ios_asset_reader.h"
#include "ios_window.h"
#include <Foundation/Foundation.h>

using namespace Halley;

void IOSSystemAPI::init()
{
}

void IOSSystemAPI::deInit()
{
}

Path IOSSystemAPI::getAssetsPath(const Path& gamePath) const
{
	return [[[NSBundle mainBundle] resourcePath] cStringUsingEncoding:NSUTF8StringEncoding];
}

Path IOSSystemAPI::getUnpackedAssetsPath(const Path& gamePath) const
{
	return [[[NSBundle mainBundle] resourcePath] cStringUsingEncoding:NSUTF8StringEncoding];
}

std::unique_ptr<ResourceDataReader> IOSSystemAPI::getDataReader(String path, int64_t start, int64_t end)
{
	return std::make_unique<IOSAssetReader>(path);
}

std::unique_ptr<GLContext> IOSSystemAPI::createGLContext()
{
	return {};
}

std::shared_ptr<Window> IOSSystemAPI::createWindow(const WindowDefinition& window)
{
	return std::make_shared<IOSWindow>(window, [[UIApplication sharedApplication] keyWindow]);
}

void IOSSystemAPI::destroyWindow(std::shared_ptr<Window> window)
{
}

Vector2i IOSSystemAPI::getScreenSize(int n) const
{
	CGRect screenRect = [[UIScreen mainScreen] nativeBounds];
	return Vector2i(screenRect.size.width, screenRect.size.height);
}

Rect4i IOSSystemAPI::getDisplayRect(int screen) const
{
	return Rect4i(Vector2i(), getScreenSize(screen));
}

void IOSSystemAPI::showCursor(bool show)
{
}

bool IOSSystemAPI::generateEvents(VideoAPI* video, InputAPI* input)
{
	return true;
}

std::shared_ptr<ISaveData> IOSSystemAPI::getStorageContainer(SaveDataType type, const String& containerName)
{
	return std::make_shared<IOSSaveData>();
}
