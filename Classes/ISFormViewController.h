//
//  ISFormViewController.h
//  Pods
//
//  Created by Jason Barrie Morley on 01/03/2014.
//
//

#import <UIKit/UIKit.h>
#import "ISSettingsViewControllerItem.h"

@class ISFormViewController;

@protocol ISFormViewControllerDataSource <NSObject>

- (id)formViewController:(ISFormViewController *)formViewController valueForProperty:(NSString *)property;
- (void)formViewController:(ISFormViewController *)formViewController setValue:(id)value forProperty:(NSString *)property;

@end

@protocol ISFormViewControllerDelegate <NSObject>

- (void)formViewController:(ISFormViewController *)formViewController didPerformActionForKey:(NSString *)key;

@end

@interface ISFormViewController : UITableViewController
<ISSettingsViewControllerItemDelegate
,ISFormViewControllerDataSource
,ISFormViewControllerDelegate>

@property (nonatomic, weak) id<ISFormViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<ISFormViewControllerDelegate> delegate;

- (id)initWithArray:(NSArray *)array;
- (void)registerClass:(Class)class
              forType:(NSString *)type;

@end
