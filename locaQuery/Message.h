
// Data model object that stores a single message
@interface Message : NSObject <NSCoding>
{
}

// The sender of the message. If nil, the message was sent by the user.
@property (nonatomic, copy) NSString* senderName;

@property (nonatomic, copy) NSString* senderFbid;

// When the message was sent
@property (nonatomic, copy) NSDate* date;

// The text of the message
@property (nonatomic, copy) NSString* text;

// The thread id the message belongs to
@property (nonatomic, copy) NSString* threadId;

// This doesn't really belong in the data model, but we use it to cache the
// size of the speech bubble for this message.
@property (nonatomic, assign) CGSize bubbleSize;

// Determines whether this message as sent by the user of the app. We will
// display such messages on the right-hand side of the screen.
- (BOOL)isSentByUser;

@end
