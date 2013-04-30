//
//  QuestionCell.h
//  LocaQuery
//
//  Created by Elli Fragkaki on 4/10/13.
//  Copyright (c) 2013 Elli Fragkaki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface QuestionCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *senderImage;

@end
