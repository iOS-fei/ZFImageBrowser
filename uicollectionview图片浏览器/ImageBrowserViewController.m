//
//  ImageBrowserViewController.m
//  uicollectionview图片浏览器
//
//  Created by 张飞 on 2018/10/24.
//  Copyright © 2018 张飞. All rights reserved.
//

#import "ImageBrowserViewController.h"
#import "UtilsMacros.h"
#import "ZFPhotoCell.h"

static NSString *const identifier = @"identifier";
static CGFloat const kSpacing = 10.0;


@interface ImageBrowserViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) UILabel *pageTipLabel;

@end

@implementation ImageBrowserViewController

@synthesize imageBrowserView = _imageBrowserView;

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(totalImageCount)]) {
        NSUInteger total = [self.dataSource totalImageCount];
        NSLog(@"total : %zd",total);
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(currentIndex)]) {
        self.currentIndex = [self.dataSource currentIndex];
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.imageBrowserView registerClass:[ZFPhotoCell class] forCellWithReuseIdentifier:identifier];    
     [self.imageBrowserView setContentOffset:CGPointMake((kSpacing*2 +KScreenWidth)*[self.dataSource currentIndex], 0)];
    self.pageTipLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.currentIndex+1,[self.dataSource totalImageCount]];
}

#pragma mark - UICollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource totalImageCount];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    ZFPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.changeAlphaBlock = ^(CGFloat alpha) {
        weakSelf.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];
    };
    cell.dismissBlock = ^{
        [weakSelf dismissViewControllerAnimated:YES completion:NULL];
    };
    UIImage *img = [self.dataSource imageBrowserViewWithIndex:indexPath.item];
    [cell setUpZFPhotoCellWithImage:img];
    return cell;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 计算最后的索引
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.currentIndex = index;
    self.pageTipLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.currentIndex+1,[self.dataSource totalImageCount]];
//    NSLog(@"%.2f",scrollView.contentOffset.x);
}


#pragma mark - getter
-(UICollectionView *)imageBrowserView
{
    if (!_imageBrowserView) {
        UICollectionView *imageBrowserView = [[UICollectionView alloc] initWithFrame:CGRectMake(-kSpacing, 0,KScreenWidth+2 * kSpacing, KScreenHeight) collectionViewLayout:self.flowLayout];
        imageBrowserView.backgroundColor = [UIColor clearColor];
        imageBrowserView.showsHorizontalScrollIndicator = NO;
        imageBrowserView.showsVerticalScrollIndicator = NO;
        imageBrowserView.alwaysBounceVertical = NO;
        imageBrowserView.alwaysBounceHorizontal = NO;
        imageBrowserView.pagingEnabled = YES;
        imageBrowserView.delegate = self;
        imageBrowserView.dataSource = self;
        [self.view addSubview:imageBrowserView];
        _imageBrowserView = imageBrowserView;
    }
    return _imageBrowserView;
}

-(UICollectionViewFlowLayout *)flowLayout
{
    if (_flowLayout == nil)
    {
        _flowLayout = [[UICollectionViewFlowLayout alloc]init];
        
        //设置每个图片的大小
        _flowLayout.itemSize = CGSizeMake(KScreenWidth, KScreenHeight);
        //设置滚动方向的间距
        
        _flowLayout.minimumLineSpacing = 2 * kSpacing;
        //        //设置上方的反方向
        _flowLayout.minimumInteritemSpacing = 0;
        //设置collectionView整体的上下左右之间的间距
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, kSpacing, 0, kSpacing);
        //设置滚动方向
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //设置header大小
        _flowLayout.headerReferenceSize = CGSizeMake(0, 0);
    }
    return _flowLayout;
}

-(UILabel *)pageTipLabel
{
    if (!_pageTipLabel) {
        
        UILabel *pageTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
        pageTipLabel.textColor = [UIColor whiteColor];
        pageTipLabel.font = [UIFont systemFontOfSize:16.f];
        pageTipLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:pageTipLabel];
        _pageTipLabel = pageTipLabel;
    }
    return _pageTipLabel;
}

-(void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
}

-(void)dealloc
{
    NSLog(@"%s",__func__);
}


@end
