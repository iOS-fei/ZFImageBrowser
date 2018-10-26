//
//  ImageBrowserDataSource.h
//  uicollectionview图片浏览器
//
//  Created by 张飞 on 2018/10/24.
//  Copyright © 2018 张飞. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ImageBrowserDataSource <NSObject>

@required

- (NSInteger)totalImageCount;
- (NSInteger)currentIndex;
- (UIImage *)imageBrowserViewWithIndex:(NSInteger)index;
//返回每一index对应的rect,方便dimiss确认最终的位置
- (CGRect)dismissAnimatedImageFrameWithIndex:(NSInteger)index;
@optional
@end

NS_ASSUME_NONNULL_END
