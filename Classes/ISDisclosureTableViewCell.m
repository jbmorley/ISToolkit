//
//  ISDisclosureTableViewCell.m
//  Pods
//
//  Created by Jason Barrie Morley on 01/03/2014.
//
//

#import "ISDisclosureTableViewCell.h"

@interface ISDisclosureTableViewCell ()

@property (nonatomic, strong) NSString *viewController;

@end

@implementation ISDisclosureTableViewCell


- (id)init
{
  self = [super initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:nil];
  if (self) {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  return self;
}


#pragma mark - ISSettingsViewControllerItem


- (void)configure:(NSDictionary *)configuration
{
  self.textLabel.text = configuration[Title];
  self.viewController = configuration[ViewController];
}


- (void)didSelectItem
{
  Class class = NSClassFromString(self.viewController);
  UIViewController *viewController = [class new];
  [self.settingsDelegate item:self
           pushViewController:viewController];
}


@end
