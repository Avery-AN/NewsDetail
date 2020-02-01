//
//  ContentCell.h
//  AveryTest
//
//  Created by Avery An on 2020/1/5.
//  Copyright © 2020 Avery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContentCell : UITableViewCell

@property (nonatomic, unsafe_unretained) ActionBlock actionBlock;
@property (nonatomic, assign) BOOL cellCanScroll;

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(nullable NSString *)reuseIdentifier
       contentViewControllers:(NSArray *)viewControllers
                contentHeight:(NSInteger)contentHeight
             inViewController:(UIViewController *)viewController
                selectedIndex:(NSInteger)selectedIndex;

- (void)selectPageAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
