#import "ViewController.h"
#import "MetalView.h"
#include "IOSSystem.h"

@implementation ViewController
{
	CADisplayLink* displayLink;
	std::unique_ptr<Halley::IOSSystem> system;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	system = std::make_unique<Halley::IOSSystem>();
	displayLink = [[CADisplayLink displayLinkWithTarget: self selector: @selector(render)] retain];
	[displayLink setPaused:YES];
	[displayLink addToRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
}

- (void)loadView
{
	[super loadView];
	self.view = [[MetalView alloc] initWithFrame:self.view.bounds];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (void) render
{
	system->run();
}

- (void) viewDidAppear:(BOOL)animated
{
	system->handleAppear();
	[displayLink setPaused:NO];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[displayLink setPaused:YES];
}

@end
