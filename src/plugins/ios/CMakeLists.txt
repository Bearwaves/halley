project (halley-ios)

include_directories(${Boost_INCLUDE_DIR} "../../engine/utils/include" "../../engine/core/include")

set(SOURCES
				"src/plugin/ios_plugin.mm"
				"src/plugin/system/ios_system_api.mm"
				"src/plugin/system/ios_save_data.mm"
				"src/plugin/system/ios_asset_reader.mm"
				"src/plugin/system/ios_window.mm"
				"src/plugin/input/ios_input.mm"

				"src/app/main.mm"
				"src/app/AppDelegate.mm"
				"src/app/IOSSystem.mm"
				"src/app/ViewController.mm"
				"src/app/MetalView.mm"
				)

set(HEADERS
				"src/plugin/system/ios_system_api.h"
				"src/plugin/system/ios_save_data.h"
				"src/plugin/system/ios_asset_reader.h"
				"src/plugin/system/ios_window.h"
				"src/plugin/input/ios_input.h"

				"src/app/AppDelegate.h"
				"src/app/IOSSystem.h"
				"src/app/ViewController.h"
				"src/app/MetalView.h"
				)

assign_source_group(${SOURCES})
assign_source_group(${HEADERS})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -x objective-c++")

find_library(FOUNDATION_LIBRARY Foundation)
find_library(UIKIT_LIBRARY UIKit)
mark_as_advanced(FOUNDATION_LIBRARY UIKIT_LIBRARY)

file(GLOB LAUNCH_IMAGES ${IOS_LAUNCH_IMAGES}/*.png)

add_executable (halley-ios ${SOURCES} ${HEADERS} ${LAUNCH_IMAGES})
target_link_libraries(halley-ios ${FOUNDATION_LIBRARY} ${UIKIT_LIBRARY} ${name} halley-core)

set_target_properties(halley-ios PROPERTIES
											XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "${IOS_CODE_SIGN_IDENTITY}"
											XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "${IOS_DEVELOPMENT_TEAM}"
											XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "${IOS_BUNDLE_IDENTIFIER}"
											XCODE_ATTRIBUTE_MARKETING_VERSION "${IOS_VERSION}"
											XCODE_ATTRIBUTE_CURRENT_PROJECT_VERSION "${IOS_BUILD_NUMBER}"
											XCODE_ATTRIBUTE_PRODUCT_NAME "${IOS_NAME}"
											XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2"
											RESOURCE "${LAUNCH_IMAGES}"
)

add_custom_command(TARGET halley-ios POST_BUILD
	COMMAND "cp" "-R" "${HALLEY_PROJECT_SOURCE_DIR}/assets/" "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${IOS_NAME}.app/"
)
