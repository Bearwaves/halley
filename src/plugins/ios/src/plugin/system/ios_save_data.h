#pragma once

#include "halley/core/api/save_data.h"

namespace Halley {
	class IOSSaveData : public ISaveData {
	public:
		bool isReady() const override;

		Bytes getData(const String &path) override;

		std::vector<String> enumerate(const String &root) override;

		void setData(const String &path, const Bytes &data, bool commit) override;

		void commit() override;
	};
}
