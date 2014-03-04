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

#import <ISUtilities/UIView+Parent.h>
#import "ISFormViewController.h"
#import "ISTextFieldTableViewCell.h"
#import "ISButtonTableViewCell.h"
#import "ISSwitchTableViewCell.h"
#import "ISTextViewTableViewCell.h"
#import "ISDisclosureTableViewCell.h"
#import "ISDetailTableViewCell.h"
#import "ISPickerTableViewCell.h"


// Keys.
NSString *const ISFormType = @"ISFormType";
NSString *const ISFormTitle = @"ISFormTitle";
NSString *const ISFormKey = @"ISFormKey";
NSString *const ISFormDetailText = @"ISFormDetailText";
NSString *const ISFormPlaceholderText = @"ISFormPlaceholderText";
NSString *const ISFormFooterText = @"ISFormFooterText";
NSString *const ISFormItems = @"ISFormItems";
NSString *const ISFormHeight = @"ISFormHeight";
NSString *const ISFormCondition = @"ISFormCondition";
NSString *const ISFormClass = @"ISFormClass";

// Types.
NSString *const ISFormGroupSpecifier = @"ISFormGroupSpecifier";
NSString *const ISFormTextFieldSpecifier = @"IFormTextFieldSpecifier";
NSString *const ISFormSwitchSpecifier = @"ISFormSwitchSpecifier";
NSString *const ISFormButtonSpecifier = @"ISFormButtonSpecifier";
NSString *const ISFormTextViewSpecifier = @"ISFormTextViewSpecifier";
NSString *const ISFormDisclosureSpecifier = @"ISFormDisclosureSpecifier";
NSString *const ISFormDetailSpecifier = @"ISFormDetailSpecifier";
NSString *const ISFormPickerSpecifier = @"ISFormPickerSpecifier";


@interface ISFormViewController () {
  BOOL _initialized;
}

@property (nonatomic, strong) NSArray *definition;
@property (nonatomic, strong) NSMutableDictionary *classes;
@property (nonatomic, strong) NSMutableDictionary *nibs;
@property (nonatomic, strong) NSMutableArray *elements;
@property (nonatomic, strong) NSArray *filteredElements;
@property (nonatomic, strong) NSMutableDictionary *elementKeys;
@property (nonatomic, strong) NSMutableDictionary *values;

@end

@implementation ISFormViewController


- (id)initWithArray:(NSArray *)array
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
      self.definition = array;
      self.classes = [NSMutableDictionary dictionaryWithCapacity:3];
      self.nibs = [NSMutableDictionary dictionaryWithCapacity:3];
      self.elements = [NSMutableArray arrayWithCapacity:3];
      self.elementKeys = [NSMutableDictionary dictionaryWithCapacity:3];
      self.values = [NSMutableDictionary dictionaryWithCapacity:3];
      
      // Register the default types.
      [self registerNib:[self nibForBundleName:@"ISToolkit"
                                   withNibName:@"ISTextFieldTableViewCell"] forType:ISFormTextFieldSpecifier];
      [self registerNib:[self nibForBundleName:@"ISToolkit"
                                   withNibName:@"ISSwitchTableViewCell"] forType:ISFormSwitchSpecifier];
      [self registerClass:[ISButtonTableViewCell class]
                  forType:ISFormButtonSpecifier];
      [self registerClass:[ISTextViewTableViewCell class]
                  forType:ISFormTextViewSpecifier];
      [self registerClass:[ISDisclosureTableViewCell class]
                  forType:ISFormDisclosureSpecifier];
      [self registerClass:[ISDetailTableViewCell class]
                  forType:ISFormDetailSpecifier];
      [self registerClass:[ISPickerTableViewCell class]
                  forType:ISFormPickerSpecifier];
      
      // Dismiss the keyboard when the user taps the view.
      UITapGestureRecognizer *dismissRecognizer
      = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissKeyboard:)];
      dismissRecognizer.delegate = self;
      [self.tableView addGestureRecognizer:dismissRecognizer];
      
      self.dataSource = self;
      self.formDelegate = self;

    }
    return self;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  NSUInteger count = 0;
  
  // Create the elements.
  if (!_initialized) {
    NSMutableDictionary *group = nil;
    for (NSDictionary *item in self.definition) {
      if ([item[ISFormType] isEqualToString:ISFormGroupSpecifier]) {
        group = [item mutableCopy];
        group[ISFormItems] = [NSMutableArray arrayWithCapacity:3];
        
        // Parse the display conditions.
        NSString *show = item[ISFormCondition];
        if (show) {
          group[@"predicate"] = [NSPredicate predicateWithFormat:show];
        } else {
          group[@"predicate"] = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
        }
        
        [self.elements addObject:group];
      } else {
        assert(group != nil); // TODO Throw exception.
        NSMutableArray *items = group[ISFormItems];
        NSMutableDictionary *mutableItem = [item mutableCopy];
        
        // Generate a key if one doesn't exist.
        if (mutableItem[ISFormKey] == nil) {
          mutableItem[ISFormKey] = [NSString stringWithFormat:@"%@%d", mutableItem[ISFormType], count];
          count++;
        }
        
        id instance = [self _configuredInstanceForItem:mutableItem];
        mutableItem[@"instance"] = instance;
        
        [items addObject:mutableItem];
      }
    }
    [self _updateValues];
    [self _applyPredicates];
    [self.tableView reloadData];
    _initialized = YES;
  }
  
}


- (void)registerClass:(Class)class
              forType:(NSString *)type
{
  [self.classes setObject:class
                 forKey:type];
}

- (void)registerNib:(UINib *)nib
            forType:(NSString *)type
{
  [self.nibs setObject:nib
                forKey:type];
}


- (UINib *)nibForBundleName:(NSString *)bundleName
                withNibName:(NSString *)nibName
{
  NSBundle* bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:bundleName withExtension:@"bundle"]];
  UINib *nib = [UINib nibWithNibName:nibName
                              bundle:bundle];
  return nib;
}


- (id)_configuredInstanceForItem:(NSDictionary *)item
{
  id<ISFormItem> instance = [self _instanceForItem:item];
  
  if ([instance respondsToSelector:@selector(configure:)]) {
    [instance configure:item];
  }
       
  if ([instance respondsToSelector:@selector(setSettingsDelegate:)]) {
    instance.settingsDelegate = self;
  }
  
  // Add the instance to the lookup.
  [self.elementKeys setObject:instance
                       forKey:item[ISFormKey]];
  
  return instance;
}


- (id)_instanceForItem:(NSDictionary *)item
{
  NSString *type = item[ISFormType];
  
  // Attempt to load a nib.
  UINib *nib = [self.nibs objectForKey:type];
  if (nib) {
    NSArray *objects = [nib instantiateWithOwner:nil
                                         options:nil];
    return objects[0];
  }
  
  // Attempt to load a classs.
  Class class = [self.classes objectForKey:type];
  return [class new];
}


- (void)_updateValues
{
  [self.elementKeys enumerateKeysAndObjectsUsingBlock:
   ^(NSString *key,
     id<ISFormItem> item,
     BOOL *stop) {
     
     // Fetch the value.
     id value = [self.dataSource formViewController:self valueForProperty:key];
     
     // Cache the value in the state.
     if (value) {
       [self.values setObject:value
                       forKey:key];
     }
     
     // Set the value on the UI.
     if ([item respondsToSelector:@selector(setValue:)]) {
       [item setValue:value];
     }
   }];
}


- (void)_dismissKeyboard:(id)sender
{
  [self.tableView resignCurrentFirstResponder];
}


- (id<ISFormItem>)_itemForIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *group = self.filteredElements[indexPath.section];
  return [group[ISFormItems] objectAtIndex:indexPath.item][@"instance"];
}


- (void)_applyPredicates
{
  NSMutableArray *filteredElements = [NSMutableArray arrayWithCapacity:3];
  for (NSDictionary *group in self.elements) {
    NSPredicate *predicate = group[@"predicate"];
    BOOL show = [predicate evaluateWithObject:self.values];
    if (show) {
      [filteredElements addObject:group];
    }
  }
  self.filteredElements = filteredElements;
}


- (void)injectValue:(id)value
             forKey:(NSString *)key
{
  // Determine the new states.
  NSMutableDictionary *newValues = [self.values mutableCopy];
  if (value) {
    [newValues setObject:value
                  forKey:key];
  } else {
    [newValues removeObjectForKey:key];
  }
  
  BOOL changed = NO;
  NSMutableArray *filteredElements =
  [NSMutableArray arrayWithCapacity:3];
  NSMutableIndexSet *deletions = [NSMutableIndexSet indexSet];
  NSMutableIndexSet *additions = [NSMutableIndexSet indexSet];
  if (_initialized) {
    
    // Work out which sections have hidden and been removed.
    NSUInteger before = 0;
    NSUInteger after = 0;
    
    for (NSDictionary *group in self.elements) {
      NSPredicate *predicate = group[@"predicate"];
      BOOL visibleBefore =
      [predicate evaluateWithObject:self.values];
      BOOL visibleAfter =
      [predicate evaluateWithObject:newValues];
      
      // If there has been a change we need to track it.
      if (visibleBefore != visibleAfter) {
        
        changed = YES;
        
        if (visibleBefore) {
          [deletions addIndex:before];
        } else if (visibleAfter) {
          [additions addIndex:after];
        }
        
      }
      
      // Add the elements to the filtered array.
      if (visibleAfter) {
        [filteredElements addObject:group];
      }
      
      // Increment the counts.
      
      if (visibleBefore) {
        before++;
      }
      
      if (visibleAfter) {
        after++;
      }
      
    }
    
  }
  
  // Cache the value.
  self.values = newValues;
  
  // Update the table view.
  if (changed) {
    [self.tableView beginUpdates];
    if (deletions.count) {
      [self.tableView deleteSections:deletions
                    withRowAnimation:UITableViewRowAnimationFade];
    }
    if (additions.count) {
      [self.tableView insertSections:additions
                    withRowAnimation:UITableViewRowAnimationFade];
    }
    self.filteredElements = filteredElements;
    [self.tableView endUpdates];
  }
  
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.filteredElements.count;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  NSDictionary *group = self.filteredElements[section];
  return [group[ISFormItems] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return (UITableViewCell *)[self _itemForIndexPath:indexPath];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  NSDictionary *group = self.filteredElements[section];
  return group[ISFormTitle];
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
  NSDictionary *group = self.filteredElements[section];
  return group[ISFormFooterText];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *group = self.filteredElements[indexPath.section];
  NSNumber *height = [group[ISFormItems] objectAtIndex:indexPath.item][ISFormHeight];
  if (height) {
    return [height floatValue];
  } else {
    return 44.0;
  }
}


#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  id<ISFormItem> item =
  [self _itemForIndexPath:indexPath];
  if ([item respondsToSelector:@selector(didSelectItem)]) {
    [item didSelectItem];
  }
  [self.tableView deselectRowAtIndexPath:indexPath
                                animated:YES];
}


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
  id<ISFormItem> item =
  [self _itemForIndexPath:indexPath];
  return [item respondsToSelector:@selector(didSelectItem)];
}


#pragma mark - ISSettingsViewControllerItemDelegate


- (void)item:(id<ISFormItem>)item valueDidChange:(id)value
{
  // Look up the key.
  NSString *key = [self.elementKeys allKeysForObject:item][0];
  
  // Notify our data source.
  [self.dataSource formViewController:self
                             setValue:value
                          forProperty:key];

  // Update the internal state.
  [self injectValue:value
             forKey:key];
  
}


- (void)itemDidPerformAction:(id<ISFormItem>)item
{
  NSString *key = [self.elementKeys allKeysForObject:item][0];
  [self.formDelegate formViewController:self
             didPerformActionForKey:key];
}


- (void)item:(id<ISFormItem>)item pushViewController:(UIViewController *)viewController
{
  [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - ISFormViewControllerDataSource


- (id)formViewController:(ISFormViewController *)formViewController valueForProperty:(NSString *)property
{
  return nil;
}


- (void)formViewController:(ISFormViewController *)formViewController setValue:(id)value forProperty:(NSString *)property
{
}


#pragma mark - ISFormViewControllerDelegate


- (void)formViewController:(ISFormViewController *)formViewController didPerformActionForKey:(NSString *)key
{
}


#pragma mark - UIGestureRecognizerDelegate


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
  return [self.tableView containsCurrentFirstResponder];
}


@end
