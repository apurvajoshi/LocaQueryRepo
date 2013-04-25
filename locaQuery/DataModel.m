
#import "DataModel.h"
#import "Message.h"

// We store our settings in the NSUserDefaults dictionary using these keys
static NSString* const NicknameKey = @"Nickname";
static NSString* const SecretCodeKey = @"SecretCode";
static NSString* const JoinedChatKey = @"JoinedChat";
static NSString* const DeviceTokenKey = @"DeviceToken";
static NSString* const Udid = @"Udid";
static NSString* const Fbid = @"Fbid";

@implementation DataModel
@synthesize messages;

+ (void)initialize
{
	if (self == [DataModel class])
	{
		// Register default values for our settings
		[[NSUserDefaults standardUserDefaults] registerDefaults:
			[NSDictionary dictionaryWithObjectsAndKeys:
				@"", NicknameKey,
				@"", SecretCodeKey,
				[NSNumber numberWithInt:0], JoinedChatKey, @"0", DeviceTokenKey, nil]];
	}
}

// Returns the path to the Messages.plist file in the app's Documents directory
- (NSString*)messagesPath
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"Messages.plist"];
}

- (void)loadMessages
{
	NSString* path = [self messagesPath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		// We store the messages in a plist file inside the app's Documents
		// directory. The Message object conforms to the NSCoding protocol,
		// which means that it can "freeze" itself into a data structure that
		// can be saved into a plist file. So can the NSMutableArray that holds
		// these Message objects. When we load the plist back in, the array and
		// its Messages "unfreeze" and are restored to their old state.

		NSData* data = [[NSData alloc] initWithContentsOfFile:path];
		NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		NSMutableArray *msgsLoaded = [unarchiver decodeObjectForKey:@"Messages"];
        for (Message *m in msgsLoaded) {
            NSMutableArray *msgs = [messages objectForKey:m.threadId];
            if (msgs == nil) {
                NSMutableArray *newmsgs = [NSMutableArray arrayWithCapacity:20];
                [messages setObject:newmsgs forKey:m.threadId];
            }
            [[messages objectForKey:m.threadId] addObject:m];
        }
		[unarchiver finishDecoding];
	}
	else
	{
		self.messages = [[NSMutableDictionary alloc] init];
	}
}

- (void)saveMessages
{
	NSMutableData* data = [[NSMutableData alloc] init];
	NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    NSMutableArray *msgsToSave = [[NSMutableArray alloc] init];
    for(NSMutableArray* msgs in messages) {
        for(Message *m in msgs)
            [msgsToSave addObject:m];
    }
	//[archiver encodeObject:self.messages forKey:@"Messages"];
    [archiver encodeObject:msgsToSave forKey:@"Messages"];
	[archiver finishEncoding];
	[data writeToFile:[self messagesPath] atomically:YES];
}

- (int)addMessage:(Message*)message
{
	//[self.messages addObject:message];
	//[self saveMessages];
	//return self.messages.count - 1;
    
    NSMutableArray *msgs = [messages objectForKey:message.threadId];
    if (msgs == nil) {
        NSMutableArray *newmsgs = [[NSMutableArray alloc] init];
        [messages setObject:newmsgs forKey:message.threadId];
    }
    [[messages objectForKey:message.threadId] addObject:message];
    return msgs.count;
    
}

- (NSString*)nickname
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:NicknameKey];
}

- (void)setNickname:(NSString*)name
{
	[[NSUserDefaults standardUserDefaults] setObject:name forKey:NicknameKey];
}

- (NSString*)secretCode
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:SecretCodeKey];
}

- (void)setSecretCode:(NSString*)string
{
	[[NSUserDefaults standardUserDefaults] setObject:string forKey:SecretCodeKey];
}

- (BOOL)joinedChat
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:JoinedChatKey];
}

- (void)setJoinedChat:(BOOL)value
{
	[[NSUserDefaults standardUserDefaults] setBool:value forKey:JoinedChatKey];
}

- (NSString*)fbid
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:Fbid];
}

- (void)setFbid:(NSString*)string
{
	[[NSUserDefaults standardUserDefaults] setObject:string forKey:Fbid];
}

- (NSString*)udid
{
	UIDevice* device = [UIDevice currentDevice];
	return [device.uniqueIdentifier stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

- (NSString*)deviceToken
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:DeviceTokenKey];
}

- (void)setDeviceToken:(NSString*)token
{
	[[NSUserDefaults standardUserDefaults] setObject:token forKey:DeviceTokenKey];
}


- (void)dealloc
{

}

@end
