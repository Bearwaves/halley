#import "MetalView.h"
#include "IOSSystem.h"

@implementation MetalView

+ (Class) layerClass
{
	return [CAMetalLayer class];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	Halley::IOSSystem::get().handleTouch([touches anyObject]);
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	Halley::IOSSystem::get().handleTouch([touches anyObject]);
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	Halley::IOSSystem::get().handleTouch([touches anyObject]);
}

@end
