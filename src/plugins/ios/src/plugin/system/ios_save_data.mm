#include "ios_save_data.h"

using namespace Halley;

bool IOSSaveData::isReady() const
{
	return true;
}

Bytes IOSSaveData::getData(const String& path)
{
	return {};
}

std::vector<String> IOSSaveData::enumerate(const String& root)
{
	return {};
}

void IOSSaveData::setData(const String& path, const Bytes& data, bool commit)
{
}

void IOSSaveData::commit()
{
}
