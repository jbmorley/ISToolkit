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

#import "ISButtonTableViewCell.h"
#import "ISDetailTableViewCell.h"
#import "ISDisclosureTableViewCell.h"
#import "ISFormViewController.h"
#import "ISImageViewTableViewCell.h"
#import "ISSegmentedControlTableViewCell.h"
#import "ISSwitchTableViewCell.h"
#import "ISTextFieldTableViewCell.h"
#import "ISTextViewTableViewCell.h"

NSString *const ISFormType = @"ISFormType";
NSString *const ISFormTitle = @"ISFormTitle";
NSString *const ISFormTitleKey = @"ISFormTitleKey";
NSString *const ISFormKey = @"ISFormKey";
NSString *const ISFormValue = @"ISFormValue";
NSString *const ISFormDetailText = @"ISFormDetailText";
NSString *const ISFormPlaceholderText = @"ISFormPlaceholderText";
NSString *const ISFormFooterKey = @"ISFormFooterKey";
NSString *const ISFormFooterText = @"ISFormFooterText";
NSString *const ISFormItems = @"ISFormItems";
NSString *const ISFormHeight = @"ISFormHeight";
NSString *const ISFormCondition = @"ISFormCondition";
NSString *const ISFormClass = @"ISFormClass";
NSString *const ISFormMode = @"ISFormMode";
NSString *const ISFormStyle = @"ISFormStyle";
NSString *const ISFormFirstResponder = @"ISFormFirstResponder";

NSString *const ISFormButtonSpecifier = @"ISFormButtonSpecifier";
NSString *const ISFormDetailSpecifier = @"ISFormDetailSpecifier";
NSString *const ISFormDisclosureSpecifier = @"ISFormDisclosureSpecifier";
NSString *const ISFormGroupSpecifier = @"ISFormGroupSpecifier";
NSString *const ISFormImageSpecifier = @"ISFormImageSpecifier";
NSString *const ISFormPickerSpecifier = @"ISFormPickerSpecifier";
NSString *const ISFormSegmentedControlSpecifier = @"ISFormSegmentedControlSpecifier";
NSString *const ISFormSwitchSpecifier = @"ISFormSwitchSpecifier";
NSString *const ISFormTextFieldSpecifier = @"ISFormTextFieldSpecifier";
NSString *const ISFormTextViewSpecifier = @"ISFormTextViewSpecifier";
NSString *const ISFormTimeSpecifier = @"ISFormTimeSpecifier";

@interface NSDictionary (Merge)

- (NSDictionary *)mergeWithDictionary:(NSDictionary *)dictionary;

@end

@implementation NSDictionary (Merge)

- (NSDictionary *)mergeWithDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *result = [self mutableCopy];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop) {
        result[key] = obj;
    }];
    return [result copy];
}

@end


@interface ISFormViewController ()

@property (nonatomic, assign, readwrite) BOOL initialized;
@property (nonatomic, strong) NSArray *definition;
@property (nonatomic, strong) NSMutableDictionary<NSString *, Class> *classes;
@property (nonatomic, strong) NSMutableDictionary *nibs;
@property (nonatomic, strong) NSMutableArray *elements;
@property (nonatomic, strong) NSArray<NSDictionary *> *filteredElements;
@property (nonatomic, strong) NSMapTable<NSString *, id<ISFormItem>> *elementKeys;
@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, assign) NSUInteger count;

@end

@implementation ISFormViewController

/**
 * Apply the configuration to a given item.
 *
 * @param item Item to configure.
 * @param dictionary Dictionary containing the various configuration options.
 */
+ (void)configureItem:(nullable id<ISFormItem>)item withDictionary:(NSDictionary *)dictionary
{
    NSParameterAssert(dictionary);

    // Presuambly the item is not visible, so we do not attempt to configure it.
    if (!item) {
        return;
    }

    if ([item respondsToSelector:@selector(configure:)]) {
        [item configure:dictionary];
    }
}

- (id)initWithArray:(NSArray *)array
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _initialized = NO;
        _animateUpdates = YES;

        [self configureWithItems:array];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _initialized = NO;
        _animateUpdates = YES;
    }
    return self;

}

- (void)configureWithItems:(NSArray *)items
{
    NSParameterAssert(items);

    self.definition = items;
    self.classes = [NSMutableDictionary dictionaryWithCapacity:3];
    self.nibs = [NSMutableDictionary dictionaryWithCapacity:3];
    self.elements = [NSMutableArray arrayWithCapacity:3];
    self.values = [NSMutableDictionary dictionaryWithCapacity:3];
    self.count = 0;
    self.elementKeys = [NSMapTable mapTableWithKeyOptions:NSMapTableCopyIn valueOptions:NSMapTableWeakMemory];

    // Register the default types.
    [self registerNib:[self nibForBundleName:@"ISToolkit" withNibName:@"ISTextFieldTableViewCell"]
              forType:ISFormTextFieldSpecifier];
    [self registerClass:[ISTextFieldTableViewCell class] forType:ISFormTextFieldSpecifier];
    [self registerNib:[self nibForBundleName:@"ISToolkit" withNibName:@"ISSwitchTableViewCell"]
              forType:ISFormSwitchSpecifier];
    [self registerClass:[ISSwitchTableViewCell class] forType:ISFormSwitchSpecifier];
    [self registerNib:[self nibForBundleName:@"ISToolkit" withNibName:@"ISImageViewTableViewCell"]
              forType:ISFormImageSpecifier];
    [self registerClass:[ISSegmentedControlTableViewCell class] forType:ISFormSegmentedControlSpecifier];
    [self registerNib:[self nibForBundleName:@"ISToolkit" withNibName:@"ISSegmentedControlTableViewCell"]
              forType:ISFormSegmentedControlSpecifier];
    [self registerClass:[ISImageViewTableViewCell class] forType:ISFormImageSpecifier];
    [self registerClass:[ISButtonTableViewCell class] forType:ISFormButtonSpecifier];
    [self registerClass:[ISTextViewTableViewCell class] forType:ISFormTextViewSpecifier];
    [self registerClass:[ISDisclosureTableViewCell class] forType:ISFormDisclosureSpecifier];
    [self registerClass:[ISDetailTableViewCell class] forType:ISFormDetailSpecifier];
    [self registerClass:[ISPickerTableViewCell class] forType:ISFormPickerSpecifier];

    self.formDataSource = self;
    self.formDelegate = self;
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
    if (!self.initialized) {
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
                [items addObject:mutableItem];
            }
        }
        [self _updateValues];
        [self _applyPredicates];
        [self.tableView reloadData];
        self.initialized = YES;
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self _assignFirstResponder];
}

- (void)_assignFirstResponder
{
    for (NSDictionary *group in self.elements) {
        for (NSDictionary *item in group[ISFormItems]) {
            NSPredicate *predicate = item[@"firstResponder"];
            if ([predicate evaluateWithObject:self.values]) {
                id<ISFormItem> instance = [self.elementKeys objectForKey:item[ISFormKey]];
                if ([instance respondsToSelector:@selector(becomeFirstResponder)] &&
                    [instance becomeFirstResponder]) {
                    [self log:@"Assigning first responder to '%@'", item[ISFormKey]];
                    return;
                }
            }
        }
    }
}


- (void)_insertPredicate:(NSMutableDictionary *)item
               sourceKey:(NSString *)sourceKey
               targetKey:(NSString *)targetKey
        defaultPredicate:(NSString *)defaultPredicate
{
    NSString *condition = item[sourceKey];
    if (condition) {
        item[targetKey] = [NSPredicate predicateWithFormat:condition];
    } else {
        item[targetKey] = [NSPredicate predicateWithFormat:defaultPredicate];
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

- (void)registerClass:(Class)class forType:(NSString *)type
{
    [self.classes setObject:class forKey:type];
}

- (void)registerNib:(UINib *)nib forType:(NSString *)type
{
    [self.nibs setObject:nib forKey:type];
}

- (Class)classForType:(NSString *)type
{
    NSParameterAssert(type);

    return [self.classes objectForKey:type];
}


/**
 * Load a named XIB or NIB from within a bundle resource.
 *
 * This assumes the file to be loaded is located within the ISForm.framework in the main application bundle.
 *
 * @param bundleName The bundle name from which to load the XIB.
 * @param nibName The name of the XIB or NIB to load.
 *
 * @return The requested XIB or NIB.
 */
- (UINib *)nibForBundleName:(NSString *)bundleName withNibName:(NSString *)nibName
{
    NSParameterAssert(bundleName);
    NSParameterAssert(nibName);

    NSURL *url = [[[[NSBundle mainBundle] privateFrameworksURL]
                   URLByAppendingPathComponent:@"ISForm.framework"]
                  URLByAppendingPathComponent:[bundleName stringByAppendingString:@".bundle"]];
    NSBundle *bundle = [NSBundle bundleWithURL:url];
    return [UINib nibWithNibName:nibName bundle:bundle];
}

- (nonnull UITableViewCell *)cellForType:(nonnull NSString *)type
{
    UINib *nib = [self.nibs objectForKey:type];
    if (nib) {
        NSArray *objects = [nib instantiateWithOwner:nil options:nil];
        return objects[0];
    }

    Class class = [self.classes objectForKey:type];
    
    return [class new];
}

- (void)_updateItem:(nullable id<ISFormItem>)item withValueForKey:(nonnull NSString *)key
{
    NSParameterAssert(key);

    if (!item) {
        return;
    }

    // Fetch the value.
    id value = [self.formDataSource formViewController:self valueForProperty:key];

    // Cache the value in the state.
    if (value) {
        [self.values setObject:value forKey:key];
    }

    // Update the options.
    if ([self.formDataSource respondsToSelector:@selector(formViewController:optionsForProperty:)] &&
        [item respondsToSelector:@selector(setOptions:)]) {
        NSArray *options = [self.formDataSource formViewController:self optionsForProperty:key];
        [item setOptions:options];
    }

    // Set the value on the UI.
    if ([item respondsToSelector:@selector(setValue:)]) {
        [item setValue:value];
    }

}

- (void)_updateValues
{
    [[self.elementKeys dictionaryRepresentation] enumerateKeysAndObjectsUsingBlock:^(NSString *key,
                                                                                     id<ISFormItem> item,
                                                                                     __unused BOOL *stop) {
        [self _updateItem:item withValueForKey:key];
    }];
}


- (void)_dismissKeyboard:(id)sender
{
    [self.tableView resignCurrentFirstResponder];
}


/**
 * Return the currently visible item at a given index path.
 *
 * @param indexPath The index path for which to return the item.
 *
 * @return The item for the specified index path; otherwise, nil.
 */
- (id<ISFormItem>)_itemForIndexPath:(NSIndexPath *)indexPath
{
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

/**
 * Return the index path of a given item.
 *
 * @param item The item to look up.
 *
 * @return The index path of the item if it is currently visible; otherwise, nil.
 */
- (NSIndexPath *)indexPathForItem:(id<ISFormItem>)item
{
    NSParameterAssert(item);
    return [self.tableView indexPathForCell:(UITableViewCell *)item];
}

- (id<ISFormItem>)nextItemForItem:(id<ISFormItem>)item
{
    NSParameterAssert(item);

    NSIndexPath *indexPath = [self indexPathForItem:item];

    if (!indexPath) {
        return nil;
    }

    return [self nextItemForIndexPath:indexPath];
}

- (id<ISFormItem>)nextItemForIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(indexPath);

    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:indexPath.row + 1 inSection:indexPath.section];

    if (nextIndexPath.section > [self.filteredElements count]) {
        return nil;
    }

    if (nextIndexPath.item >= [self.filteredElements[nextIndexPath.section][ISFormItems] count]) {
        nextIndexPath = [NSIndexPath indexPathForItem:0 inSection:nextIndexPath.section + 1];
    }

    return [self _itemForIndexPath:nextIndexPath];
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

- (void)injectValue:(id)value forKey:(NSString *)key
{
    [self injectDictionary:@{key: value ?: [NSNull null]}];
}

- (void)injectDictionary:(NSDictionary *)dictionary
{
    NSParameterAssert(dictionary);

    // Determine the new states (deletion of keys is supported using NSNull).
    NSMutableDictionary *newValues = [self.values mutableCopy];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, __unused BOOL *stop) {
        if (value == [NSNull null]) {
            [newValues removeObjectForKey:key];
        } else {
            [newValues setObject:value forKey:key];
        }
    }];

    BOOL changed = NO;
    NSMutableIndexSet *deletions = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *additions = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *updates = [NSMutableIndexSet indexSet];
    NSMutableArray *itemDeletions = [NSMutableArray array];
    NSMutableArray *itemAdditions = [NSMutableArray array];

    if (self.initialized) {

        // Work out which sections have hidden and been removed.
        NSUInteger before = 0;
        NSUInteger after = 0;

        for (NSDictionary *group in self.elements) {
            NSPredicate *predicate = group[@"predicate"];
            BOOL visibleBefore = [predicate evaluateWithObject:self.values];
            BOOL visibleAfter = [predicate evaluateWithObject:newValues];
            BOOL groupChanged = NO;

            // If there has been a change we need to track it.
            if (visibleBefore != visibleAfter) {

                changed = YES;

                if (visibleBefore) {
                    [deletions addIndex:before];
                } else if (visibleAfter) {
                    [additions addIndex:after];
                }

            } else {

                // Check for sections which have dynamic footers (and presumably headers in the future).
                if (visibleAfter) {
                    if (group[ISFormFooterKey] || group[ISFormTitleKey]) {
                        groupChanged = YES;
                        changed = YES;
                        [updates addIndex:after];
                    }
                }

                // If the group was visible beforehand (and has not changed), we need to to check its items to see if
                // any have been added or removed.
                if (visibleBefore && !groupChanged) {

                    NSUInteger itemBefore = 0;
                    NSUInteger itemAfter = 0;

                    for (NSDictionary *item in group[ISFormItems]) {

                        NSPredicate *itemPredicate = item[@"predicate"];
                        BOOL itemVisibleBefore = [itemPredicate evaluateWithObject:self.values];
                        BOOL itemVisibleAfter = [itemPredicate evaluateWithObject:newValues];

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

        if (!self.animateUpdates) {

            [self _applyPredicates];
            [self.tableView reloadData];

        } else {

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
                [self.tableView deleteSections:deletions withRowAnimation:UITableViewRowAnimationFade];
                [deletions enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [self log:@"- {%d, *}", idx];
                }];
            }

            if (additions.count) {
                [self.tableView insertSections:additions withRowAnimation:UITableViewRowAnimationFade];
                [additions enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [self log:@"+ {%d, *}", idx];
                }];
            }

            if (updates.count) {
                [self.tableView reloadSections:updates withRowAnimation:UITableViewRowAnimationNone];
            }

            [self _applyPredicates];

              // TODO: https://github.com/jbmorley/ISToolkit/issues/4 Configuring the items for keyboard action type can crash
//            BOOL last = YES;
//            for (NSDictionary *group in [self.filteredElements reverseObjectEnumerator]) {
//                for (NSDictionary *item in [group[ISFormItems] reverseObjectEnumerator]) {
//                    if (last) {
//                        [ISFormViewController configureItem:item[@"instance"]
//                                             withDictionary:[item mergeWithDictionary:@{@"returnKeyType": @(UIReturnKeyDone)}]];
//                        last = NO;
//                    } else {
//                        [ISFormViewController configureItem:item[@"instance"]
//                                             withDictionary:[item mergeWithDictionary:@{@"returnKeyType": @(UIReturnKeyNext)}]];
//                    }
//                }
//            }

            [self.tableView endUpdates];

        }

    }

    [self _updateValues];
}

- (void)log:(NSString *)message, ...
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *group = self.filteredElements[section];
    return [group[ISFormItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= [self.filteredElements count] ||
        indexPath.row >= [self.filteredElements[indexPath.section][ISFormItems] count]) {
        return nil;
    }

    NSDictionary *item = self.filteredElements[indexPath.section][ISFormItems][indexPath.item];

    UITableViewCell *cell = [self cellForType:item[ISFormType]];
    id<ISFormItem> formItem = (id<ISFormItem>)cell;

    [ISFormViewController configureItem:formItem withDictionary:item];
    [self _updateItem:formItem withValueForKey:item[ISFormKey]];
    [self.elementKeys setObject:formItem forKey:item[ISFormKey]];

    if ([formItem respondsToSelector:@selector(setSettingsDelegate:)]) {
        formItem.settingsDelegate = self;
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *group = self.filteredElements[section];
    NSString *title = group[ISFormTitle];
    NSString *titleKey = group[ISFormTitleKey];

    if (titleKey) {
        return [self.formDataSource formViewController:self valueForProperty:titleKey];
    } else if (title) {
        return title;
    } else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSDictionary *group = self.filteredElements[section];
    NSString *footerText = group[ISFormFooterText];
    NSString *footerKey = group[ISFormFooterKey];

    if (footerKey) {
        return [self.formDataSource formViewController:self valueForProperty:footerKey];
    } else if (footerText) {
        return footerText;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *details = self.filteredElements[indexPath.section][ISFormItems][indexPath.item];
    NSNumber *height = details[ISFormHeight];
    Class c = [self classForType:details[ISFormType]];

    if (height) {
        return [height floatValue];
    } else if ([c respondsToSelector:@selector(heightForValue:configuration:width:)]) {

        id value = [self.formDataSource formViewController:self valueForProperty:details[ISFormKey]];
        return [c heightForValue:value configuration:details width:CGRectGetWidth(self.tableView.bounds)];
        
    } else {
        return 44.0;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<ISFormItem> item = [self _itemForIndexPath:indexPath];
    if ([item respondsToSelector:@selector(didSelectItem)]) {
        [item didSelectItem];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<ISFormItem> item = (id<ISFormItem>)[self.tableView cellForRowAtIndexPath:indexPath];
    return [item respondsToSelector:@selector(didSelectItem)];
}

#pragma mark - ISSettingsViewControllerItemDelegate

- (void)item:(id<ISFormItem>)item valueDidChange:(id)value
{
    NSString *key = [[self.elementKeys dictionaryRepresentation] allKeysForObject:item][0];
    [self.formDataSource formViewController:self setValue:value forProperty:key];
    [self injectValue:value forKey:key];
}

- (void)itemDidPerformAction:(id<ISFormItem>)item
{
    NSString *key = [[self.elementKeys dictionaryRepresentation] allKeysForObject:item][0];
    [self.formDelegate formViewController:self didPerformActionForKey:key];
}

- (void)item:(id<ISFormItem>)item pushViewController:(UIViewController *)viewController
{
    NSString *key = [[self.elementKeys dictionaryRepresentation] allKeysForObject:item][0];
    if ([self.formDelegate respondsToSelector:@selector(formViewController:willPushViewController:forKey:)]) {
        [self.formDelegate formViewController:self willPushViewController:viewController forKey:key];
    }
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)itemDidEndEditing:(id<ISFormItem>)item
{
    id<ISFormItem> nextItem = [self nextItemForItem:item];

    if (!nextItem) {
        return;
    }

    if ([nextItem respondsToSelector:@selector(becomeFirstResponder)]) {
        [nextItem becomeFirstResponder];
    }
}

#pragma mark - ISFormViewControllerDataSource

- (id)formViewController:(ISFormViewController *)formViewController valueForProperty:(NSString *)property
{
    return nil;
}

- (void)formViewController:(ISFormViewController *)formViewController
                  setValue:(id)value
               forProperty:(NSString *)property
{
}

#pragma mark - ISFormViewControllerDelegate

- (void)formViewController:(ISFormViewController *)formViewController didPerformActionForKey:(NSString *)key
{
    NSLog(@"formViewController:didPerformActionForKey:%@", key);
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return [self.tableView containsCurrentFirstResponder];
}

@end
