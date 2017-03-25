//
//  ChatTextView.h
//  KeyboardAnimationDemo
//
//  Created by songmeng on 17/3/25.
//  Copyright © 2017年 songmeng. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 聊天输入框 */
@interface ChatTextView : UITextView


/** 默认为nil */
@property (nonatomic, copy) NSString    * placeHolder;

/** 默认lightTextColor */
@property (nonatomic, strong) UIColor   * placeHolderColor;

/** 允许显示的最大高度，超过这个高度视图内的文本将会滚动 */
@property (nonatomic, assign) CGFloat   maxHeight;


/**
 如果设置了placeHolder，请在-textViewDidChange:代理方法中调用此方法
 用于清除或显示plceHolder
 */
- (void)textDidChanged;


@end
