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
			sampleRate:44100
			channels:requestedFormat.numChannels
			interleaved:NO];
	[open_device_format retain];
	
	AudioSpec actualFormat;
	actualFormat.bufferSize = requestedFormat.bufferSize;
	actualFormat.format = requestedFormat.format;
	actualFormat.numChannels = requestedFormat.numChannels;
	actualFormat.sampleRate = 44100;

	buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:open_device_format
			frameCapacity:1024];
	[buffer retain];

	AVAudioMixerNode* mixer = [engine mainMixerNode];
	open_device_player = [[AVAudioPlayerNode alloc] init];
	[open_device_player retain];
	[engine attachNode:open_device_player];
	[engine connect:open_device_player to:mixer format:buffer.format];

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

void AVFAudioAPI::queueAudio(gsl::span<const float> data)
{
	Expects(engine);
	
	doQueueAudio(gsl::as_bytes(data));
}

void AVFAudioAPI::doQueueAudio(gsl::span<const gsl::byte> data)
{
	std::vector<unsigned char> tmp(data.size_bytes());
	memcpy(tmp.data(), data.data(), data.size_bytes());

	std::unique_lock<std::mutex> lock(mutex);
	audioQueue.push_back(std::move(tmp));
}

void AVFAudioAPI::onCallback()
{
	Expects(engine);
	std::unique_lock<std::mutex> lock(mutex);
	
	if (audioQueue.empty()) {
		lock.unlock();
		if (callback) {
			callback();
		}
		if (!audioQueue.empty()) {
			onCallback();
		}
	} else {
		auto& front = audioQueue.front();
		memcpy(buffer.floatChannelData[1], front.data(), front.size()/2);
		//memcpy(buffer.floatChannelData[1], front.data() + front.size()/2, front.size()/2);
		buffer.frameLength = front.size() / 8;
		[open_device_player scheduleBuffer:buffer completionHandler:^{onCallback();}];
		audioQueue.pop_front();
		[open_device_player play];
	}
}

bool AVFAudioAPI::needsMoreAudio()
{
	return false;
}

bool AVFAudioAPI::needsInterleavedSamples() const
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
