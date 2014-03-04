//
//  ISDetailTableViewCell.m
//  Updater
//
//  Created by Jason Barrie Morley on 26/02/2014.
//  Copyright (c) 2014 InSeven Limited. All rights reserved.
//

#import "ISDetailTableViewCell.h"
#import "ISForm.h"

@implementation ISDetailTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
  if (self) {
  }
  return self;
}


#pragma mark - ISSettingsViewCOntrollerItem


- (void)configure:(NSDictionary *)configuration
{
  self.textLabel.text = configuration[ISFormTitle];
  self.detailTextLabel.text = configuration[ISFormDetailText];
}


@end
