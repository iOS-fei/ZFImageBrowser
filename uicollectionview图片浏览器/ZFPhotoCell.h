//
//  ZFPhotoCell.h
//  uicollectionview图片浏览器
//
//  Created by 张飞 on 2018/9/20.
//  Copyright © 2018年 张飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DismissBlock)(void);
typedef void(^ChangeAlphaBlock)(CGFloat alpha);
@interface ZFPhotoCell : UICollectionViewCell

@property (nonatomic,copy) DismissBlock dismissBlock;
@property (nonatomic,copy) ChangeAlphaBlock changeAlphaBlock;
@property (nonatomic,weak,readonly) UIImageView *imageView;

- (void)setUpZFPhotoCellWithImage:(UIImage *)image;

/**
 获取当前图片视图的frame

 @return CGRect:frame
 */
- (CGRect)getCurrentImageViewFrame;

@end
