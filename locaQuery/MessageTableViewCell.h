
@class Message;
@class SpeechBubbleView;

// Table view cell that displays a Message. The message text appears in a
// speech bubble; the sender name and date are shown in a UILabel below that.
@interface MessageTableViewCell : UITableViewCell
{
	SpeechBubbleView* bubbleView;
	UILabel* label;
}

- (void)setMessage:(Message*)message;

@end
