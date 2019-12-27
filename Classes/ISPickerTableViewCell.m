//
// Copyright (c) 2013-2014 InSeven Limited.
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

#import "ISPickerTableViewCell.h"
#import "ISForm.h"

NSString *const ISPickerModeSingle = @"single";
NSString *const ISPickerModeMultiple = @"multiple";

@interface ISPickerTableViewCell ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *selections;
@property (nonatomic, assign) ISPickerViewControllerMode mode;
@property (nonatomic, strong) NSString *placeholder;

@end

@implementation ISPickerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
  if (self) {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  return self;
}


#pragma mark - ISSettingsViewControllerItem


- (void)configure:(NSDictionary *)configuration
{
  self.textLabel.text = configuration[ISFormTitle];
  self.detailTextLabel.text = configuration[ISFormDetailText];
  self.items = configuration[ISFormItems];
  self.placeholder = configuration[ISFormPlaceholderText];
  if ([configuration[ISFormMode] isEqualToString:ISPickerModeSingle]) {
    self.mode = ISPickerViewControllerModeSingle;
  } else if ([configuration[ISFormMode] isEqualToString:ISPickerModeMultiple]) {
    self.mode = ISPickerViewControllerModeMultiple;
  } else {
    self.mode = ISPickerViewControllerModeSingle;
  }
}

- (void)setValue:(id)value
{
  if (value) {
    self.selections = value;
  } else {
    self.selections = @[];
  }
  [self _updateDetails];
}

- (void)setOptions:(NSArray *)options
{
    self.items = options;
}

- (void)_updateDetails
{
  if (self.selections.count == 0) {
    self.detailTextLabel.text = self.placeholder;
    self.detailTextLabel.textColor = [UIColor colorWithRed:0.807 green:0.806 blue:0.826 alpha:1.000];
  } else {
    NSMutableArray *titles =
    [NSMutableArray arrayWithCapacity:self.selections.count];
    for (NSDictionary *item in self.items) {
      if ([self.selections containsObject:item[ISFormValue]]) {
        [titles addObject:item[ISFormTitle]];
      }
    }
    self.detailTextLabel.text =
    [titles componentsJoinedByString:@", "];
    self.detailTextLabel.textColor = [UIColor colorWithRed:0.607 green:0.607 blue:0.620 alpha:1.000];
  }
}


- (void)didSelectItem
{
  ISPickerViewController *viewController = [[ISPickerViewController alloc] initWithItems:self.items];
  viewController.mode = ISPickerViewControllerModeSingle;
  viewController.delegate = self;
  viewController.title = self.textLabel.text;
  viewController.selections = [self.selections mutableCopy];
  viewController.mode = self.mode;

  [self.settingsDelegate item:self
           pushViewController:viewController];
}


#pragma mark - ISPickerViewControllerDelegate


- (void) pickerViewControllerDidDismiss:(ISPickerViewController *)pickerViewController
{
  self.selections = pickerViewController.selections;
  [self _updateDetails];
  [self.settingsDelegate item:self
               valueDidChange:pickerViewController.selections];
}


@end
