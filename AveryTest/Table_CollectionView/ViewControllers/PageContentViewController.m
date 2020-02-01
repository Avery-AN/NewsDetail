//
//  PageContentViewController.m
//  AveryTest
//
//  Created by Avery An on 2020/1/5.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "PageContentViewController.h"

@interface PageContentViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSMutableArray *datas;
@end

@implementation PageContentViewController

#pragma mark - Life Cycle -
- (void)dealloc {
    NSLog(@" %s", __func__);
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@" %s",__func__);
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@" %s",__func__);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)getDatas {
    if (!self.datas) {
        self.datas = [NSMutableArray array];
    }
    
    NSString *pageString = nil;
    NSInteger count = 0;
    if (self.pageContentNumber == PageContentNumber_Page_0) {
        pageString = @"Page_1";
        count = 20;
    }
    else if (self.pageContentNumber == PageContentNumber_Page_1) {
        pageString = @"Page_2";
        count = 50;
    }
    else if (self.pageContentNumber == PageContentNumber_Page_2) {
        pageString = @"Page_3";
        count = 20;
    }
    
    for (int i = 0; i < count; i++) {
        [self.datas addObject:[NSString stringWithFormat:@" (%@)   Cell - %d", pageString, i]];
    }
}


#pragma mark - Public Methods -
- (void)loadContent {
    if (self.tableView.superview == nil) {
        [self getDatas];
        [self.view addSubview:self.tableView];
    }
    [self.tableView reloadData];
    
    NSLog(@"self.tableView.frame: %@",NSStringFromCGRect(self.tableView.frame));
}


#pragma mark - TableView Datasource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellID = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [self.datas objectAtIndex:indexPath.row];
    return cell;
}


#pragma mark - UIScrollView Delegate -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.tableCanScroll) {
        scrollView.contentOffset = CGPointZero;
    }
    
    if (scrollView.contentOffset.y <= 0) {
        self.tableCanScroll = NO;
        scrollView.contentOffset = CGPointZero;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"backToTop" object:nil];  // 到顶通知父视图改变状态
    }
    self.tableView.showsVerticalScrollIndicator = self.tableCanScroll ? YES : NO;
}


#pragma mark - Property -
- (UITableView *)tableView {
    if (!_tableView) {
        CGRect bounds = self.view.bounds;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor purpleColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
