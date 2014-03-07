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

#import "ISPickerViewController.h"
#import "ISForm.h"

@interface ISPickerViewController ()

@property (nonatomic, strong) NSArray *items;

@end

static NSString *const CellIdentifier = @"Cell";

@implementation ISPickerViewController

- (id)initWithItems:(NSArray *)items
{
  self = [super initWithStyle:UITableViewStyleGrouped];
  if (self) {
    self.items = items;
    self.selections = [@[] mutableCopy];
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:CellIdentifier];
  }
  return self;
}


- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  if (self.isMovingFromParentViewController) {
    [self.delegate pickerViewControllerDidDismiss:self];
  }
}


- (NSUInteger)_selectedIndex
{
  if (self.selections.count != 1) {
    return 0;
  }
  
  __block NSUInteger index = 0;
  [self.items enumerateObjectsUsingBlock:
   ^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
     if ([item[ISFormValue] isEqualToString:self.selections[0]]) {
       index = idx;
       *stop = YES;
     }
   }];
  return index;
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  NSDictionary *item = self.items[indexPath.item];
  cell.textLabel.text = item[ISFormTitle];
  
  if ([self.selections containsObject:item[ISFormValue]]) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  
  return cell;
}


#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *item = self.items[indexPath.item];
  
  if (self.mode ==
      ISPickerViewControllerModeSingle) {
    
    NSUInteger selectedIndex = [self _selectedIndex];
    if (selectedIndex != indexPath.item) {
      self.selections = [@[item[ISFormValue]] mutableCopy];
      NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
      [self.tableView reloadRowsAtIndexPaths:@[indexPath, previousIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
      [self.tableView deselectRowAtIndexPath:indexPath
                                    animated:YES];
    }
    
  } else if (self.mode ==
             ISPickerViewControllerModeMultiple) {
    
    if ([self.selections containsObject:item[ISFormValue]]) {
      [self.selections removeObject:item[ISFormValue]];
    } else {
      [self.selections addObject:item[ISFormValue]];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
  }
  
}


@end
