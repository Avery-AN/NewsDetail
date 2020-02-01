//
//  NewsViewController.m
//  AveryTest
//
//  Created by Avery An on 2020/1/6.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "NewsViewController.h"
#import <WebKit/WebKit.h>
#import "HtmlManager.h"

static int gap_web_table = 20;   // webView & tableView之间的间隔

@interface NewsViewController () <UIScrollViewDelegate, WKNavigationDelegate, WKUIDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, WKScriptMessageHandler>
@property (nonatomic) NSString *html;
@property (nonatomic) HtmlManager *htmlManager;
@property (nonatomic) UIScrollView *containerView;
@property (nonatomic) UIProgressView *progressView;
@property (nonatomic) WKWebView *webView;
@property (nonatomic) NSMutableArray *datas;
@property (nonatomic) UITableView *tableView;
@property (nonatomic, assign) CGFloat containerViewHeight;
@property (nonatomic, assign) CGFloat containerViewContentHeight;
@property (nonatomic, assign) CGFloat webViewHeight;
@property (nonatomic, assign) CGFloat webViewContentHeight;
@property (nonatomic, assign) CGFloat webViewMaxContentOffset;
@property (nonatomic, assign) CGFloat tableViewHeight;
@property (nonatomic, assign) CGFloat tableViewContentHeight;
@property (nonatomic, assign) CGFloat tableViewMaxOriginY;
@end

@implementation NewsViewController

#pragma mark - Life Cycle -
- (void)dealloc {
    NSLog(@"%s",__func__);
    
    if (self.webView) {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadHtml];
    [self addImageClickEventForWebview];
    [self addImageLongpressEventForWebview];
    
    [self loadTableDatas];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.webView];
}


#pragma mark - Private Methods -
- (void)loadHtml {
    [self createHtml];
    
    if (self.htmlManager == nil) {
        HtmlManager *htmlManager = [HtmlManager new];
        self.htmlManager = htmlManager;
        self.html = [htmlManager appendLocalCssStytle:self.html];
        [htmlManager processImagesInHtml:self.html
                                 webView:self.webView
                              completion:^(NSString * _Nullable _html, NSArray * _Nullable imageUrls) {
            self.html = _html;
            [self.webView loadHTMLString:self.html baseURL:nil];
        }];
    }
    
    if (self.webView.estimatedProgress == 1) {
        self.progressView.hidden = YES;
    }
    else {
        [self.view addSubview:self.progressView];
    }
}
- (void)createHtml {
    NSString *html = @"<html> \n"
    "<head> \n"
    "<style type=\"text/css\"> \n"
    "body {font-size:16px;} \n"
    "</style> \n"
    "</head> \n"
    "<body><script type='text/javascript'>window.onload = function(){ \n"
    "    var $img = document.getElementsByTagName('img'); \n"
    "    for(var p in  $img){ \n"
    "        $img[p].style.width = '100%'; \n"
    "        $img[p].style.height ='auto' \n"
    "    } \n"
    "}</script><!DOCTYPE html><html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0,user-scalable=NO\"/></script></head><body><p>文章开始</p> \n"
    "<p>最近，“区块链”的热度居高不下，但一些地方出现“虚火过旺”，比如有人怀着暴富心态花式蹭热点，借区块链大肆炒作；有人直接宣扬“炒币获得官方支持”， 热炒空气币等。区块链不是炒作的“噱头”、行骗的“招牌”，也绝不等于数字货币。\n人民日报发表评论称，区块链的出现虽与虚拟货币有着千丝万缕的关系，但区块链并不能与虚拟货币画等号，虚拟货币更不是区块链应用的全部。一些人故意混淆“币”“链”概念，与虚拟货币相关的炒作花样翻新、投机盛行，价格暴涨暴跌的背后风险快速聚集。即使是最具代表性的虚拟货币“比特币”，也不是哪国的法定流通货币，本质仍是一种投资风险极高的虚拟商品。看上去很美的风口，很可能又是陷阱罢了。\n任何创新都应以合法合规为前提。占据区块链技术制高点，亦没有捷径可走。目前，区块链技术应用已延伸到数字金融、物联网、智能制造等领域。</p> \n"
    "<p style=\"text-align:center;\"><img src=\"https://upload-images.jianshu.io/upload_images/17788728-c70af7cb2d08d901.jpg\" /></p> \n"
    "<p style=\"text-align:center;\"><img src=\"https://upload-images.jianshu.io/upload_images/14892748-590eb681e5adfa96\" /></p>  \n"
    "<p style=\"text-align:center;\"><img src=\"https:www.avery.com/123/abc.jpg!thumb\" /></p>  \n"
    "<p style=\"text-align:start;\">​靠区块链发横财不靠谱，不过这个行业还有很多机会，技术的发展存在非常大的想象空间。</p> \n"
    "<p style=\"text-align:start;\">任何创新都应以合法合规为前提。占据区块链技术制高点，亦没有捷径可走。</p> \n"
    "<p style=\"text-align:start;\"><img src=\"https://upload-images.jianshu.io/upload_images/8666040-e168249b5659f7b1.jpeg\" /></p> \n"
    "<p style=\"text-align:start;\">​目前，区块链技术应用已延伸到数字金融、物联网、智能制造等领域。</p> \n"
    "<p style=\"text-align:start;\">如果要实现一个底部带有相关推荐和评论的资讯详情页，很自然会想到WebView和TableView嵌套使用的方案。 这个方案是WebView作为TableView的TableHeaderView或者TableView的一个Cell，然后根据网页的高度动态的更新TableHeaderView和Cell的高度，这个方案逻辑上最简单，也最容易实现，而且滑动效果也比较好。然而在实际应用中发现如果资讯内容很长而且带有大量图片和GIf图片的时候，APP内存占用会暴增，有被系统杀掉的风险。但是在单纯的使用WebView的时候内存占用不会那么大，WebView会根据自身视口的大小动态渲染HTML内容，不会一次性的渲染素有的HTML内容。这个方案只是简单的将WebView的大小更新为HTML的实际大小，WebView将会一次性的渲染所有的HTML内容，因此直接使用这种方案会有内存占用暴增的风险。</p>\n"
    "</body></html></body></html> \n";
    
    self.html = html;
}
- (void)loadTableDatas {
    if (!self.datas) {
        self.datas = [NSMutableArray array];
    }
    for (int i = 0; i < 20; i++) {
        [self.datas addObject:[NSString stringWithFormat:@" TableCell - %d", i]];
    }
}
- (void)updateWebWithOffsetY:(CGFloat)offsetY {
    if (self.webViewMaxContentOffset - offsetY >= 0) {
        [self.webView.scrollView setContentOffset:CGPointMake(0, offsetY)];
        
        CGRect frame = self.webView.frame;
        frame.origin.y = offsetY;
        self.webView.frame = frame;
    }
    else {
        [self.webView.scrollView setContentOffset:CGPointMake(0, self.webViewMaxContentOffset)];
        
        CGRect frame = self.webView.frame;
        frame.origin.y = self.webViewMaxContentOffset;
        self.webView.frame = frame;
    }
}
- (void)updateTableWithOffsetY:(CGFloat)offsetY {
    if (self.tableViewContentHeight != self.tableView.contentSize.height) {
        self.tableViewContentHeight = self.tableView.contentSize.height;
        
        CGRect bounds = self.containerView.bounds;
        self.containerView.contentSize = CGSizeMake(bounds.size.width, self.webViewContentHeight + gap_web_table + self.tableViewContentHeight);
        self.containerViewContentHeight = _containerView.contentSize.height;
        self.tableViewMaxOriginY = (self.webViewContentHeight + gap_web_table + (self.tableView.contentSize.height - self.tableViewHeight));
    }
    
    if (offsetY - (self.webViewContentHeight + gap_web_table) >= 0) {
        if (offsetY >= self.tableViewMaxOriginY) {
            [self.tableView setContentOffset:CGPointMake(0, (self.tableView.contentSize.height - self.tableViewHeight))];
            
            CGRect frame = self.tableView.frame;
            if (frame.origin.y - self.tableViewMaxOriginY < 0) {
                frame.origin.y = self.tableViewMaxOriginY;
                self.tableView.frame = frame;
            }
        }
        else {
            CGRect frame = self.tableView.frame;
            frame.origin.y = offsetY;
            self.tableView.frame = frame;
            
            CGFloat tableOffsetY = offsetY - (self.webViewContentHeight + gap_web_table);
            [self.tableView setContentOffset:CGPointMake(0, tableOffsetY)];
        }
    }
    else {
        CGRect frame = self.tableView.frame;
        frame.origin.y = self.webViewContentHeight + gap_web_table;
        self.tableView.frame = frame;
        
        [self.tableView setContentOffset:CGPointMake(0, 0)];
    }
}
- (void)tapAction {
    NSLog(@"%s",__func__);
}
- (void)addImageClickEventForWebview {
    static NSString *jsSource;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jsSource = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ImageClickEvent" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    });
    
    // 添加自定义的脚本:
    WKUserScript *imgAddClickEventJS = [[WKUserScript alloc] initWithSource:jsSource injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    [self.webView.configuration.userContentController addUserScript:imgAddClickEventJS];
    
    // 注册回调:
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"imageDidClick"];
}
- (void)addImageLongpressEventForWebview {
    static NSString *jsSource;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jsSource = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ImageLongPressEvent" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    });
    
    // 添加自定义的脚本:
    WKUserScript *imgAddClickEventJS = [[WKUserScript alloc] initWithSource:jsSource injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    [self.webView.configuration.userContentController addUserScript:imgAddClickEventJS];
    
    // 注册回调:
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"imageDidLongpress"];
}


#pragma mark - WKNavigationDelegate -
// 开始加载，对应UIWebView的- (void)webViewDidStartLoad:(UIWebView *)webView;
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@" didStartProvisionalNavigation");
}
// 加载成功，对应UIWebView的- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@" didFinishNavigation");
    
    /**
     注释掉webkit默认的Select事件
     */
    [self.webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:nil];
    [self.webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
}
// 加载失败，对应UIWebView的- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@" didFailNavigation");
}
// 先针对一次action来决定是否允许跳转，action中可以获取request，允许与否都需要调用decisionHandler;
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *requestString = [[navigationAction.request URL] absoluteString];
    NSLog(@" requestString : %@",requestString);
    
    decisionHandler(WKNavigationActionPolicyAllow);
}
// 后根据response来决定，是否允许跳转，允许与否都需要调用decisionHandler;
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}


#pragma mark - UITableView DataSource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"WeiboDetail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(UIWidth-13-100, 12, 90, 36);
        button.backgroundColor = [UIColor lightGrayColor];
        [button.titleLabel setTextColor:[UIColor orangeColor]];
        [button setTitle:@"TapAction" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.datas objectAtIndex:indexPath.row]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@" didSelectRowAtIndexPath : %ld",indexPath.row);
}


#pragma mark - UIScrollView Delegate -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY <= 0 && scrollView == self.containerView) {
        [self updateWebWithOffsetY:0];
        return;
    }
    else if (scrollView == self.webView.scrollView || scrollView == self.tableView) {
        return;
    }

    [self updateWebWithOffsetY:offsetY];
    [self updateTableWithOffsetY:offsetY];
}


#pragma mark - observe -
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        [self.progressView setProgress:newprogress animated:YES];
        if (newprogress - 1 == 0.) {
            self.progressView.hidden = YES;
        }
    }
    else if (object == self.webView.scrollView && [keyPath isEqualToString:@"contentSize"]) {
        if (!self.tableView.superview) {
            [self.containerView addSubview:self.tableView];
            self.tableViewContentHeight = self.tableView.contentSize.height;
        }
        
        if (self.webViewContentHeight - self.webView.scrollView.contentSize.height == 0) {
            return;
        }
        self.webViewContentHeight = self.webView.scrollView.contentSize.height;
        
        CGRect webViewRect = self.webView.frame;
        if (webViewRect.size.height - self.webViewContentHeight > 0) {
            webViewRect.size.height = self.webViewContentHeight;
            self.webView.frame = webViewRect;
        }
        
        CGRect bounds = self.containerView.bounds;
        _containerView.contentSize = CGSizeMake(bounds.size.width, self.webView.scrollView.contentSize.height + gap_web_table + self.tableView.contentSize.height);
        
        self.containerViewContentHeight = _containerView.contentSize.height;
        self.webViewMaxContentOffset = self.webViewContentHeight - self.webViewHeight;
        self.tableViewMaxOriginY = (self.webViewContentHeight + gap_web_table + (self.tableView.contentSize.height - self.tableViewHeight));
    }
}


#pragma mark - UIGestureRecognizer Delegate -
/**
 让ScrollView响应多手势
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


#pragma mark - WKScriptMessageHandler Delegate -
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"imageDidClick"]) {
        NSDictionary *dic = message.body;
        
        NSString *selectedImageUrl = dic[@"imgUrl"];
        CGFloat x = [dic[@"x"] floatValue] + self.webView.scrollView.contentInset.left;
        CGFloat y = [dic[@"y"] floatValue] + self.webView.scrollView.contentInset.top;
        CGFloat width = [dic[@"width"] floatValue];
        CGFloat height = [dic[@"height"] floatValue];
        CGRect frame = CGRectMake(x, y, width, height);
        NSUInteger index = [dic[@"index"] integerValue];
        NSLog(@"\n 点击了第'%@'张图片;\n link: %@;\n frame: %@;", @(index), selectedImageUrl, NSStringFromCGRect(frame));
    }
    else if ([message.name isEqualToString:@"imageDidLongpress"]) {
        NSDictionary *dic = message.body;
        NSLog(@"Longpress-dic: %@",dic);
    }
}


#pragma mark - Property -
- (UIScrollView *)containerView {
    if (!_containerView) {
        self.containerViewHeight = UIHeight - NavigationBarHeight;
        _containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NavigationBarHeight, UIWidth, self.containerViewHeight)];
        _containerView.backgroundColor = [UIColor colorWithRed:236/255. green:236/255. blue:236/255. alpha:1];
        _containerView.delegate = self;
    }
    return _containerView;
}
- (WKWebView *)webView {
    if (!_webView) {
        CGRect bounds = self.containerView.bounds;
        self.webViewHeight = bounds.size.height;
        _webView = [[WKWebView alloc] initWithFrame:bounds];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.scrollView.scrollEnabled = NO;
        [_webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _webView;
}
- (UITableView *)tableView {
    if (!_tableView) {
        CGRect webViewRect = self.webView.frame;
        CGRect bounds = self.containerView.bounds;
        self.tableViewHeight = bounds.size.height;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, webViewRect.origin.y + webViewRect.size.height + gap_web_table, bounds.size.width, self.tableViewHeight) style:UITableViewStylePlain];
        // _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.scrollEnabled = NO;
    }
    
    return _tableView;
}
- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, NavigationBarHeight, [UIScreen mainScreen].bounds.size.width, 1)];
        _progressView.tintColor = [UIColor orangeColor];
        _progressView.trackTintColor = [UIColor whiteColor];
    }
    
    return _progressView;
}

@end
