//
//  ISDisclosureTableViewCell.h
//  Pods
//
//  Created by Jason Barrie Morley on 01/03/2014.
//
//

#import <UIKit/UIKit.h>
#import "ISSettingsViewControllerItem.h"

@interface ISDisclosureTableViewCell : UITableViewCell
<ISSettingsViewControllerItem>

@property (nonatomic, weak) id<ISSettingsViewControllerItemDelegate> settingsDelegate;

@end
