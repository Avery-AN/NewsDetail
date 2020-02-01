//
//  HtmlManager.h
//  Avery
//
//  Created by Avery on 2018/11/8.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

typedef void (^DownloadCompletion) (UIImage * _Nullable _image);
typedef void (^ProcessImagesCompletion) (NSString * _Nullable _html, NSArray * _Nullable imageUrls);

NS_ASSUME_NONNULL_BEGIN

@interface HtmlManager : NSObject

- (void)processImagesInHtml:(NSString *)html_
                    webView:(WKWebView *)webView
                 completion:(ProcessImagesCompletion)completion;

- (NSString *)appendLocalCssStytle:(NSString *)html_;

- (NSString *)appendRemoteCssStytle:(NSString *)html_
                                css:(NSString *)cssUrlString;

@end

NS_ASSUME_NONNULL_END
