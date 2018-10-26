//
//  CustomPresentationController.m
//  uicollectionview图片浏览器
//
//  Created by 张飞 on 2018/10/24.
//  Copyright © 2018 张飞. All rights reserved.
//

#import "CustomPresentationController.h"
#import "ImageBrowserViewController.h"
#import "ZFPhotoCell.h"
@interface CustomPresentationController ()<UIViewControllerAnimatedTransitioning>
@property (nonatomic, strong) UIImageView *animateImageView;
@end


@implementation CustomPresentationController
- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(nullable UIViewController *)presentingViewController
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return [transitionContext isAnimated]?0.4:0;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = transitionContext.containerView;
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromController.view;
    UIView *toView = toController.view;
    
    //Enter
    if (toController.isBeingPresented) {
        [containerView addSubview:toView];
        
        ImageBrowserViewController *imageBrowserVC = (ImageBrowserViewController *)toController;
        UIImage *img = [imageBrowserVC.dataSource imageBrowserViewWithIndex:imageBrowserVC.currentIndex];        
        self.animateImageView.frame = [imageBrowserVC.dataSource dismissAnimatedImageFrameWithIndex:imageBrowserVC.currentIndex];
        self.animateImageView.image = img;
        [containerView addSubview:self.animateImageView];
        toView.alpha = 0;
        CGSize imgSize = CGSizeMake(img.size.width, img.size.height);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toView.alpha = 1;
            self.animateImageView.frame = [self private_enterFrameWithImageSize:imgSize];
            
        } completion:^(BOOL finished) {
            if (finished) {
                [self.animateImageView removeFromSuperview];
                BOOL wasCancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!wasCancelled];
            }
            
        }];
    }
    
    //Out
    if (fromController.isBeingDismissed) {
         ImageBrowserViewController *imageBrowserVC = (ImageBrowserViewController *)fromController;
        ZFPhotoCell *cell = (ZFPhotoCell *)[imageBrowserVC.imageBrowserView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:imageBrowserVC.currentIndex inSection:0]];
        cell.imageView.hidden = YES;
        self.animateImageView.image = cell.imageView.image;
        [containerView addSubview:self.animateImageView];
        self.animateImageView.frame = [cell getCurrentImageViewFrame];
        CGRect toFrame = [imageBrowserVC.dataSource dismissAnimatedImageFrameWithIndex:imageBrowserVC.currentIndex];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            self.animateImageView.frame = toFrame;
            fromView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        } completion:^(BOOL finished) {
            if (finished) {
                [self.animateImageView removeFromSuperview];
                BOOL wasCancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!wasCancelled];
            }
        }];
    }
}


#pragma mark - UIViewControllerTransitioningDelegate
- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source NS_AVAILABLE_IOS(8_0)
{
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

#pragma mark - private
- (CGRect)private_enterFrameWithImageSize:(CGSize)imageSize
{
    CGFloat x = 0, y = 0, width = 0, height = 0;
    CGSize containerSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    width = containerSize.width;
    height = containerSize.width * (imageSize.height / imageSize.width);
    if (imageSize.width / imageSize.height >= containerSize.width / containerSize.height)
    y = (containerSize.height - height) / 2.0;//图片居中显示
    else
    y = 0;
    return CGRectMake(x, y, width, height);
}

#pragma mark - lazy
- (UIImageView *)animateImageView {
    if (!_animateImageView) {
        _animateImageView = [UIImageView new];
    }
    return _animateImageView;
}


@end
