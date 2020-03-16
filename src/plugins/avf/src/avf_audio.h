#pragma once
#include "halley/core/api/halley_api_internal.h"
#include <vector>
#include <AVFoundation/AVFoundation.h>

namespace Halley {
	class AVFAudioDevice final : public AudioDevice
	{
	public:
		AVFAudioDevice(String name);
		String getName() const override;

	private:
		String name;
	};

	class AVFAudioAPI final : public AudioOutputAPIInternal
	{
	public:
		void init() override;
		void deInit() override;

		Vector<std::unique_ptr<const AudioDevice>> getAudioDevices() override;
		AudioSpec openAudioDevice(const AudioSpec& requestedFormat, const AudioDevice* device, AudioCallback callback) override;
		void closeAudioDevice() override;

		void startPlayback() override;
		void stopPlayback() override;

		void queueAudio(gsl::span<const float> data) override;
		bool needsMoreAudio() override;

		bool needsAudioThread() const override;
		bool needsInterleavedSamples() const override;

	private:
		AVAudioCommonFormat getNativeAudioFormat(AudioSampleFormat format);

		AudioCallback callback;
		AVAudioEngine* engine;
		AVAudioPlayerNode* open_device_player;
		AVAudioFormat* open_device_format;
		AVAudioPCMBuffer* buffer;
		bool playing;
		
		std::mutex mutex;
		std::list<std::vector<unsigned char>> audioQueue;
		int remaining;

		void doQueueAudio(gsl::span<const gsl::byte> data);
		void onCallback();
	};
}
