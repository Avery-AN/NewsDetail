//
//  PageContentViewController.h
//  AveryTest
//
//  Created by Avery An on 2020/1/5.
//  Copyright © 2020 Avery. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PageContentNumber) {
    PageContentNumber_Null = -1,
    PageContentNumber_Page_0 = 1,
    PageContentNumber_Page_1 = 2,
    PageContentNumber_Page_2 = 3
};

NS_ASSUME_NONNULL_BEGIN

@interface PageContentViewController : UIViewController

@property (nonatomic, assign) PageContentNumber pageContentNumber;
@property (nonatomic, assign) BOOL tableCanScroll;
@property (nonatomic) UITableView *tableView;

- (void)loadContent;

@end

NS_ASSUME_NONNULL_END
