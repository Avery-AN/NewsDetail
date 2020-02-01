//
//  RootViewController.m
//  AveryTest
//
//  Created by Avery An on 2019/12/17.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "RootViewController.h"
#import "TestViewController.h"
#import "NewsViewController.h"

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor orangeColor];
    button.frame = CGRectMake(36, 160, 330, 60);
    [button setTitle:@"Table_CollectionView" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.backgroundColor = [UIColor orangeColor];
    button2.frame = CGRectMake(36, 260, 330, 60);
    [button2 setTitle:@"Scroll_Web_TableView" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(tapAction_2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
}

- (void)tapAction {
    TestViewController *testVC = [TestViewController new];
    [self.navigationController pushViewController:testVC animated:YES];
}
- (void)tapAction_2 {
    NewsViewController *newsVC = [NewsViewController new];
    [self.navigationController pushViewController:newsVC animated:YES];
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
