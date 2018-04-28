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

#import "ISPickerViewController.h"
#import "ISForm.h"

@interface ISPickerViewController ()

@property (nonatomic, strong) NSMutableArray *groups;

@end

static NSString *const CellIdentifier = @"Cell";

@implementation ISPickerViewController

- (id)initWithItems:(NSArray *)items
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {

        self.groups = [NSMutableArray arrayWithCapacity:3];
        NSMutableArray *group = nil;
        for (NSDictionary *item in items) {
            NSString *type = item[ISFormType];
            if ([type isEqualToString:ISFormGroupSpecifier]) {
                if (group) {
                    [self.groups addObject:group];
                }
                group = [NSMutableArray arrayWithCapacity:3];
            } else {
                if (group == nil) {
                    group = [NSMutableArray arrayWithCapacity:3];
                }
                [group addObject:item];
            }
        }
        if (group == nil) {
            return self;
        }
        [self.groups addObject:group];

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


- (NSIndexPath *)_selectedIndex
{
    if (self.selections.count != 1) {
        return nil;
    }

    __block NSIndexPath *indexPath = nil;
    [self.groups enumerateObjectsUsingBlock:^(NSArray *group, NSUInteger section, BOOL *stop) {

         [group enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger row, BOOL *stop) {
              if ([item[ISFormValue] isEqualToString:self.selections[0]]) {
                  indexPath = [NSIndexPath indexPathForRow:row
                                                 inSection:section];
                  *stop = YES;
              }
          }];

         if (indexPath) {
             *stop = YES;
         }

     }];
    return indexPath;
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.groups.count;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSArray *group = self.groups[section];
    return group.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSArray *group = self.groups[indexPath.section];
    NSDictionary *item = group[indexPath.item];
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
    NSArray *group = self.groups[indexPath.section];
    NSDictionary *item = group[indexPath.item];

    if (self.mode == ISPickerViewControllerModeSingle) {

        NSIndexPath *selectedIndex = [self _selectedIndex];
        if (!selectedIndex) {

            self.selections = [@[item[ISFormValue]] mutableCopy];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        } else if (![selectedIndex isEqual:indexPath]) {

            self.selections = [@[item[ISFormValue]] mutableCopy];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath, selectedIndex]
                                  withRowAnimation:UITableViewRowAnimationFade];

        } else {

            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

        }

    } else if (self.mode == ISPickerViewControllerModeMultiple) {
        
        if ([self.selections containsObject:item[ISFormValue]]) {
            [self.selections removeObject:item[ISFormValue]];
        } else {
            [self.selections addObject:item[ISFormValue]];
        }
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
}


@end
