
#import "Message.h"

static NSString* const SenderNameKey = @"SenderName";
static NSString* const DateKey = @"Date";
static NSString* const TextKey = @"Text";
static NSString* const ThreadIdKey = @"Thread";

@implementation Message

@synthesize senderName, date, text, bubbleSize, threadId;

- (id)initWithCoder:(NSCoder*)decoder
{
	if ((self = [super init]))
	{
		self.senderName = [decoder decodeObjectForKey:SenderNameKey];
		self.date = [decoder decodeObjectForKey:DateKey];
		self.text = [decoder decodeObjectForKey:TextKey];
        self.threadId = [decoder decodeObjectForKey:ThreadIdKey];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:self.senderName forKey:SenderNameKey];
	[encoder encodeObject:self.date forKey:DateKey];
	[encoder encodeObject:self.text forKey:TextKey];
    [encoder encodeObject:self.threadId forKey:ThreadIdKey];
}

- (BOOL)isSentByUser
{
	return self.senderName == nil;
}

- (void)dealloc
{
	
}

@end
