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

#import "ISCacheViewController.h"
#import "ISRotatingFlowLayout.h"
#import "ISCacheFile.h"
#import "ISCacheStateFilter.h"
#import "ISCacheUserInfoFilter.h"

@interface ISCacheViewController () {
  NSUInteger _count;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ISListViewAdapter *adapter;
@property (nonatomic, strong) ISListViewAdapterConnector *connector;
@property (nonatomic, strong) ISRotatingFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableDictionary *titleCache;

@end

static NSString *kCacheCollectionViewHeaderReuseIdentifier = @"CacheHeader";
static NSString *kCacheCollectionViewCellReuseIdentifier = @"CacheCell";

@implementation ISCacheViewController


- (id)init
{
  self = [super init];
  if (self) {
    [self _initialize];
  }
  return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self _initialize];
  }
  return self;
}


- (void)_initialize
{
  self.title = @"Downloads";
  
  self.titleCache = [NSMutableDictionary dictionaryWithCapacity:3];
  
  // Create and configure the flow layout.
  self.flowLayout = [ISRotatingFlowLayout new];
  self.flowLayout.adjustsItemSize = YES;
  self.flowLayout.spacing = 2.0f;
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    self.flowLayout.minimumItemSize = CGSizeMake(283.0, 72.0);
  } else {
    self.flowLayout.minimumItemSize = CGSizeMake(283.0, 72.0);
  }
  self.flowLayout.headerReferenceSize = CGSizeMake(0.0, 20.0);
  
  self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
  self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.collectionView.alwaysBounceVertical = YES;
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
  [self.view addSubview:self.collectionView];
  
  self.collectionView.backgroundColor = [UIColor whiteColor];
  
  self.adapter = [[ISListViewAdapter alloc] initWithDataSource:self];
  self.connector = [ISListViewAdapterConnector connectorWithAdapter:self.adapter collectionView:self.collectionView];
  self.connector.incrementalUpdates = YES;
  
  // Register the views.
  NSBundle* bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"ISToolkit" withExtension:@"bundle"]];
  UINib *nib = [UINib nibWithNibName:@"ISCacheCollectionViewCell" bundle:bundle];
  [self.collectionView registerNib:nib
        forCellWithReuseIdentifier:kCacheCollectionViewCellReuseIdentifier];
  [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCacheCollectionViewHeaderReuseIdentifier];
  
  [[ISCache defaultCache] addCacheObserver:self];
}


- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.adapter invalidate];
}


- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self.connector ready];
}


- (NSString *)titleForItem:(ISCacheItem *)cacheItem
{
  NSString *title = [self.titleCache objectForKey:cacheItem.uid];
  if (title) {
    return title;
  } else if ([self.delegate respondsToSelector:@selector(cacheViewController:titleForItem:)]) {
    title = [self.delegate cacheViewController:self
                                  titleForItem:cacheItem];
    if (title) {
      [self.titleCache setObject:title
                          forKey:cacheItem.uid];
    }
  }
  return title;
}


#pragma mark - UICollectionViewDataSource


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return [self.connector numberOfSections];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
  return [self.connector numberOfItemsInSection:section];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  ISCacheCollectionViewCell *cell
  = [collectionView dequeueReusableCellWithReuseIdentifier:kCacheCollectionViewCellReuseIdentifier forIndexPath:indexPath];

  ISCacheItem *cacheItem = [[self.adapter itemForIndexPath:indexPath] fetchBlocking];
  
  cell.delegate = self;
  cell.cacheItem = cacheItem;
  
  // Title.
  [cell setTitle:[self titleForItem:cacheItem]];
  
  // Image URL.
  if ([self.delegate respondsToSelector:@selector(cacheViewController:imageURLForItem:)]) {
    NSString *url = [self.delegate cacheViewController:self imageURLForItem:cacheItem];
    [cell.imageView setImageWithIdentifier:url context:ISCacheImageContext preferences:nil placeholderImage:nil block:NULL];
  }
  
  return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
  if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
    UICollectionReusableView *header = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCacheCollectionViewHeaderReuseIdentifier forIndexPath:indexPath];
    header.backgroundColor = [UIColor magentaColor];
    return header;
  }
  return nil;
}


#pragma mark - ISListViewAdapterDataSource


- (void)itemsForAdapter:(ISListViewAdapter *)adapter
        completionBlock:(ISListViewAdapterBlock)completionBlock
{
  ISCache *defaultCache = [ISCache defaultCache];
  ISCacheStateFilter *filter = self.filter;
  if (filter == nil) {
    filter = [ISCacheStateFilter filterWithStates:ISCacheItemStateAll];
  }
  
  NSArray *items = [defaultCache items:filter];
  
  // Sort the items.
  items = [items sortedArrayUsingComparator:
           ^NSComparisonResult(ISCacheItem *item1, ISCacheItem *item2) {
             if (item1.state == item2.state) {
               return [[self titleForItem:item1] compare:[self titleForItem:item2]];
             } else if (item1.state < item2.state) {
               return NSOrderedAscending;
             } else {
               return NSOrderedDescending;
             }
           }];
  
  completionBlock(items);
}


- (id)adapter:(ISListViewAdapter *)adapter
identifierForItem:(id)item
{
  ISCacheItem *cacheItem = item;
  return cacheItem.uid;
}


- (id)adapter:(ISListViewAdapter *)adapter
summaryForItem:(id)item
{
  return @"";
}


- (NSString *)adapter:(ISListViewAdapter *)adapter sectionForItem:(id)item
{
  ISCacheItem *cacheItem = item;
  if (cacheItem.state == ISCacheItemStateInProgress) {
    return @"In Progress";
  } else if (cacheItem.state == ISCacheItemStateNotFound) {
    return @"Not Found";
  } else if (cacheItem.state == ISCacheItemStateFound) {
    return @"Found";
  }
  return @"";
}


- (void)adapter:(ISListViewAdapter *)adapter
itemForIdentifier:(id)identifier
completionBlock:(ISListViewAdapterBlock)completionBlock
{
  ISCache *defaultCache = [ISCache defaultCache];
  completionBlock([defaultCache itemForUid:identifier]);
}


#pragma mark - ISCacheObserver


- (void)cacheDidUpdate:(ISCache *)cache
{
  ISCache *defaultCache = [ISCache defaultCache];
  id<ISCacheFilter> filter = self.filter;
  if (filter == nil) {
    filter = [ISCacheStateFilter filterWithStates:ISCacheItemStateAll];
  }
  filter = [ISCacheCompoundFilter filterMatching:filter and:[ISCacheStateFilter filterWithStates:ISCacheItemStateInProgress]];
  NSArray *items = [defaultCache items:filter];
  
  [self willChangeValueForKey:@"count"];
  _count = items.count;
  [self didChangeValueForKey:@"count"];
  
  [self.adapter invalidate];
}


#pragma mark - UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  ISCacheItem *item =
  [[self.adapter itemForIndexPath:indexPath] fetchBlocking];
  [self.delegate cacheViewController:self
                  didSelectCacheItem:item];
}


#pragma mark - ISCacheCollectionViewCellDelegate


- (void)cell:(ISCacheCollectionViewCell *)cell
didFetchItem:(ISCacheItem *)item
{
  if ([self.delegate respondsToSelector:@selector(cacheViewController:didFetchCacheItem:)]) {
    [self.delegate cacheViewController:self
                     didFetchCacheItem:item];
  }
}


- (void)cell:(ISCacheCollectionViewCell *)cell
didRemoveItem:(ISCacheItem *)item
{
  if ([self.delegate respondsToSelector:@selector(cacheViewController:didRemoveCacheItem:)]) {
    [self.delegate cacheViewController:self
                    didRemoveCacheItem:item];
  }
}


- (void)cell:(ISCacheCollectionViewCell *)cell
didCancelItem:(ISCacheItem *)item
{
  if ([self.delegate respondsToSelector:@selector(cacheViewController:didCancelCacheItem:)]) {
    [self.delegate cacheViewController:self
                    didCancelCacheItem:item];
  }
}


@end
