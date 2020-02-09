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

bool AVFAudioAPI::needsAudioThread() const
{
	return false;
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
	this->callback = callback;

	if (requestedFormat.format == AudioSampleFormat::Undefined) {
		throw Exception("Invalid audio format", HalleyExceptions::AudioOutPlugin);
	}

	open_device_format = [[AVAudioFormat alloc] initWithCommonFormat:getNativeAudioFormat(requestedFormat.format)
			sampleRate:requestedFormat.sampleRate
			channels:requestedFormat.numChannels
			interleaved:NO];
	[open_device_format retain];

	buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:open_device_format
			frameCapacity:requestedFormat.bufferSize];
	[buffer retain];

	AVAudioMixerNode* mixer = [engine mainMixerNode];
	open_device_player = [[AVAudioPlayerNode alloc] init];
	[open_device_player retain];
	[engine attachNode:open_device_player];
	[engine connect:open_device_player to:mixer format:buffer.format];

	return requestedFormat;
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
	callback();
}

void AVFAudioAPI::stopPlayback()
{
	if (engine && playing) {
		[engine stop];
		playing = false;
	}
}

void AVFAudioAPI::queueAudio(gsl::span<const float> data)
{
	char* toCopy = (char*) *buffer.floatChannelData;
	if (open_device_format.commonFormat == AVAudioPCMFormatInt16) {
		toCopy = (char*) buffer.int16ChannelData;
	} else if (open_device_format.commonFormat == AVAudioPCMFormatInt32) {
		toCopy = (char*) buffer.int32ChannelData;
	}

	auto bytes = gsl::as_bytes(data);

	memcpy(toCopy, bytes.data(), bytes.size_bytes()/2);
	buffer.frameLength = (bytes.size_bytes() / 8);

	[open_device_player scheduleBuffer:buffer completionHandler:^{callback();}];
	[open_device_player play];
}

bool AVFAudioAPI::needsMoreAudio()
{
	return false;
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
