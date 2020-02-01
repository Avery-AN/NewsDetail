//
//  ContentCell.m
//  AveryTest
//
//  Created by Avery An on 2020/1/5.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "ContentCell.h"

@interface ContentCell ()
@property (nonatomic) NSInteger contentHeight;
@property (nonatomic) PageContentView *pageContentView;
@end

@implementation ContentCell

#pragma mark - Public Methods -
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(nullable NSString *)reuseIdentifier
       contentViewControllers:(NSArray *)viewControllers
                contentHeight:(NSInteger)contentHeight
             inViewController:(UIViewController *)viewController
                selectedIndex:(NSInteger)selectedIndex {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentHeight = contentHeight;
        self.pageContentView.contentControllers = viewControllers;
        self.pageContentView.parentViewController = viewController;
        [self.contentView addSubview:self.pageContentView];
        [self.pageContentView selectedAtIndex:selectedIndex];
    }
    return self;
}
- (void)selectPageAtIndex:(NSInteger)index {
    [self.pageContentView selectedAtIndex:index];
}


#pragma mark - Property -
- (PageContentView *)pageContentView {
    if (!_pageContentView) {
        _pageContentView = [[PageContentView alloc] initWithFrame:CGRectMake(0, 0, UIWidth, self.contentHeight)];
    }
    return _pageContentView;
}
- (void)setActionBlock:(ActionBlock)actionBlock {
    self.pageContentView.actionBlock = actionBlock;
}
- (void)setCellCanScroll:(BOOL)cellCanScroll {
    _cellCanScroll = cellCanScroll;
    
    for (PageContentViewController *VC in self.pageContentView.contentControllers) {
        VC.tableCanScroll = cellCanScroll;
        if (!cellCanScroll) {   // 如果cell不能滑动，代表到了顶部，修改所有子vc的状态回到顶部
            VC.tableView.contentOffset = CGPointZero;
        }
    }
}

@end
