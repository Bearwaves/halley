#include "ios_audio.h"

using namespace Halley;

IOSAudioDevice::IOSAudioDevice(String name)
	: name(name)
{
}

String IOSAudioDevice::getName() const
{
	return name != "" ? name : "Default";
}


void IOSAudioAPI::init()
{
	engine = [[AVAudioEngine alloc] init];
}

bool IOSAudioAPI::needsAudioThread() const
{
	return true;
}

void IOSAudioAPI::deInit()
{
	closeAudioDevice();
	[engine release];
}

Vector<std::unique_ptr<const AudioDevice>> IOSAudioAPI::getAudioDevices()
{
	Vector<std::unique_ptr<const AudioDevice>> result;
	result.emplace_back(std::make_unique<IOSAudioDevice>("Default"));
	return result;
}

AudioSpec IOSAudioAPI::openAudioDevice(const AudioSpec& requestedFormat, const AudioDevice* dev, AudioCallback callback)
{
	if (requestedFormat.format == AudioSampleFormat::Undefined) {
		throw Exception("Invalid audio format", HalleyExceptions::AudioOutPlugin);
	}

	open_device_format = [[AVAudioFormat alloc] initWithCommonFormat:getNativeAudioFormat(requestedFormat.format)
			sampleRate:requestedFormat.sampleRate
			channels:requestedFormat.numChannels
			interleaved:NO];

	buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:open_device_format
			frameCapacity:requestedFormat.bufferSize];

	AVAudioMixerNode* mixer = [engine mainMixerNode];
	open_device_player = [[AVAudioPlayerNode alloc] init];
	[engine attachNode:open_device_player];
	[engine connect:open_device_player to:mixer format:buffer.format];

	return requestedFormat;
}

void IOSAudioAPI::closeAudioDevice()
{
	[engine detachNode:open_device_player];
	[open_device_player release];
	[open_device_format release];
	[buffer release];
}

void IOSAudioAPI::startPlayback()
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
}

void IOSAudioAPI::stopPlayback()
{
	if (engine && playing) {
		[engine pause];
		playing = false;
	}
}

void IOSAudioAPI::queueAudio(gsl::span<const float> data)
{
	char* toCopy = (char*) buffer.floatChannelData;
	if (open_device_format.commonFormat == AVAudioPCMFormatInt16) {
		toCopy = (char*) buffer.int16ChannelData;
	} else if (open_device_format.commonFormat == AVAudioPCMFormatInt32) {
		toCopy = (char*) buffer.int32ChannelData;
	}

	auto bytes = gsl::as_bytes(data);

	memcpy(toCopy, bytes.data(), bytes.size_bytes());

	[open_device_player scheduleBuffer:buffer completionHandler:^{callback();}];
}

bool IOSAudioAPI::needsMoreAudio()
{
	return false;
}

AVAudioCommonFormat IOSAudioAPI::getNativeAudioFormat(AudioSampleFormat format)
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
