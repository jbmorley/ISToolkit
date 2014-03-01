//
//  ISFormViewController.m
//  Pods
//
//  Created by Jason Barrie Morley on 01/03/2014.
//
//

#import <ISUtilities/UIView+Parent.h>
#import "ISFormViewController.h"
#import "ISTextFieldTableViewCell.h"
#import "ISButtonTableViewCell.h"
#import "ISSwitchTableViewCell.h"
#import "ISTextViewTableViewCell.h"
#import "ISDisclosureTableViewCell.h"

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
                                   withNibName:@"ISTextFieldTableViewCell"] forType:PSTextFieldSpecifier];
      [self registerNib:[self nibForBundleName:@"ISToolkit"
                                   withNibName:@"ISSwitchTableViewCell"] forType:PSToggleSwitchSpecifier];
      [self registerClass:[ISButtonTableViewCell class]
                  forType:ISButtonSpecifier];
      [self registerClass:[ISTextViewTableViewCell class]
                  forType:ISTextViewSpecifier];
      [self registerClass:[ISDisclosureTableViewCell class]
                  forType:ISDisclosureSpecifier];
      
      // Dismiss the keyboard when the user taps the view.
      UITapGestureRecognizer *dismissRecognizer
      = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissKeyboard:)];
      dismissRecognizer.delegate = self;
      [self.tableView addGestureRecognizer:dismissRecognizer];
      
      self.dataSource = self;
      self.delegate = self;

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
  
  // Create the elements.
  if (!_initialized) {
    NSMutableDictionary *group = nil;
    for (NSDictionary *item in self.definition) {
      if ([item[Type] isEqualToString:PSGroupSpecifier]) {
        group = [item mutableCopy];
        group[Items] = [NSMutableArray arrayWithCapacity:3];
        
        // Parse the display conditions.
        NSString *show = item[Show];
        if (show) {
          group[@"predicate"] = [NSPredicate predicateWithFormat:show];
        } else {
          group[@"predicate"] = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
        }
        
        [self.elements addObject:group];
      } else {
        assert(group != nil); // TODO Throw exception.
        NSMutableArray *items = group[Items];
        id instance = [self _configuredInstanceForItem:item];
        NSMutableDictionary *mutableItem = [item mutableCopy];
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
  id<ISSettingsViewControllerItem> instance = [self _instanceForItem:item];
  [instance configure:item];
  instance.settingsDelegate = self;
  
  // Add the instance to the lookup.
  [self.elementKeys setObject:instance
                       forKey:item[Key]];
  
  return instance;
}


- (id)_instanceForItem:(NSDictionary *)item
{
  NSString *type = item[Type];
  
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
     id<ISSettingsViewControllerItem> item,
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


- (id<ISSettingsViewControllerItem>)_itemForIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *group = self.filteredElements[indexPath.section];
  return [group[Items] objectAtIndex:indexPath.item][@"instance"];
}


- (void)_applyPredicates
{
  NSMutableArray *filteredElements = [NSMutableArray arrayWithCapacity:3];
  for (NSDictionary *group in self.elements) {
    NSPredicate *predicate = group[@"predicate"];
    BOOL show = [predicate evaluateWithObject:self.values];
    NSLog(@"%@ => %d", group[Title], show);
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
  return [group[Items] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return (UITableViewCell *)[self _itemForIndexPath:indexPath];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  NSDictionary *group = self.filteredElements[section];
  return group[Title];
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
  NSDictionary *group = self.filteredElements[section];
  return group[FooterText];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *group = self.filteredElements[indexPath.section];
  NSNumber *height = [group[Items] objectAtIndex:indexPath.item][Height];
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
  id<ISSettingsViewControllerItem> item =
  [self _itemForIndexPath:indexPath];
  if ([item respondsToSelector:@selector(didSelectItem)]) {
    [item didSelectItem];
  }
  [self.tableView deselectRowAtIndexPath:indexPath
                                animated:YES];
}


#pragma mark - ISSettingsViewControllerItemDelegate


- (void)item:(id<ISSettingsViewControllerItem>)item valueDidChange:(id)value
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


- (void)itemDidPerformAction:(id<ISSettingsViewControllerItem>)item
{
  NSString *key = [self.elementKeys allKeysForObject:item][0];
  [self.delegate formViewController:self
             didPerformActionForKey:key];
}


- (void)item:(id<ISSettingsViewControllerItem>)item pushViewController:(UIViewController *)viewController
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
