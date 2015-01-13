//
//  CustomCell.h
//  GenericMail
//
//  Created by Eric Lam on 4/22/14.
//  Copyright (c) 2014 Eric Lam. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Class that simply acts as a container that defines the content view of the UITableViewCell */
@interface CustomCell : UITableViewCell

/** The title of the custom cell */
@property (strong, nonatomic) IBOutlet UILabel *Title;

/** The subtitle of the custom cell */
@property (strong, nonatomic) IBOutlet UILabel *SubTitle;

@end
