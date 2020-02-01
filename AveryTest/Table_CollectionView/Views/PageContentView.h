//
//  PageContentView.h
//  AveryTest
//
//  Created by Avery An on 2020/1/5.
//  Copyright © 2020 Avery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"

typedef NS_ENUM(NSInteger, SlidingDirection) {
    SlidingDirection_Null = -1,
    SlidingDirection_toLeft = 1,    // 从右至左
    SlidingDirection_toRight = 2    // 从左至右
};

/**
 @param offsetX 滑动距离
 @param slidingDirection 滑动方向
 @param currentPage 当前的页码
 @param paged 是否滑动了一页
 */
typedef void (^ActionBlock)(CGFloat offsetX, SlidingDirection slidingDirection, NSInteger currentPage, BOOL paged);

NS_ASSUME_NONNULL_BEGIN

@interface PageContentView : UIView

@property (nonatomic, assign, readonly) NSInteger currentPage;
@property (nonatomic, weak) NSArray *contentControllers;
@property (nonatomic, weak) UIViewController *parentViewController;
@property (nonatomic, copy) ActionBlock actionBlock;

- (void)selectedAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
