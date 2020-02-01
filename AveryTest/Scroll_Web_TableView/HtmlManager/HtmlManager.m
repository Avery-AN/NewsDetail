//
//  HtmlManager.m
//  Avery
//
//  Created by Avery on 2018/11/8.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "HtmlManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIImageView+WebCache.h>

static NSString *regexString_image = @"<img\\b[^<>]*?\\bsrc[\\s\\t\\r\\n]*=[\\s\\t\\r\\n]*[""']?[\\s\\t\\r\\n]*(?<imgUrl>[^\\s\\t\\r\\n""'<>]*)[^<>]*?/?[\\s\\t\\r\\n]*>";

@interface HtmlManager ()
@property (nonatomic) NSMutableArray *updateImagesJS;
@property (nonatomic, unsafe_unretained) WKWebView *webView;
@end

@implementation HtmlManager

#pragma mark - Life Cycle -
- (void)dealloc {
    NSLog(@"%s",__func__);
}


#pragma mark - Publiac Api -
- (void)processImagesInHtml:(NSString *)html_
                    webView:(WKWebView *)webView
                 completion:(ProcessImagesCompletion)completion {
    self.webView = webView;
    __block NSString *html = html_;
    NSMutableArray *allUrls = [NSMutableArray arrayWithCapacity:0];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            __autoreleasing NSMutableDictionary *urlDicts = [NSMutableDictionary dictionary];
            NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
            
            /**
             // 获取沙盒主目录路径:
             NSString *homeDir = NSHomeDirectory();
             // 获取Documents目录路径:
             NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
             // 获取Library的目录路径:
             NSString *libDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
             // 获取Caches目录路径:
             NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
             // 获取tmp目录路径:
             NSString *tmpDir = NSTemporaryDirectory();
             */
            
            // 匹配image标签的正则表达式:
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString_image options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
            NSArray *result = [regex matchesInString:html_ options:NSMatchingReportCompletion range:NSMakeRange(0, html_.length)];
            for (NSTextCheckingResult *item in result) {
                NSString *imageHtml = [html_ substringWithRange:item.range];
                // NSLog(@"imageHtml: %@",imageHtml);
                NSRange range = [imageHtml rangeOfString:@"http"];
                NSString *imageUrlString = [imageHtml substringFromIndex:range.location];
                range = [imageUrlString rangeOfString:@"\" />"];
                if (range.location != NSNotFound) {
                    imageUrlString = [imageUrlString substringToIndex:range.location];
                }
                else {
                    range = [imageUrlString rangeOfString:@"\"/>"];
                    imageUrlString = [imageUrlString substringToIndex:range.location];
                }
                // NSLog(@"imageUrlString: %@",imageUrlString);
                
                if (imageUrlString.length > 0) {
                    // 先将链接取个本地名字,且获取完整路径:
                    NSString *localPath = [cachesDir stringByAppendingPathComponent:[self md5:imageUrlString]];
                    [urlDicts setObject:localPath forKey:imageUrlString];
                    [allUrls addObject:imageUrlString];
                }
            }
            
            // 添加监听:
            [webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew |  NSKeyValueObservingOptionOld context:NULL];
            
            // 遍历所有的URL,替换成本地的URL,并异步获取图片:
            for (int i = 0; i < allUrls.count; i++) {
                NSString *imageUrlString = [allUrls objectAtIndex:i];
                NSString *localPath = [urlDicts objectForKey:imageUrlString];
                
                // 如果已经缓存过,就不需要重复加载了:
                if (![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
                    // 全部替换为默认图片
                    UIImage *defaultImage = [UIImage imageNamed:@"默认图"];  // 默认图片
                    NSString *imageSource = [self htmlForJPGImage:defaultImage];
                    html = [html stringByReplacingOccurrencesOfString:imageUrlString withString:imageSource]; // 全局替换imageUrlString
                    
                    // 异步下载:
                    [self downloadImageWithUrl:imageUrlString completion:^(UIImage * _Nonnull image) {
                        if (image) {
                            NSString *imageSource = [self htmlForJPGImage:image]; // 把图片进行base64编码
                            html = [html stringByReplacingOccurrencesOfString:localPath withString:imageSource]; // 全局替换imageUrlString
                            NSInteger position = [allUrls indexOfObject:imageUrlString];
                            NSString *updateImageJS = [NSString stringWithFormat:@"document.images[%ld].src='%@'", position, imageSource];
                            
                            if (webView && webView.estimatedProgress - 1 == 0) {
                                // 需要webView完成FinishLoad之后才可以调用该方法:
                                [webView evaluateJavaScript:updateImageJS completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                                    // NSLog(@"webView response: %@ error: %@", response, error);
                                }];
                            }
                            else {
                                if (!self.updateImagesJS) {
                                    self.updateImagesJS = [NSMutableArray arrayWithCapacity:0];
                                }
                                [self.updateImagesJS addObject:[NSDictionary dictionaryWithObjectsAndKeys:updateImageJS, @"updateImagesJS", nil]];
                            }
                        }
                        else {
                            /*
                             在这里显示加载失败的image
                             */
                        }
                    }];
                }
                else {
                    UIImage *_image = [UIImage imageWithContentsOfFile:localPath]; // 根据本地路径获取图片
                    NSString *imageSource = [self htmlForJPGImage:_image];  // 把图片进行base64编码
                    html = [html stringByReplacingOccurrencesOfString:localPath withString:imageSource]; // 全局替换imageUrlString
                }
            }
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(html, allUrls);
            });
        }
    });
}

- (NSString *)appendLocalCssStytle:(NSString *)html_ {
    NSString *gap_top_bottom = @"0px";      // 上下间隔
    NSString *gap_left_right = @"13px";     // 左右间隔
    NSString *gap_letter = @"2px";          // 字间距
    NSString *lineHeight = @"26px";         // 行高
    CGFloat fontSize = 16;                  // 字号
    
    // "text-justify:inter-ideograph;" 两端对齐
    NSString *html = [NSString stringWithFormat:@"<html> \n"
                      "<head> \n"                         // html头部标签
                      "<style type=\"text/css\"> \n"      // css内部样式的写法
                      "body {margin:%@ %@; font-size:%f; letter-spacing:%@; line-height:%@; text-align:justify; text-justify:inter-ideograph; word-wrap:break-word; word-break:normal;} \n" // css里面的标签选择器
                      "</style> \n"
                      "</head> \n"
                      "<body>"
                      "<script type='text/javascript'> \n"
                      "window.onload = function(){ \n"
                      "var $img = document.getElementsByTagName('img'); \n"
                      "for(var p in  $img){ \n"
                      "$img[p].style.width = '100%%'; \n"
                      "$img[p].style.height ='auto' \n"
                      "} \n"
                      "} \n"
                      "</script> \n"
                      "%@"
                      "</body>"
                      "</html>", gap_top_bottom, gap_left_right, fontSize, gap_letter, lineHeight, html_];
    return html;
}

- (NSString *)appendRemoteCssStytle:(NSString *)html_ css:(NSString *)cssUrlString {
    NSString *html = [NSString stringWithFormat:@"<html> \n"
                      "<body> \n"
                      "<script type='text/javascript'> \n"
                      "window.onload = function(){ \n"
                      "var $img = document.getElementsByTagName('img'); \n"
                      "for(var p in  $img) { \n"
                      "$img[p].style.width = '100%%'; \n"
                      "$img[p].style.height ='auto' \n"
                      "} \n"
                      "} \n"
                      "</script> \n"
                      "%@"
                      "</body>"
                      "</html>", html_];
    
    // 处理css:
    NSString *richTxt_css = cssUrlString;
    NSString *css = [NSString stringWithFormat:@"<link href=\"%@\" type=\"text/css\" rel=\"stylesheet\">",richTxt_css];
    html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">%@</head> <body><div class=\"appview\">%@</div><body></html>", css, html];
    
    return html;
}


#pragma mark - Private Methods -
- (NSString *)md5:(NSString *)sourceContent {
    if (!sourceContent || [sourceContent length] == 0) {
        return nil;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([sourceContent UTF8String], (int)[sourceContent lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    NSMutableString *ms = [NSMutableString string];
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x", (int)(digest[i])];
    }
    
    return [ms copy];
}
- (void)downloadImageWithUrl:(NSString *)imageUrlString
                  completion:(void (^ _Nonnull)(UIImage * _Nonnull image))completionBlock {
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageUrlString]
                                                          options:SDWebImageDownloaderLowPriority
                                                         progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                             
                                                         } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                                                             UIImage *completionImage = image;
                                                             if (!error) {
                                                                 [self saveImage:image imagePath:imageUrlString];
                                                             }
                                                             else {
                                                                 // NSLog(@"   下载图片失败: %@",imageUrlString);
                                                             }
                                                             
                                                             if (completionBlock) {
                                                                 completionBlock(completionImage);
                                                             }
                                                         }];
}

- (void)saveImage:(UIImage *)image imagePath:(NSString *)imagePath {
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *localPath = [cachesDir stringByAppendingPathComponent:[self md5:imagePath]];
    
    if ([imageData writeToFile:localPath atomically:NO]) {
        NSLog(@"   图片保存到本地成功: %@", localPath);
    }
    else {
        NSLog(@"   图片保存到本地失败: %@", imagePath);
    }
}

- (NSString *)htmlForJPGImage:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSString *imageSource = [NSString stringWithFormat:@"data:image/jpg;base64,%@",[imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]];
    
    return imageSource;
}


#pragma mark - Observe -
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]) {
        float estimatedProgress = [[change valueForKey:NSKeyValueChangeNewKey] floatValue];
        // NSLog(@"estimatedProgress: %f",estimatedProgress);
        if (estimatedProgress - 1 == 0) {
            for (NSDictionary *dic in self.updateImagesJS) {
                NSString *strJS = [dic valueForKey:@"updateImagesJS"];
                if (self.webView) {
                    [self.webView evaluateJavaScript:strJS completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                        // NSLog(@"webView response: %@ error: %@", response, error);
                    }];
                }
            }
        }
    }
}

@end
