//
//  ImageBrowserViewController.h
//  uicollectionview图片浏览器
//
//  Created by 张飞 on 2018/10/24.
//  Copyright © 2018 张飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageBrowserDataSource.h"
NS_ASSUME_NONNULL_BEGIN

@interface ImageBrowserViewController : UIViewController

@property (nonatomic,weak) id<ImageBrowserDataSource> dataSource;

/**
 图片浏览视图 UICollectionView
 */
@property (nonatomic,weak,readonly) UICollectionView *imageBrowserView;

/**
 当前 page
 */
@property (nonatomic,assign,readonly) NSInteger currentIndex;

@end

NS_ASSUME_NONNULL_END
