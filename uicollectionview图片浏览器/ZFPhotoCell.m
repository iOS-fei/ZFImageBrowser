//
//  ZFPhotoCell.m
//  uicollectionview图片浏览器
//
//  Created by 张飞 on 2018/9/20.
//  Copyright © 2018年 张飞. All rights reserved.
//

#import "ZFPhotoCell.h"
#import "UtilsMacros.h"

@interface ZFPhotoCell ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,weak) UIScrollView *mainContentView;
@property (nonatomic,assign) CGPoint gestureInteractionStartPoint;
@property (nonatomic,assign) CGSize containerSize;
@property (nonatomic,assign) BOOL isGestureInteraction;
@property (nonatomic,assign) BOOL isZooming;

@end

@implementation ZFPhotoCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView* imageView = [UIImageView new];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.userInteractionEnabled =  YES;
        self.imageView = imageView;
        [self.mainContentView addSubview:self.imageView];
        [self addGesture];
    }
    return self;
}

-(void)prepareForReuse
{
    self.mainContentView.zoomScale = 1;
    [super prepareForReuse];
}

/**
 添加手势
 */
- (void)addGesture
{
    UITapGestureRecognizer *tapSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSingle:)];
    tapSingle.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tapDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDouble:)];
    tapDouble.numberOfTapsRequired = 2;
    [tapSingle requireGestureRecognizerToFail:tapDouble];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.maximumNumberOfTouches = 1;
    pan.delegate = self;
    
    [self.mainContentView addGestureRecognizer:tapSingle];
    [self.mainContentView addGestureRecognizer:tapDouble];
    [self.imageView addGestureRecognizer:pan];
}

- (CGRect)getCurrentImageViewFrame
{
    return self.private_didEndZoomingImageViewFrame;
}

#pragma mark - GestureRecognizer Selector

- (void)tapSingle:(UITapGestureRecognizer *)tap
{
    if(self.mainContentView.zoomScale>1)
    {
        CGRect zoomRect = [self zoomRectForScale:1 withCenter:[tap locationInView:tap.view]];
        [self.mainContentView zoomToRect:zoomRect animated:YES];
    }
    else
    {
        //这里返回dismiss回调
        if (self.dismissBlock) {
            self.dismissBlock();
        }
    }
}

- (void)tapDouble:(UITapGestureRecognizer *)tap
{
    CGFloat newScale;
    if(self.mainContentView.zoomScale>1){
        newScale=1.0;
    }else{
        newScale=2.0;
    }
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[tap locationInView:tap.view]];
    [self.mainContentView zoomToRect:zoomRect animated:YES];
}

- (void)pan:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:self];
//    NSLog(@"---------=========");
    
    if (pan.state == UIGestureRecognizerStateBegan) {

        self->_gestureInteractionStartPoint = point;

    }
    else if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateRecognized || pan.state == UIGestureRecognizerStateFailed)
    {

        if (self->_isGestureInteraction) {
            CGPoint velocity = [pan velocityInView:self.mainContentView];

            BOOL velocityArrive = ABS(velocity.y) > 800;
            BOOL distanceArrive = ABS(point.y - self->_gestureInteractionStartPoint.y) > self.containerSize.height * 0.22;

            BOOL shouldDismiss = distanceArrive || velocityArrive;
            if (shouldDismiss) {
               //这里返回dismiss回调
                if (self.dismissBlock) {
                    self.dismissBlock();
                }
            } else {
                NSLog(@"到底会不会到这里？？？");
                [self restoreGestureInteractionWithDuration:0.15];
                [self private_collectionViewScrollEnabled:YES];
            }
        }

    }
    else if (pan.state == UIGestureRecognizerStateChanged)
    {
        CGPoint velocity = [pan velocityInView:self.mainContentView];
        CGFloat triggerDistance = 3;

        BOOL startPointValid = !CGPointEqualToPoint(self->_gestureInteractionStartPoint, CGPointZero);
        BOOL distanceArrive = ABS(point.x - self->_gestureInteractionStartPoint.x) < triggerDistance && ABS(velocity.x) < 500;
        NSLog(@"velocity.x = : %.2f",velocity.x);

        BOOL upArrive = point.y - self->_gestureInteractionStartPoint.y > triggerDistance && self.mainContentView.contentOffset.y <= 1,
        downArrive = point.y - self->_gestureInteractionStartPoint.y < -triggerDistance && self.mainContentView.contentOffset.y + self.mainContentView.bounds.size.height >= MAX(self.mainContentView.contentSize.height, self.mainContentView.bounds.size.height) - 1;

        BOOL shouldStart = startPointValid && !self->_isGestureInteraction && (upArrive || downArrive) && distanceArrive && !self->_isZooming;

        // START
        if (shouldStart) {
            self->_gestureInteractionStartPoint = point;
            CGRect startFrame = self.mainContentView.frame;
            CGFloat anchorX = point.x / startFrame.size.width,
            anchorY = point.y / startFrame.size.height;
            self.mainContentView.layer.anchorPoint = CGPointMake(anchorX, anchorY);
            self.mainContentView.userInteractionEnabled = NO;
            self.mainContentView.scrollEnabled = NO;
            self->_isGestureInteraction = YES;
        }

        // CHNAGE
        if (self->_isGestureInteraction) {
            
            [self private_collectionViewScrollEnabled:NO];
            
            self.mainContentView.center = point;

            CGFloat scale = 1 - ABS(point.y - self->_gestureInteractionStartPoint.y) / (self.containerSize.height * 1.2);
            if (scale > 1) scale = 1;
            if (scale < 0.35) scale = 0.35;
            self.mainContentView.transform = CGAffineTransformMakeScale(scale, scale);
            CGFloat alpha = 1 - ABS(point.y - self->_gestureInteractionStartPoint.y) / (self.containerSize.height * 1.1);
            if (self.changeAlphaBlock) {
                self.changeAlphaBlock(alpha);
            }
            if (alpha > 1) alpha = 1;
            if (alpha < 0) alpha = 0;
        }

    }
}


- (void)restoreGestureInteractionWithDuration:(NSTimeInterval)duration {
    
    void (^animations)(void) = ^{
        self.mainContentView.transform = CGAffineTransformIdentity;
        self.mainContentView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        self.imageView.frame = [self private_enterFrameWithImageSize:self.containerSize];
    };
    void (^completion)(BOOL finished) = ^(BOOL finished){
        self.mainContentView.userInteractionEnabled = YES;
        self.mainContentView.scrollEnabled = YES;
        
        self->_gestureInteractionStartPoint = CGPointZero;
        self->_isGestureInteraction = NO;
    };
    if (duration <= 0) {
        animations();
        completion(NO);
    } else {
        [UIView animateWithDuration:duration animations:animations completion:completion];
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = self.mainContentView.frame.size.height / scale;
    zoomRect.size.width  = self.mainContentView.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  /2);
    zoomRect.origin.y = center.y - (zoomRect.size.height /2);
    return zoomRect;
}


- (void)setUpZFPhotoCellWithImage:(UIImage *)image
{
    self.imageView.frame = [self private_enterFrameWithImageSize:CGSizeMake(image.size.width, image.size.height)];
    self.imageView.image = image;
    self.containerSize = [self private_enterFrameWithImageSize:CGSizeMake(self.imageView.image.size.width, self.imageView.image.size.height)].size;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    //目前contentsize的width是否大于原scrollview的contentsize，如果大于，设置imageview中心x点为contentsize的一半，以固定imageview在该contentsize中心。如果不大于说明图像的宽还没有超出屏幕范围，可继续让中心x点为屏幕中点，此种情况确保图像在屏幕中心。
    
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    
    [self.imageView setCenter:CGPointMake(xcenter, ycenter)];
    
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    self->_isZooming = NO;
    [scrollView setZoomScale:scale animated:NO];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self->_isZooming = YES;
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

- (CGRect)private_didEndZoomingImageViewFrame
{
    CGFloat x = self.mainContentView.frame.origin.x, y = 0, width = 0, height = 0;
    CGSize containerSize = self.mainContentView.frame.size;
    width = containerSize.width;
    height = containerSize.width * (self.containerSize.height / self.containerSize.width);
    if (self.containerSize.width / self.containerSize.height >= containerSize.width / containerSize.height)
    y = (containerSize.height - height) / 2.0 + self.mainContentView.frame.origin.y;//图片居中显示
    else
    y = self.mainContentView.frame.origin.y;
    return CGRectMake(x, y, width, height);
}

- (void)private_collectionViewScrollEnabled:(BOOL)enable
{
    //拿到父视图，禁止左右滑动
    UIView *superView = self;
    while (![superView isKindOfClass:[UICollectionView class]]) {
        superView = superView.superview;
    }
    UICollectionView *collectionView = (UICollectionView *)superView;
    collectionView.scrollEnabled = enable;
}

-(UIScrollView *)mainContentView
{
    if (!_mainContentView) {
        UIScrollView *mainContentView = [UIScrollView new];
        mainContentView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        mainContentView.backgroundColor = [UIColor clearColor];
        mainContentView.delegate = self;
        mainContentView.showsHorizontalScrollIndicator = NO;
        mainContentView.showsVerticalScrollIndicator = NO;
        mainContentView.decelerationRate = UIScrollViewDecelerationRateFast;
        mainContentView.maximumZoomScale = 2;
        mainContentView.minimumZoomScale = 1;
        mainContentView.alwaysBounceHorizontal = NO;
        mainContentView.alwaysBounceVertical = NO;
        mainContentView.layer.masksToBounds = NO;
        if (@available(iOS 11.0, *)) mainContentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [self.contentView addSubview:mainContentView];
        _mainContentView = mainContentView;
    }
    return _mainContentView;
}

-(void)setImageView:(UIImageView *)imageView
{
    _imageView = imageView;
}


//-(void)dealloc
//{
//    NSLog(@"%s",__func__);
//}

@end
