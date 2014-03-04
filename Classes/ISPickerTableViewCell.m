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

#import "ISPickerTableViewCell.h"
#import "ISForm.h"

@interface ISPickerTableViewCell ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *selections;

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


- (void)_updateDetails
{
  NSMutableArray *titles = [NSMutableArray arrayWithCapacity:self.selections.count];
  for (NSDictionary *item in self.items) {
    if ([self.selections containsObject:item[ISFormKey]]) {
      [titles addObject:item[ISFormTitle]];
    }
  }
  self.detailTextLabel.text = [titles componentsJoinedByString:@", "];
}


- (void)didSelectItem
{
  ISPickerViewController *viewController = [[ISPickerViewController alloc] initWithItems:self.items];
  viewController.mode = ISPickerViewControllerModeSingle;
  viewController.delegate = self;
  viewController.title = self.textLabel.text;
  viewController.selections = [self.selections mutableCopy];
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
