#include "avf_audio.h"

using namespace Halley;

AVFAudioDevice::AVFAudioDevice(String name)
	: name(name)
{
}

String AVFAudioDevice::getName() const
{
	return name != "" ? name : "Default";
}


void AVFAudioAPI::init()
{
	engine = [[AVAudioEngine alloc] init];
	[engine retain];
}

void AVFAudioAPI::deInit()
{
	closeAudioDevice();
	[engine release];
}

Vector<std::unique_ptr<const AudioDevice>> AVFAudioAPI::getAudioDevices()
{
	Vector<std::unique_ptr<const AudioDevice>> result;
	result.emplace_back(std::make_unique<AVFAudioDevice>("Default"));
	return result;
}

AudioSpec AVFAudioAPI::openAudioDevice(const AudioSpec& requestedFormat, const AudioDevice* dev, AudioCallback callback)
{
	prepareAudioCallback = callback;

	if (requestedFormat.format == AudioSampleFormat::Undefined) {
		throw Exception("Invalid audio format", HalleyExceptions::AudioOutPlugin);
	}

	open_device_format = [[AVAudioFormat alloc] initWithCommonFormat:getNativeAudioFormat(requestedFormat.format)
			sampleRate:requestedFormat.sampleRate
			channels:requestedFormat.numChannels
			interleaved:NO];
	[open_device_format retain];

	AudioSpec actualFormat;
	actualFormat.bufferSize = requestedFormat.bufferSize;
	actualFormat.format = requestedFormat.format;
	actualFormat.numChannels = requestedFormat.numChannels;
	actualFormat.sampleRate = 44100;

	buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:open_device_format
			frameCapacity:requestedFormat.bufferSize];
	[buffer retain];

	AVAudioMixerNode* mixer = [engine mainMixerNode];
	open_device_player = [[AVAudioPlayerNode alloc] init];
	[open_device_player retain];
	[engine attachNode:open_device_player];
	[engine connect:open_device_player to:mixer format:buffer.format];

	output_format = actualFormat;
	return actualFormat;
}

void AVFAudioAPI::closeAudioDevice()
{
	[engine detachNode:open_device_player];
	[open_device_player release];
	[open_device_format release];
	[buffer release];
}

void AVFAudioAPI::startPlayback()
{
	if (!engine) {
		throw Exception("Audio not initialised.", HalleyExceptions::AudioOutPlugin);
	}
	if (!playing) {
		NSError* error = NULL;
		if (![engine startAndReturnError:&error]) {
			throw Exception([[error localizedDescription] UTF8String], HalleyExceptions::AudioOutPlugin);
		}
	}
	playing = true;
	onCallback();
}

void AVFAudioAPI::stopPlayback()
{
	if (engine && playing) {
		[engine stop];
		playing = false;
	}
}

void AVFAudioAPI::onCallback()
{
	Expects(engine);

	std::cout << "out" <<std::endl;
	const auto dst = gsl::span<std::byte>(reinterpret_cast<std::byte*>(*buffer.floatChannelData), buffer.frameCapacity * 8);
	const auto written = getAudioOutputInterface().output(dst, false);
	std::cout << "written: " << written << "cap: " << buffer.frameCapacity << std::endl;
	buffer.frameLength = written / 8;
	[open_device_player scheduleBuffer:buffer completionHandler:^{onCallback();}];
	[open_device_player play];
}

bool AVFAudioAPI::needsAudioThread() const
{
	return false;
}

bool AVFAudioAPI::needsMoreAudio()
{
	std::cout << "needs" << std::endl;
	return getAudioOutputInterface().getAvailable() < getAudioBytesNeeded(output_format, 2);
}

bool AVFAudioAPI::needsInterleavedSamples() const
{
	return false;
}

void AVFAudioAPI::onAudioAvailable()
{
	std::cout << "avail" <<std::endl;
}

AVAudioCommonFormat AVFAudioAPI::getNativeAudioFormat(AudioSampleFormat format)
{
	switch (format) {
		case AudioSampleFormat::Int16:
			return AVAudioPCMFormatInt16;
		case AudioSampleFormat::Int32:
			return AVAudioPCMFormatInt32;
		default:
			return AVAudioPCMFormatFloat32;
	}
}
