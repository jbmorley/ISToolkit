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

#import <ISUtilities/ISUtilities.h>
#import <ISUtilities/UIKit+ISUtilities.h>
#import "ISFormViewController.h"
#import "ISTextFieldTableViewCell.h"
#import "ISButtonTableViewCell.h"
#import "ISSwitchTableViewCell.h"
#import "ISTextViewTableViewCell.h"
#import "ISDisclosureTableViewCell.h"
#import "ISDetailTableViewCell.h"


// Keys.
NSString *const ISFormType = @"ISFormType";
NSString *const ISFormTitle = @"ISFormTitle";
NSString *const ISFormKey = @"ISFormKey";
NSString *const ISFormValue = @"ISFormValue";
NSString *const ISFormDetailText = @"ISFormDetailText";
NSString *const ISFormPlaceholderText = @"ISFormPlaceholderText";
NSString *const ISFormFooterText = @"ISFormFooterText";
NSString *const ISFormItems = @"ISFormItems";
NSString *const ISFormHeight = @"ISFormHeight";
NSString *const ISFormCondition = @"ISFormCondition";
NSString *const ISFormClass = @"ISFormClass";
NSString *const ISFormMode = @"ISFormMode";
NSString *const ISFormStyle = @"ISFormStyle";
NSString *const ISFormFirstResponder = @"ISFormFirstResponder";

// Types.
NSString *const ISFormGroupSpecifier = @"ISFormGroupSpecifier";
NSString *const ISFormTextFieldSpecifier = @"IFormTextFieldSpecifier";
NSString *const ISFormSwitchSpecifier = @"ISFormSwitchSpecifier";
NSString *const ISFormButtonSpecifier = @"ISFormButtonSpecifier";
NSString *const ISFormTextViewSpecifier = @"ISFormTextViewSpecifier";
NSString *const ISFormDisclosureSpecifier = @"ISFormDisclosureSpecifier";
NSString *const ISFormDetailSpecifier = @"ISFormDetailSpecifier";
NSString *const ISFormPickerSpecifier = @"ISFormPickerSpecifier";
NSString *const ISFormTimeSpecifier = @"ISFormTimeSpecifier";


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
@property (nonatomic, assign) NSUInteger count;

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
      self.count = 0;
      
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
      
      self.formDataSource = self;
      self.formDelegate = self;
      
    }
    return self;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Dismiss the keyboard when the user taps the view.
  UITapGestureRecognizer *dismissRecognizer
  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissKeyboard:)];
  dismissRecognizer.delegate = self;
  [self.tableView addGestureRecognizer:dismissRecognizer];

}


- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  // Create the elements.
  if (!_initialized) {
    NSMutableDictionary *group = nil;
    for (NSDictionary *item in self.definition) {
      if ([item[ISFormType] isEqualToString:ISFormGroupSpecifier]) {
        group = [item mutableCopy];
        group[ISFormItems] = [NSMutableArray arrayWithCapacity:3];
        [self _insertPredicate:group
                     sourceKey:ISFormCondition
                     targetKey:@"predicate"
              defaultPredicate:@"TRUEPREDICATE"];
        [self.elements addObject:group];
      } else {
        assert(group != nil); // TODO Throw exception.
        NSMutableArray *items = group[ISFormItems];
        NSMutableDictionary *mutableItem = [item mutableCopy];
        [self _insertPredicate:mutableItem
                     sourceKey:ISFormCondition
                     targetKey:@"predicate"
              defaultPredicate:@"TRUEPREDICATE"];
        [self _insertPredicate:mutableItem
                     sourceKey:ISFormFirstResponder
                     targetKey:@"firstResponder"
              defaultPredicate:@"FALSEPREDICATE"];
        [self _insertKey:mutableItem];
        [self _insertInstance:mutableItem];
        [items addObject:mutableItem];
      }
    }
    [self _updateValues];
    [self _applyPredicates];
    [self.tableView reloadData];
    _initialized = YES;
  }
  
  [self _assignFirstResponder];
}


- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}


- (void)_assignFirstResponder
{
  for (NSDictionary *group in self.elements) {
    for (NSDictionary *item in group[ISFormItems]) {
      NSPredicate *predicate = item[@"firstResponder"];
      if ([predicate evaluateWithObject:self.values]) {
        if ([item[@"instance"] respondsToSelector:@selector(becomeFirstResponder)] && [item[@"instance"] becomeFirstResponder]) {
          [self log:
           @"Assigning first responder to '%@'",
           item[ISFormKey]];
          return;
        }
      }
    }
  }
}


- (void)_insertInstance:(NSMutableDictionary *)item
{
  id instance = [self _configuredInstanceForItem:item];
  item[@"instance"] = instance;
}


- (void)_insertPredicate:(NSMutableDictionary *)item
               sourceKey:(NSString *)sourceKey
               targetKey:(NSString *)targetKey
        defaultPredicate:(NSString *)defaultPredicate
{
  NSString *condition = item[sourceKey];
  if (condition) {
    item[targetKey] =
    [NSPredicate predicateWithFormat:condition];
  } else {
    item[targetKey] =
    [NSPredicate predicateWithFormat:defaultPredicate];
  }
}


- (void)_insertKey:(NSMutableDictionary *)item
{
  // Generate a key if one doesn't exist.
  if (item[ISFormKey] == nil) {
    item[ISFormKey] = [NSString stringWithFormat:@"%@%lu", item[ISFormType], (unsigned long)self.count];
    self.count++;
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
     id value = [self.formDataSource formViewController:self valueForProperty:key];
     
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
    if ([predicate evaluateWithObject:self.values]) {
      
      NSMutableDictionary *mutableGroup = [group mutableCopy];
      mutableGroup[ISFormItems] = [NSMutableArray arrayWithCapacity:3];
      
      for (NSDictionary *item in group[ISFormItems]) {
        
        NSPredicate *itemPredicate = item[@"predicate"];
        if ([itemPredicate evaluateWithObject:self.values]) {
          [mutableGroup[ISFormItems] addObject:item];
        }
        
      }
      [filteredElements addObject:mutableGroup];
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
  NSMutableIndexSet *deletions = [NSMutableIndexSet indexSet];
  NSMutableIndexSet *additions = [NSMutableIndexSet indexSet];
  NSMutableArray *itemDeletions =
  [NSMutableArray arrayWithCapacity:3];
  NSMutableArray *itemAdditions =
  [NSMutableArray arrayWithCapacity:3];

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
        
      } else {
        
        // If the group was visible beforehand we need to
        // to check its items to see if any have been added
        // or removed.
        if (visibleBefore) {
          
          NSUInteger itemBefore = 0;
          NSUInteger itemAfter = 0;
          
          for (NSDictionary *item in group[ISFormItems]) {
            NSPredicate *itemPredicate = item[@"predicate"];
            BOOL itemVisibleBefore =
            [itemPredicate evaluateWithObject:self.values];
            BOOL itemVisibleAfter =
            [itemPredicate evaluateWithObject:newValues];
            
            if (itemVisibleBefore != itemVisibleAfter) {
              
              changed = YES;
              
              if (itemVisibleBefore) {
                [itemDeletions addObject:[NSIndexPath indexPathForItem:itemBefore inSection:before]];
              } else if (itemVisibleAfter) {
                [itemAdditions addObject:[NSIndexPath indexPathForItem:itemAfter inSection:after]];
              }

            }
            
            if (itemVisibleBefore) {
              itemBefore++;
            }
            
            if (itemVisibleAfter) {
              itemAfter++;
            }
            
          }
          
        }
        
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
    if (itemDeletions.count) {
      [self.tableView deleteRowsAtIndexPaths:itemDeletions withRowAnimation:UITableViewRowAnimationFade];
      for (NSIndexPath *indexPath in itemDeletions) {
        [self log:@"- {%d, %d}", indexPath.section, indexPath.row];
      }
    }
    if (itemAdditions.count) {
      [self.tableView insertRowsAtIndexPaths:itemAdditions withRowAnimation:UITableViewRowAnimationFade];
      for (NSIndexPath *indexPath in itemAdditions) {
        [self log:@"+ {%d, %d}", indexPath.section, indexPath.row];
      }
    }
    if (deletions.count) {
      [self.tableView deleteSections:deletions
                    withRowAnimation:UITableViewRowAnimationFade];
      [deletions enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self log:@"- {%d, *}", idx];
      }];
    }
    if (additions.count) {
      [self.tableView insertSections:additions
                    withRowAnimation:UITableViewRowAnimationFade];
      [additions enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self log:@"+ {%d, *}", idx];
      }];
    }
    [self _applyPredicates];
    [self.tableView endUpdates];
  }
  
}


-(void)log:(NSString *)message, ...
{
  if (self.debug) {
    va_list args;
    va_start(args, message);
    NSLogv(message, args);
    va_end(args);
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
  [self.formDataSource formViewController:self
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
  NSString *key = [self.elementKeys allKeysForObject:item][0];
  if ([self.formDelegate respondsToSelector:@selector(formViewController:willPushViewController:forKey:)]) {
    [self.formDelegate formViewController:self willPushViewController:viewController forKey:key];
  }
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
  NSLog(@"formViewController:didPerformActionForKey:%@", key);
}


#pragma mark - UIGestureRecognizerDelegate


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
  return [self.tableView containsCurrentFirstResponder];
}


@end
