//
// Copyright (c) 2013 InSeven Limited.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import <UIKit/UIKit.h>
#import "ISSettingsViewControllerItem.h"
#import "ISPickerTableViewCell.h"

// Keys.
extern NSString *const ISFormType;
extern NSString *const ISFormTitle;
extern NSString *const ISFormDetailText;
extern NSString *const ISFormKey;
extern NSString *const ISFormValue;
extern NSString *const ISFormPlaceholderText;
extern NSString *const ISFormFooterText;
extern NSString *const ISFormItems;
extern NSString *const ISFormHeight;
extern NSString *const ISFormCondition;
extern NSString *const ISFormClass;
extern NSString *const ISFormMode;
extern NSString *const ISFormStyle;
extern NSString *const ISFormTimeSpecifier;

// Types.
extern NSString *const ISFormGroupSpecifier;
extern NSString *const ISFormTextFieldSpecifier;
extern NSString *const ISFormSwitchSpecifier;
extern NSString *const ISFormButtonSpecifier;
extern NSString *const ISFormTextViewSpecifier;
extern NSString *const ISFormDisclosureSpecifier;
extern NSString *const ISFormDetailSpecifier;
extern NSString *const ISFormPickerSpecifier;

@class ISFormViewController;

@protocol ISFormViewControllerDataSource <NSObject>

- (id)formViewController:(ISFormViewController *)formViewController valueForProperty:(NSString *)property;
- (void)formViewController:(ISFormViewController *)formViewController setValue:(id)value forProperty:(NSString *)property;

@end

@protocol ISFormViewControllerDelegate <NSObject>

- (void)formViewController:(ISFormViewController *)formViewController didPerformActionForKey:(NSString *)key;

@optional

- (void)formViewController:(ISFormViewController *)formViewController willPushViewController:(UIViewController *)viewController forKey:(NSString *)key;

@end

@interface ISFormViewController : UITableViewController
<ISFormItemDelegate
,ISFormViewControllerDataSource
,ISFormViewControllerDelegate
,UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<ISFormViewControllerDataSource> formDataSource;
@property (nonatomic, weak) id<ISFormViewControllerDelegate> formDelegate;
@property (nonatomic, assign) BOOL debug;

- (id)initWithArray:(NSArray *)array;
- (void)registerClass:(Class)class
              forType:(NSString *)type;
- (void)injectValue:(id)value
             forKey:(NSString *)key;

@end
