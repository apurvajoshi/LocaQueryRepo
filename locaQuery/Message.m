
#import "Message.h"

static NSString* const SenderNameKey = @"SenderName";
static NSString* const DateKey = @"Date";
static NSString* const TextKey = @"Text";
static NSString* const ThreadIdKey = @"Thread";
static NSString* const SenderFbidIdKey = @"SenderFbid";

@implementation Message

@synthesize senderName, date, text, bubbleSize, threadId, senderFbid;

- (id)initWithCoder:(NSCoder*)decoder
{
	if ((self = [super init]))
	{
		self.senderName = [decoder decodeObjectForKey:SenderNameKey];
		self.date = [decoder decodeObjectForKey:DateKey];
		self.text = [decoder decodeObjectForKey:TextKey];
        self.threadId = [decoder decodeObjectForKey:ThreadIdKey];
        self.senderFbid = [decoder decodeObjectForKey:SenderFbidIdKey];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:self.senderName forKey:SenderNameKey];
	[encoder encodeObject:self.date forKey:DateKey];
	[encoder encodeObject:self.text forKey:TextKey];
    [encoder encodeObject:self.threadId forKey:ThreadIdKey];
    [encoder encodeObject:self.senderFbid forKey:SenderFbidIdKey];
}

- (BOOL)isSentByUser
{
	return self.senderName == nil;
}

- (void)dealloc
{
	
}

@end
