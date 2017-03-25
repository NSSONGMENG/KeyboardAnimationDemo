//
//  ChatTextView.m
//  KeyboardAnimationDemo
//
//  Created by songmeng on 17/3/25.
//  Copyright © 2017年 songmeng. All rights reserved.
//

#import "ChatTextView.h"

@implementation ChatTextView

- (instancetype)init{
    if (self = [super init]) {
        _placeHolderColor = [UIColor lightGrayColor];
    }
    return self;
}

/**
 如果设置了placeHolder，请在-textViewDidChange:代理方法中调用此方法
 用于清除或显示plceHolder
 */
- (void)textDidChanged{
    [self setNeedsDisplay];
    if (_maxHeight < self.frame.size.height) return;
    
    CGRect  aimFrame = self.frame;
    CGFloat textHeight = ceilf([self sizeThatFits:self.frame.size].height);
    if (textHeight == aimFrame.size.height && _maxHeight > aimFrame.size.height) return;
    
    CGSize  size = self.frame.size;
    BOOL    shouldSetContentOffset = NO;
    
    if (textHeight > self.frame.size.height) {
        CGPoint origin = self.frame.origin;
        if (self.contentSize.height > _maxHeight) {
            aimFrame = CGRectMake(origin.x, origin.y + size.height - _maxHeight, size.width, _maxHeight);
        }
        else{
            aimFrame = CGRectMake(origin.x, origin.y + size.height - self.contentSize.height, size.width, self.contentSize.height);
            shouldSetContentOffset = YES;
        }
    }else{
        if (textHeight == 0) textHeight = self.frame.size.height;
        CGPoint origin = self.frame.origin;
        aimFrame = CGRectMake(origin.x, origin.y + size.height - textHeight, size.width, textHeight);
    }
    self.frame = aimFrame;
    if (shouldSetContentOffset) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setContentOffset:CGPointMake(0, 0) animated:NO];
        });
    }
}

- (void)setPlaceHolder:(NSString *)placeHolder{
    _placeHolder = placeHolder;
    [self setNeedsDisplay];
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor{
    _placeHolderColor = placeHolderColor;
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    if (self.text.length == 0 && _placeHolder) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        paragraphStyle.alignment = self.textAlignment;
        
        CGRect  aimRect = CGRectMake(5, rect.size.height/2 - 10, rect.size.width - 10, 20);
        [self.placeHolder drawInRect:aimRect
                      withAttributes:@{ NSFontAttributeName : self.font,
                                        NSForegroundColorAttributeName : _placeHolderColor,
                                        NSParagraphStyleAttributeName : paragraphStyle }];
    }
}


@end
