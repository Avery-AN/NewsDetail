//
//  TestViewController.m
//  AveryTest
//
//  Created by Avery An on 2020/1/5.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "TestViewController.h"
#import "ContentCell.h"
#import "PageContentViewController.h"
#import "ContentTableView.h"

static NSInteger SectionHeaderHeight = 50;
static NSInteger DefaultTag = 100;
static NSInteger DefaultFontSize = 13;
static NSInteger SelectFontSize = 19;

@interface TestViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSInteger contentHeight;
@property (nonatomic) ContentTableView *tableView;
@property (nonatomic) NSMutableArray *viewControllers;
@property (nonatomic) UIView *sectionHeader;
@property (nonatomic, assign) BOOL tableCanScroll;
@property (nonatomic) ContentCell *contentCell;
@end

@implementation TestViewController

#pragma mark - Life Cycle -
- (void)dealloc {
    NSLog(@"%s",__func__);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.viewControllers = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        PageContentViewController *vc = [PageContentViewController new];
        vc.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - NavigationBarHeight - SectionHeaderHeight);
        if (i == 0) {
            vc.view.backgroundColor = [UIColor orangeColor];
            vc.pageContentNumber = PageContentNumber_Page_0;
        }
        else if (i == 1) {
            vc.view.backgroundColor = [UIColor cyanColor];
            vc.pageContentNumber = PageContentNumber_Page_1;
        }
        else if (i == 2) {
            vc.view.backgroundColor = [UIColor lightGrayColor];
            vc.pageContentNumber = PageContentNumber_Page_2;
        }
        [self.viewControllers addObject:vc];
    }
    self.contentHeight = UIHeight - NavigationBarHeight - SectionHeaderHeight;
    [self processSectionHeaderUI];
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeScrollStatus) name:@"backToTop" object:nil];
}


#pragma mark - Private Methods -
- (void)processSectionHeaderUI {
    NSInteger items = self.viewControllers.count;
    NSInteger buttonWidth = UIWidth / items;
    CGFloat buttonHeight = SectionHeaderHeight;
    for (int i = 0; i < items; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = i + DefaultTag;
        button.frame = CGRectMake(i * buttonWidth, 0, buttonWidth, buttonHeight);
        [button.titleLabel setTextColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(selectPage:) forControlEvents:UIControlEventTouchUpInside];
        [self.sectionHeader addSubview:button];
        
        switch (i) {
            case 0: {
                [button setTitle:@"页面一" forState:UIControlStateNormal];
                
                UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(buttonWidth, 0, 0.5, buttonHeight)];
                line.backgroundColor = [UIColor whiteColor];
                [self.sectionHeader addSubview:line];
            }
                break;
                
            case 1: {
                [button setTitle:@"页面二" forState:UIControlStateNormal];
                
                UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(buttonWidth*2, 0, 0.5, buttonHeight)];
                line.backgroundColor = [UIColor whiteColor];
                [self.sectionHeader addSubview:line];
            }
                break;
                
            case 2: {
                [button setTitle:@"页面三" forState:UIControlStateNormal];
            }
                break;
                
            default:
                break;
        }
    }
}
- (void)selectPage:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (!button || button.selected) {
        return;
    }
    [self selectButton:button];
    
    if (button.tag == DefaultTag) {
        [self selectPageAtIndex:0];
    }
    else if (button.tag == DefaultTag + 1) {
        [self selectPageAtIndex:1];
    }
    else if (button.tag == DefaultTag + 2) {
        [self selectPageAtIndex:2];
    }
}
- (void)selectButton:(UIButton *)button {
    [button.titleLabel setFont:[UIFont systemFontOfSize:SelectFontSize]];
    button.selected = YES;
    
    if (button.tag == DefaultTag) {
        UIButton *button_1 = [self.sectionHeader viewWithTag:(DefaultTag + 1)];
        [button_1.titleLabel setFont:[UIFont systemFontOfSize:DefaultFontSize]];
        button_1.selected = NO;
        UIButton *button_2 = [self.sectionHeader viewWithTag:(DefaultTag + 2)];
        [button_2.titleLabel setFont:[UIFont systemFontOfSize:DefaultFontSize]];
        button_2.selected = NO;
    }
    else if (button.tag == DefaultTag + 1) {
        UIButton *button_0 = [self.sectionHeader viewWithTag:(DefaultTag)];
        [button_0.titleLabel setFont:[UIFont systemFontOfSize:DefaultFontSize]];
        button_0.selected = NO;
        UIButton *button_2 = [self.sectionHeader viewWithTag:(DefaultTag + 2)];
        [button_2.titleLabel setFont:[UIFont systemFontOfSize:DefaultFontSize]];
        button_2.selected = NO;
    }
    else if (button.tag == DefaultTag + 2) {
        UIButton *button_0 = [self.sectionHeader viewWithTag:(DefaultTag)];
        [button_0.titleLabel setFont:[UIFont systemFontOfSize:DefaultFontSize]];
        button_0.selected = NO;
        UIButton *button_1 = [self.sectionHeader viewWithTag:(DefaultTag + 1)];
        [button_1.titleLabel setFont:[UIFont systemFontOfSize:DefaultFontSize]];
        button_1.selected = NO;
    }
}
- (void)selectPageAtIndex:(int)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    ContentCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell selectPageAtIndex:index];
}


#pragma mark - TableView Datasource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 260;
    }
    else {
        return self.contentHeight;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return SectionHeaderHeight;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return self.sectionHeader;
    }
    return nil;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellID = @"UITableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    else {
        static NSString *cellID = @"ContentCell";
        ContentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            NSInteger page = 1;  // 默认选择的页码
            UIButton *button = [self.sectionHeader viewWithTag:page+DefaultTag];
            [self selectButton:button];
            
            cell = [[ContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID contentViewControllers:self.viewControllers contentHeight:self.contentHeight inViewController:self selectedIndex:page];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            __weak typeof(self) weakSelf = self;
            cell.actionBlock = ^(CGFloat offsetX, SlidingDirection slidingDirection, NSInteger currentPage, BOOL paged) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                NSInteger tag = currentPage + DefaultTag;
                UIButton *button = [strongSelf.sectionHeader viewWithTag:tag];
                
                if (paged) {
                    NSLog(@"翻页了");
                    
                    [strongSelf selectButton:button];
                    if (button.tag == DefaultTag) {
                        [strongSelf selectPageAtIndex:0];
                    }
                    else if (button.tag == DefaultTag + 1) {
                        [strongSelf selectPageAtIndex:1];
                    }
                    else if (button.tag == DefaultTag + 2) {
                        [strongSelf selectPageAtIndex:2];
                    }
                }
                else {
                    CGFloat rate = offsetX / cell.bounds.size.width;
                    CGFloat value = rate * (SelectFontSize - DefaultFontSize);
                    [button.titleLabel setFont:[UIFont systemFontOfSize:SelectFontSize-value]];
                    
                    if (slidingDirection == SlidingDirection_toLeft) {
                        UIButton *button_pre = [strongSelf.sectionHeader viewWithTag:tag-1];
                        [button_pre.titleLabel setFont:[UIFont systemFontOfSize:DefaultFontSize+value]];
                    }
                    else if (slidingDirection == SlidingDirection_toRight) {
                        UIButton *button_nex = [strongSelf.sectionHeader viewWithTag:tag+1];
                        [button_nex.titleLabel setFont:[UIFont systemFontOfSize:DefaultFontSize+value]];
                    }
                }
            };
        }
        self.contentCell = cell;
        self.tableCanScroll = YES;
        self.contentCell.cellCanScroll = NO;
        return cell;
    }
}


#pragma mark - UIScrollView Delegate -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat bottomCellOffset = [self.tableView rectForSection:1].origin.y;
    if (scrollView.contentOffset.y - bottomCellOffset >= 0.) {
        scrollView.contentOffset = CGPointMake(0, bottomCellOffset);
        if (self.tableCanScroll) {
            self.tableCanScroll = NO;
            self.contentCell.cellCanScroll = YES;
        }
    }
    else {
        if (!self.tableCanScroll) {  // 子视图没到顶部
            scrollView.contentOffset = CGPointMake(0, bottomCellOffset);
        }
    }
    self.tableView.showsVerticalScrollIndicator = self.tableCanScroll ? YES : NO;
}


#pragma mark - notify -
- (void)changeScrollStatus {
    self.tableCanScroll = YES;
    self.contentCell.cellCanScroll = NO;
}


#pragma mark - Property -
- (ContentTableView *)tableView {
    if (!_tableView) {
        _tableView = [[ContentTableView alloc] initWithFrame:CGRectMake(0, NavigationBarHeight, UIWidth, UIHeight - NavigationBarHeight) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}
- (UIView *)sectionHeader {
    if (!_sectionHeader) {
        _sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIWidth, SectionHeaderHeight)];
        _sectionHeader.backgroundColor = [UIColor colorWithRed:236/255. green:236/255. blue:236/255. alpha:1];
    }
    return _sectionHeader;
}

@end
