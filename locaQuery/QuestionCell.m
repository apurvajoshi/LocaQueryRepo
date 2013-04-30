//
//  QuestionCell.m
//  LocaQuery
//
//  Created by Elli Fragkaki on 4/10/13.
//  Copyright (c) 2013 Elli Fragkaki. All rights reserved.
//

#import "QuestionCell.h"

@implementation QuestionCell

@synthesize nameLabel = _nameLabel;
@synthesize timeLabel = _timeLabel;
@synthesize senderImage = _senderImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
