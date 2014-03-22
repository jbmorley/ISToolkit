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

@end

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
  
  // Create and configure the flow layout.
  self.flowLayout = [ISRotatingFlowLayout new];
  self.flowLayout.adjustsItemSize = YES;
  self.flowLayout.spacing = 2.0f;
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    self.flowLayout.minimumItemSize = CGSizeMake(283.0, 72.0);
  } else {
    self.flowLayout.minimumItemSize = CGSizeMake(283.0, 72.0);
  }
  
  self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
  self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.collectionView.alwaysBounceVertical = YES;
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
  [self.view addSubview:self.collectionView];
  
  self.collectionView.backgroundColor = [UIColor whiteColor];
  
  self.adapter = [[ISListViewAdapter alloc] initWithDataSource:self];
  self.connector = [ISListViewAdapterConnector connectorWithAdapter:self.adapter collectionView:self.collectionView];
  
  // Register the download cell.
  NSBundle* bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"ISToolkit" withExtension:@"bundle"]];
  UINib *nib = [UINib nibWithNibName:@"ISCacheCollectionViewCell" bundle:bundle];
  [self.collectionView registerNib:nib
        forCellWithReuseIdentifier:kCacheCollectionViewCellReuseIdentifier];
  
  [[ISCache defaultCache] addCacheObserver:self];
}


- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.adapter invalidate];
}


#pragma mark - UICollectionViewDataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
  return self.connector.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  ISCacheCollectionViewCell *cell
  = [collectionView dequeueReusableCellWithReuseIdentifier:kCacheCollectionViewCellReuseIdentifier forIndexPath:indexPath];

  ISCacheItem *cacheItem = [[self.adapter itemForIndexPath:indexPath] fetchBlocking];
  
  cell.delegate = self;
  cell.cacheItem = cacheItem;
  
  if ([self.delegate respondsToSelector:@selector(cacheViewController:imageURLForItem:)]) {
    NSString *url = [self.delegate cacheViewController:self imageURLForItem:cacheItem];
    [cell.imageView setImageWithIdentifier:url context:ISCacheImageContext preferences:nil placeholderImage:nil block:NULL];
  }
  
  return cell;
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
  // TODO Can we use the blocking mechanism for this?
  ISListViewAdapterItem *item =
  [self.adapter itemForIndexPath:indexPath];
  [item fetch:^(ISCacheItem *item) {
    [self.delegate cacheViewController:self
                    didSelectCacheItem:item];
  }];
}


#pragma mark - ISCacheCollectionViewCellDelegate


- (void)cell:(ISCacheCollectionViewCell *)cell didFetchItem:(ISCacheItem *)item
{
  if ([self.delegate respondsToSelector:@selector(cacheViewController:didFetchCacheItem:)]) {
    [self.delegate cacheViewController:self
                     didFetchCacheItem:item];
  }
}


- (void)cell:(ISCacheCollectionViewCell *)cell didRemoveItem:(ISCacheItem *)item
{
  if ([self.delegate respondsToSelector:@selector(cacheViewController:didRemoveCacheItem:)]) {
    [self.delegate cacheViewController:self
                    didRemoveCacheItem:item];
  }
}


- (void)cell:(ISCacheCollectionViewCell *)cell didCancelItem:(ISCacheItem *)item
{
  if ([self.delegate respondsToSelector:@selector(cacheViewController:didCancelCacheItem:)]) {
    [self.delegate cacheViewController:self
                    didCancelCacheItem:item];
  }
}


@end
