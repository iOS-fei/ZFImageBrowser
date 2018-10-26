//
//  ViewController.m
//  uicollectionview图片浏览器
//
//  Created by 张飞 on 2018/9/20.
//  Copyright © 2018年 张飞. All rights reserved.
//

#import "ViewController.h"
#import "ImageBrowserDataSource.h"
#import "ImageBrowserViewController.h"
#import "CustomPresentationController.h"
@interface ViewController ()<ImageBrowserDataSource>

@property (nonatomic,strong) NSMutableArray *imgArr;
@property (nonatomic,assign) NSUInteger currentIdx;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"图片浏览";
    self.imgArr = [NSMutableArray array];
    self.currentIdx = 0;
    for (int i = 1; i < 5; i++) {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i]];
        [self.imgArr addObject:img];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
        imgView.frame = CGRectMake(0, 105*i, 100 , 100);
        imgView.tag = i;
        imgView.userInteractionEnabled = YES;
        [self.view addSubview:imgView];
        
        UITapGestureRecognizer *tapSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSingle:)];
        tapSingle.numberOfTapsRequired = 1;
        [imgView addGestureRecognizer:tapSingle];
    }
}

#pragma mark - GestureRecognizer Selector

- (void)tapSingle:(UITapGestureRecognizer *)tap
{
    UIImageView *imgView = (UIImageView *)tap.view;
    self.currentIdx = imgView.tag-1;
    
    CustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    ImageBrowserViewController *imageBrowserVC = [[ImageBrowserViewController alloc] init];
    presentationController = [[CustomPresentationController alloc] initWithPresentedViewController:imageBrowserVC presentingViewController:self];
    imageBrowserVC.transitioningDelegate = presentationController;
    imageBrowserVC.dataSource = self;
    [self presentViewController:imageBrowserVC animated:YES completion:NULL];
}


- (NSInteger)totalImageCount
{
    return self.imgArr.count;
}
- (NSInteger)currentIndex
{
    return self.currentIdx;
}
- (UIImage *)imageBrowserViewWithIndex:(NSInteger)index
{
    return self.imgArr[index];
}

- (CGRect)dismissAnimatedImageFrameWithIndex:(NSInteger)index
{
    UIImageView *imgView = [self.view viewWithTag:index+1];
    return [imgView convertRect:imgView.bounds toView:GetNormalWindow()];
}


UIWindow *GetNormalWindow(void) {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow *temp in windows) {
            if (temp.windowLevel == UIWindowLevelNormal) {
                window = temp; break;
            }
        }
    }
    return window;
}

@end
