//
//  ISFormViewController.m
//  Pods
//
//  Created by Jason Barrie Morley on 01/03/2014.
//
//

#import "ISFormViewController.h"
#import "ISTextFieldTableViewCell.h"
#import "ISButtonTableViewCell.h"
#import "ISSwitchTableViewCell.h"
#import "ISTextViewTableViewCell.h"
#import <ISUtilities/UIView+Parent.h>

@interface ISFormViewController ()

@property (nonatomic, strong) NSArray *definition;
@property (nonatomic, strong) NSMutableDictionary *classes;
@property (nonatomic, strong) NSMutableDictionary *nibs;
@property (nonatomic, strong) NSMutableArray *elements;
@property (nonatomic, strong) NSMutableDictionary *elementKeys;

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
      
      // Register the default types.
      [self registerNib:[self nibForBundleName:@"ISToolkit"
                                   withNibName:@"ISTextFieldTableViewCell"] forType:PSTextFieldSpecifier];
      [self registerNib:[self nibForBundleName:@"ISToolkit"
                                   withNibName:@"ISSwitchTableViewCell"] forType:PSToggleSwitchSpecifier];
      [self registerClass:[ISButtonTableViewCell class]
                  forType:ISButtonSpecifier];
      [self registerClass:[ISTextViewTableViewCell class]
                  forType:ISTextViewSpecifier];
      
      // Dismiss the keyboard when the user taps the view.
      UITapGestureRecognizer *dismissRecognizer
      = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
      [self.tableView addGestureRecognizer:dismissRecognizer];
      
      self.dataSource = self;
      self.delegate = self;

    }
    return self;
}


- (void)viewDidLoad
{
  [super viewDidLoad];

  // Create the elements.
  NSMutableDictionary *group = nil;
  for (NSDictionary *item in self.definition) {
    if ([item[Type] isEqualToString:PSGroupSpecifier]) {
      group = [item mutableCopy];
      group[Items] = [NSMutableArray arrayWithCapacity:3];
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
  
}


- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self _updateValues];
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
     [item setValue:[self.dataSource formViewController:self valueForProperty:key]];
   }];
}


- (void)dismissKeyboard:(id)sender
{
  [self.tableView resignCurrentFirstResponder];
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.elements.count;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  NSDictionary *group = self.elements[section];
  return [group[Items] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *group = self.elements[indexPath.section];
  return [group[Items] objectAtIndex:indexPath.item][@"instance"];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  NSDictionary *group = self.elements[section];
  return group[Title];
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
  NSDictionary *group = self.elements[section];
  return group[FooterText];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *group = self.elements[indexPath.section];
  NSNumber *height = [group[Items] objectAtIndex:indexPath.item][Height];
  if (height) {
    return [height floatValue];
  } else {
    return 44.0;
  }
}


#pragma mark - ISSettingsViewControllerItemDelegate


- (void)item:(id<ISSettingsViewControllerItem>)item valueDidChange:(id)value
{
  NSString *key = [self.elementKeys allKeysForObject:item][0];
  [self.dataSource formViewController:self
                             setValue:value
                          forProperty:key];
}


- (void)itemDidPerformAction:(id<ISSettingsViewControllerItem>)item
{
  NSString *key = [self.elementKeys allKeysForObject:item][0];
  [self.delegate formViewController:self
             didPerformActionForKey:key];
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


@end
