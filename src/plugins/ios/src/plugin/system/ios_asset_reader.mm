#include "ios_asset_reader.h"

using namespace Halley;

IOSAssetReader::IOSAssetReader(String path)
{
	handle = [[NSFileHandle fileHandleForReadingAtPath:[NSString stringWithUTF8String:path.c_str()]] retain];
}

IOSAssetReader::~IOSAssetReader()
{
	close();
}

size_t IOSAssetReader::size() const
{
	size_t startPos = [handle offsetInFile];
	[handle seekToEndOfFile];
	size_t size = [handle offsetInFile];
	[handle seekToFileOffset:startPos];
	return size;
}

int IOSAssetReader::read(gsl::span<gsl::byte> dst)
{
	NSData* buffer = [handle readDataOfLength:dst.length()];
	[buffer getBytes:dst.data() length:buffer.length];
	return (int) buffer.length;
}

void IOSAssetReader::seek(int64_t pos, int whence)
{
	[handle seekToFileOffset:(pos + whence)];
}

size_t IOSAssetReader::tell() const
{
	return [handle offsetInFile];
}

void IOSAssetReader::close()
{
	[handle closeFile];
	[handle release];
}
