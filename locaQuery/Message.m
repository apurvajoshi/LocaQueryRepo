
#import "Message.h"

static NSString* const SenderNameKey = @"SenderName";
static NSString* const DateKey = @"Date";
static NSString* const TextKey = @"Text";

@implementation Message

@synthesize senderName, date, text, bubbleSize;

- (id)initWithCoder:(NSCoder*)decoder
{
	if ((self = [super init]))
	{
		self.senderName = [decoder decodeObjectForKey:SenderNameKey];
		self.date = [decoder decodeObjectForKey:DateKey];
		self.text = [decoder decodeObjectForKey:TextKey];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:self.senderName forKey:SenderNameKey];
	[encoder encodeObject:self.date forKey:DateKey];
	[encoder encodeObject:self.text forKey:TextKey];
}

- (BOOL)isSentByUser
{
	return self.senderName == nil;
}

- (void)dealloc
{
	
}

@end
