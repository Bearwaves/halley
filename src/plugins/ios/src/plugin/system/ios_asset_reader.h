#pragma once

#include "halley/resources/resource_data.h"
#include <Foundation/Foundation.h>

namespace Halley {
	class IOSAssetReader : public ResourceDataReader {
	public:
		IOSAssetReader(String path);
		~IOSAssetReader();

		size_t size() const override;
		int read(gsl::span<gsl::byte> dst) override;
		void seek(int64_t pos, int whence) override;
		size_t tell() const override;
		void close() override;

	private:
		NSFileHandle* handle;
	};
}
