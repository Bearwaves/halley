#include "ios_input.h"

using namespace Halley;

static IOSInputAPI* input = nullptr;

IOSInputAPI::IOSInputAPI()
{
	input = this;
}

IOSInputAPI::~IOSInputAPI()
{
	input = nullptr;
}

IOSInputAPI* IOSInputAPI::get()
{
	return input;
}

void IOSInputAPI::init()
{
}

void IOSInputAPI::deInit()
{
}

void IOSInputAPI::beginEvents(Time t)
{
    //mouse->onButtonStatus(0, false);
    //mouse->onButtonStatus(1, false);
    //mouse->onButtonStatus(2, holdingRight);
}

size_t IOSInputAPI::getNumberOfKeyboards() const
{
    return 0;
}

std::shared_ptr<InputKeyboard> IOSInputAPI::getKeyboard(int id) const
{
    return std::shared_ptr<InputKeyboard>();
}

size_t IOSInputAPI::getNumberOfJoysticks() const
{
    return 0;
}

std::shared_ptr<InputJoystick> IOSInputAPI::getJoystick(int id) const
{
    return std::shared_ptr<InputJoystick>();
}

size_t IOSInputAPI::getNumberOfMice() const
{
    return 1;
}

std::shared_ptr<InputDevice> IOSInputAPI::getMouse(int id) const
{
	return {};
}

std::vector<std::shared_ptr<InputTouch>> IOSInputAPI::getNewTouchEvents()
{
    // TODO
    return {};
}

std::vector<std::shared_ptr<InputTouch>> IOSInputAPI::getTouchEvents()
{
    // TODO
    return {};
}

void IOSInputAPI::setMouseRemapping(std::function<Vector2f(Vector2i)> remapFunction)
{
    //mouseRemap = remapFunction;
}

void IOSInputAPI::onTouchEvent(UITouch* touch)
{
	std::cout << touch.tapCount << std::endl;
	std::cout << touch.type << std::endl;
	std::cout << touch.majorRadius << std::endl;
	std::cout << touch.phase << std::endl;
	auto loc = [touch locationInView:touch.view];
	std::cout << "(" << loc.x << ", " << loc.y << ")" << std::endl;

}
