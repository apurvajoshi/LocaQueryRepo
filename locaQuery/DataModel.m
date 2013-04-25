
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
CLLocationManager *locationManager;
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
    
    locationManager = [[CLLocationManager alloc] init];
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
		self.messages = [unarchiver decodeObjectForKey:@"Messages"];
		[unarchiver finishDecoding];
	}
	else
	{
		self.messages = [NSMutableArray arrayWithCapacity:20];
	}
}

- (void)saveMessages
{
	NSMutableData* data = [[NSMutableData alloc] init];
	NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:self.messages forKey:@"Messages"];
	[archiver finishEncoding];
	[data writeToFile:[self messagesPath] atomically:YES];
}

- (int)addMessage:(Message*)message
{
	[self.messages addObject:message];
	[self saveMessages];
	return self.messages.count - 1;
}

- (NSString*)nickname
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:NicknameKey];
}

- (NSString*)getaLocation
{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
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
