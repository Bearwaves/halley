project (halley-avf)

include_directories(${BOOST_INCLUDE_DIR} "../../engine/utils/include" "../../engine/core/include" "../../engine/audio/include")

set(SOURCES
	"src/avf_plugin.cpp"
	"src/avf_movie_api.mm"
	"src/avf_movie_player.mm"
	"src/avf_audio.mm"
	)

set(HEADERS
	"src/avf_movie_api.h"
	"src/avf_movie_player.h"
	"src/avf_audio.h"
	)

assign_source_group(${SOURCES})
assign_source_group(${HEADERS})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -x objective-c++")

add_library (halley-avf ${SOURCES} ${HEADERS})
target_link_libraries(halley-avf
	halley-core
	halley-audio
	"-framework AVFoundation"
	"-framework CoreMedia"
)
