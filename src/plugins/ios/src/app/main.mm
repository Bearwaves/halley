#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include <exception>

int main(int argc, char * argv[]) {
	NSString * appDelegateClassName;
	@autoreleasepool {
		try {
			appDelegateClassName = NSStringFromClass([AppDelegate class]);
			return UIApplicationMain(argc, argv, nil, appDelegateClassName);
		} catch (std::exception& e) {
			NSLog(@"Got exception: %s", e.what());
		}
	}
}
