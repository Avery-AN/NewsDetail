//
//  PageContentView.m
//  AveryTest
//
//  Created by Avery An on 2020/1/5.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "PageContentView.h"

static NSString *CellReuseIdentifier = @"QAPageContentView";
static NSInteger DefaultTag = 1000;

@interface PageContentView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic) UICollectionView *collectionView;
@end

@implementation PageContentView

#pragma mark - Life Cycle -
- (void)dealloc {
    NSLog(@"%s",__func__);
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


#pragma mark - Public Methods -
- (void)selectedAtIndex:(NSInteger)index {
    self->_currentPage = index;
    [self addSubview:self.collectionView];
    [self.collectionView setContentOffset:CGPointMake(index * UIWidth, 0)];
    
    PageContentViewController *vc = [self.contentControllers objectAtIndex:index];
    [vc loadContent];
}


#pragma mark - UICollectionView Datasource & Delegate -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.contentControllers.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    if (!IS_IOS8_LATER) {
        if (![cell.contentView viewWithTag:indexPath.row + DefaultTag]) {
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            UIViewController *childVC = self.contentControllers[indexPath.item];
            childVC.view.frame = cell.contentView.bounds;
            childVC.view.tag = indexPath.row + DefaultTag;
            [cell.contentView addSubview:childVC.view];
            // [self.parentViewController addChildViewController:childVC];
        }
    }
    return cell;
}

#ifdef __IPHONE_8_0
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![cell.contentView viewWithTag:indexPath.row + DefaultTag]) {
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UIViewController *childVC = self.contentControllers[indexPath.row];
        childVC.view.frame = cell.contentView.bounds;
        childVC.view.tag = indexPath.row + DefaultTag;
        [cell.contentView addSubview:childVC.view];
        // [self.parentViewController addChildViewController:childVC];
    }
}
#endif


#pragma mark - UIScrollView Delegate -
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    if (self.actionBlock) {
        self.actionBlock(self.bounds.size.width, SlidingDirection_Null, currentPage, YES);
    }
    
    self->_currentPage = currentPage;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < 0 ||
        scrollView.contentOffset.x >= self.bounds.size.width * (self.contentControllers.count - 1)) {
        return;
    }
    
    SlidingDirection slidingDirection = 0;
    if (scrollView.contentOffset.x - self.currentPage * self.bounds.size.width >= 0) {
        slidingDirection = SlidingDirection_toRight;
    }
    else {
        slidingDirection = SlidingDirection_toLeft;
    }
    
    if (self.actionBlock) {
        CGFloat offsetX = fabs(scrollView.contentOffset.x - self.currentPage * self.bounds.size.width);
        self.actionBlock(offsetX, slidingDirection, self.currentPage, NO);
    }
}


#pragma mark - Property -
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = self.bounds.size;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellReuseIdentifier];
    }
    
    return _collectionView;
}

@end
