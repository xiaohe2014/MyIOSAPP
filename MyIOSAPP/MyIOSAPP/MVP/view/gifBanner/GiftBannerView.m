//
//  GiftBannerView.m
//  Broadcast
//
//  Created by river on 2017/11/23.
//  Copyright © 2017年 river. All rights reserved.
//

#import "GiftBannerView.h"
#import "POP.h"
#import "UIColor+Hex.h"
#import "UIView+EFrame.h"

#define kShowDuration   2

#define giftSize 55
// 屏幕尺寸
#define SCREEN_SIZE         [UIScreen mainScreen].bounds.size
#define SCREEN_WIDTH        SCREEN_SIZE.width
#define SCREEN_HEIGHT       SCREEN_SIZE.height
#define SCREEN_SCALE        [UIDevice currentDevice].screenScale

@interface GiftBannerView ()
@property (nonatomic, strong) UIImageView *imgAvatar;
@property (nonatomic, strong) UILabel *lbName;
@property (nonatomic, strong) UILabel *lbInfo;
@property (nonatomic, strong) UIImageView *imgGift;
@property (nonatomic, strong) UILabel *lbGiftCount;
@property (nonatomic, assign) CGPoint targetCenter;
@property (nonatomic, assign) CGPoint giftImageTargetCenter;
@property (nonatomic, assign) int line;
@property (nonatomic, copy)   GiftBannerAnimationBlock block;
@property (nonatomic, strong) NSTimer *giftReceiveTimer;

@property (nonatomic, assign) BOOL                      isHiding;

@end

@implementation GiftBannerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

static int height = 42;
+ (CGFloat)bannerHeight
{
    return height;
}

static int width = 200;
+ (CGFloat)bannerWidth
{
    return width;
}

static const int nameLeftPadding = 5;

-(void)initCustomView{
    CGFloat totalWidth = 0;
    
    self.layer.cornerRadius = height / 2;
    //    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.3];
    
    //btnAvatar
    self.imgAvatar = [UIImageView new];
    _imgAvatar.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnAvatarClicked)];
    [_imgAvatar addGestureRecognizer:tap];
//    _imgAvatar.image = [UIImage imageNamed:@"avatarSmall"];
//    if (msg.fromuid.longLongValue == 1) {
//        _imgAvatar.image = [UIImage imageNamed:@"avatarSmall2"];
//    }
//    if (msg.fromuid.longLongValue == 1000) {
        _imgAvatar.image = [UIImage imageNamed:@"myAvatarSmall"];
//    }
    
    _imgAvatar.layer.cornerRadius = height/2;
    _imgAvatar.layer.masksToBounds = YES;
    _imgAvatar.frame = CGRectMake(0, 0, height, height);
    [self addSubview:_imgAvatar];
    
    //lbName
    self.lbName = [UILabel new];
    _lbName.backgroundColor = [UIColor clearColor];
    _lbName.font = [UIFont systemFontOfSize:14];
    _lbName.textColor = [UIColor whiteColor];
    _lbName.text = @"XXX";

    int topMargin = 4;
    CGSize textSize = [_lbName sizeThatFits:CGSizeZero];
    CGRect frame = _imgAvatar.frame;
    frame.origin.x = CGRectGetMaxX(frame) + nameLeftPadding;
    frame.origin.y = topMargin;
    frame.size = textSize;
    frame.size.width = width - frame.origin.x;
    _lbName.frame = frame;
    [self addSubview:_lbName];

    self.lbInfo = [UILabel new];
    _lbInfo.backgroundColor = [UIColor clearColor];
    _lbInfo.font = [UIFont systemFontOfSize:12];
    _lbInfo.textColor = [UIColor colorWithHex:0xFDDB00];
//    _lbInfo.text = [self getGiftSendText];
    _lbInfo.text = @"发送某某的礼物";

    topMargin = 2;
    textSize = [_lbInfo sizeThatFits:CGSizeZero];
    frame = _lbName.frame;
    frame.origin.y = CGRectGetMaxY(frame) + topMargin;
    frame.size = textSize;
    _lbInfo.frame = frame;
    [self addSubview:_lbInfo];

    //imgGift
    self.imgGift = [UIImageView new];
    _imgGift.backgroundColor = [UIColor clearColor];
//    UIImage* image = [_currentGiftMsg getGiftImageForBarrage:YES];
//
//    if (msg.fromuid.longLongValue == _OwnerID) {
//        image = [UIImage imageNamed:[NSString stringWithFormat:@"gift%d", (int)msg.giftType]];
//    }
   UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"gift1"]];

    //这里计算礼物文案宽度
    totalWidth = CGRectGetMaxX(_lbInfo.frame) + giftSize;
    totalWidth = ceil(totalWidth);
    width = 200;
    if (totalWidth > width) {
        width = totalWidth;
    }
    _imgGift.image = image;
    _imgGift.frame = CGRectMake(width - giftSize, - (giftSize-height), giftSize, giftSize);
    _lbName.eWidth = _imgGift.eOriginx - _lbName.eOriginx;

    [self addSubview:_imgGift];
//
    self.giftImageTargetCenter = _imgGift.center;
    _imgGift.frame = CGRectMake(-giftSize, - (giftSize-height), giftSize, giftSize);

    //in order to get targetCenter
    frame = self.frame;
    frame.size.width = width;
    self.frame = frame;

    if (!CGRectIsEmpty(self.frame)) {
        self.targetCenter = self.center;
    }

    //make it to real position
    frame = self.frame;
    frame.origin.x = -frame.size.width;
    self.frame = frame;
}

static const int bannerLeftPadding = 7;
- (void)showWithAnimationFinishBlock:(GiftBannerAnimationBlock)block
{
    self.block = block;
    CGFloat toValue = _targetCenter.x + bannerLeftPadding;
    
    CGPoint center = self.center;
    CGPoint imgCenter = _imgGift.center;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        self.center = CGPointMake(toValue, center.y);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            CGFloat toValue = _giftImageTargetCenter.x;
            _imgGift.center = CGPointMake(toValue, imgCenter.y);
            
        } completion:^(BOOL finished) {
            
//            [self playNumberAnimationWithCount:_currentGiftMsg.tapCount];
            [self playNumberAnimationWithCount:10];

            
        }];
        
    }];
}
- (void)playNumberAnimationWithCount:(int)count{
    UILabel *lab = [self viewWithTag:100];
    [lab removeFromSuperview];
    
    //lbGiftCount
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:25];
    label.textColor = [UIColor colorWithHex:0x58CBEE];
    label.text = [NSString stringWithFormat:@"X %d",count];
    
    //shadow
    label.layer.shadowColor = [UIColor whiteColor].CGColor;
    label.layer.shadowOpacity = 1;
    label.layer.shadowRadius = 0;
    label.layer.shadowOffset = CGSizeMake(0, 0);
    label.clipsToBounds = NO;
    label.tag = 100;
    
    [self addSubview:label];
    CGSize textSize = [label sizeThatFits:CGSizeZero];
    CGFloat minScale = 0.01;
    CGFloat maxScale = 3;
    CGFloat flexTop = 5;
    
    label.frame = CGRectMake(width, CGRectGetMinY(_imgGift.frame) - flexTop, textSize.width, textSize.height);
    label.transform = CGAffineTransformScale(CGAffineTransformIdentity, maxScale, maxScale);
    
    [UIView animateWithDuration:0.15 animations:^{
        label.transform = CGAffineTransformScale(CGAffineTransformIdentity, minScale, minScale);
    } completion:^(BOOL finished) {
        
        POPSpringAnimation *anim2 = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        anim2.completionBlock = ^(POPAnimation *anim, BOOL finished){
            
            if (_giftReceiveTimer) {
                [_giftReceiveTimer invalidate];
                self.giftReceiveTimer = nil;
            }
            
//            if (_nextGiftMsg) {
//                
//                [self continuePlayTapAnimationIfNeeded];
//                
//            }
//            else
//            {
//                self.giftReceiveTimer = [NSTimer scheduledTimerWithTimeInterval:kShowDuration target:self selector:@selector(onGiftQueueTimeout) userInfo:nil repeats:false];
//            }
            self.giftReceiveTimer = [NSTimer scheduledTimerWithTimeInterval:kShowDuration target:self selector:@selector(onGiftQueueTimeout) userInfo:nil repeats:false];

            
        };
        anim2.fromValue = [NSValue valueWithCGSize:CGSizeMake(minScale, minScale)];
        anim2.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
        anim2.springSpeed = 20;
        anim2.springBounciness = 20;
        anim2.dynamicsFriction = 18;
        //        anim2.velocity = [NSValue valueWithCGSize:CGSizeMake(20, 20)];
        [label.layer pop_addAnimation:anim2 forKey:@"xxx"];
        
    }];
}


- (BOOL)isHiding
{
    return _isHiding;
}

- (void)hide
{
    self.isHiding = YES;
    
    if (_block) {
        _block(_line);
    }
    CGPoint point = self.center;
    point.y -= self.bounds.size.height;
    
    [UIView animateWithDuration:1 animations:^{
        
        self.center = point;
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
    }];
}

- (void)onGiftQueueTimeout
{
//    if (_nextGiftMsg) {
//        [self continuePlayTapAnimationIfNeeded];
//        return;
//    }
    
    _giftReceiveTimer = nil;
    [self hide];
}

- (NSString *)getGiftSendText
{
    return @"送了你一个星星";
}

@end
