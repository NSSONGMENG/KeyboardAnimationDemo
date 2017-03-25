//
//  ViewController.m
//  KeyboardAnimationDemo
//
//  Created by songmeng on 17/3/24.
//  Copyright © 2017年 songmeng. All rights reserved.
//

#import "ViewController.h"
#import "ChatTextView.h"
#import "Masonry.h"

#define KnumberOfRow 15

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

@property (nonatomic, strong)UITableView    * tableView;
@property (nonatomic, strong)ChatTextView   * textView;

@end

static NSString * ident = @"tableviewcell";

@implementation ViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor yellowColor];
    
    //UIKeyboardWillChangeFrameNotification － iOS 5就有了，可以放心用
    //注册完成之后，别忘了在dealloc方法中删除通知哦，否则会引起崩溃，不明白的请查看－dealloc方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    //键盘回手手势（加上table view之后，如果点击到cell上就轮不到self.view响应事件了，如果cell比较少的话，还是有用的）
    UITapGestureRecognizer  * tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(tapAction)];
    [self.view addGestureRecognizer:tap];
    
    
    [self createSubview];
}

- (void)createSubview{
    //因为继承自UIControl的UITextField不能实现滚动效果，所以输入框应该使用继承自UIScrollView的UITextView，或其子类
    _textView = [ChatTextView new];
    _textView.delegate = self;
    _textView.maxHeight = 100;
    _textView.placeHolder = @"请输入";
    _textView.font = [UIFont systemFontOfSize:16];
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.layer.cornerRadius = 4.f;
    _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _textView.layer.borderWidth = 1.f;
    _textView.clipsToBounds = YES;
    [self.view addSubview:_textView];
    
    _tableView = [UITableView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.mas_equalTo(35);
        make.bottom.equalTo(self.view);
    }];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(_textView.mas_top);
    }];
}

#pragma  mark  - gesture action

- (void)tapAction{
    [_textView resignFirstResponder];
}

#pragma  mark  - keyboard aniamtion

- (void)keyboardWillChangeFrame:(NSNotification *)notify{
    NSDictionary    * info = notify.userInfo;
    //动画时间
    CGFloat animationDuration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //键盘目标位置
    CGRect  keyboardAimFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self keybaordAnimationWithDuration:animationDuration keyboardOriginY:keyboardAimFrame.origin.y];
}

/**
 处理键盘弹出、隐藏、更新frame动画
 
 @param duration 动画时间
 @param keyboardOriginY 键盘纵向起点
 */
- (void)keybaordAnimationWithDuration:(CGFloat)duration keyboardOriginY:(CGFloat)keyboardOriginY{
    CGFloat contentHeight = _tableView.contentSize.height;
    
    //作为视图的键盘，弹出动画也是UIViewAnimationOptionCurveEaseIn的方式
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        //text field
        CGPoint textFieldOrigin = _textView.frame.origin;
        CGSize  textFieldSize = _textView.frame.size;
        CGRect  textFieldAimFrame = CGRectMake(textFieldOrigin.x, keyboardOriginY - textFieldSize.height, textFieldSize.width, textFieldSize.height);
        _textView.frame = textFieldAimFrame;
        
        //table view
        CGPoint tableViewOrigin = _tableView.frame.origin;
        CGSize  tableViewSize   = _tableView.frame.size;
        CGRect  tableViewAimFrame = CGRectMake(tableViewOrigin.x, tableViewOrigin.y, tableViewSize.width, textFieldAimFrame.origin.y - tableViewOrigin.y);
        _tableView.frame = tableViewAimFrame;
        
        //显示最后一个cell
        if (contentHeight > tableViewAimFrame.size.height){
            [_tableView setContentOffset:CGPointMake(0, contentHeight - tableViewAimFrame.size.height)];
        }
    } completion:^(BOOL finished) {
        [self refreshLayout];
    }];
}


/**
 设置完frame之后更新约束，使frame失效
 */
- (void)refreshLayout{
    [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        CGRect  frame = _tableView.frame;
        make.top.equalTo(self.view).offset(frame.origin.y);
        make.left.equalTo(self.view).offset(frame.origin.x);
        make.right.equalTo(self.view).offset(- frame.origin.x);
        make.bottom.equalTo(_textView.mas_top);
    }];
    [_textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        CGRect  frame = _textView.frame;
        CGSize  screenSize = [UIScreen mainScreen].bounds.size;
        make.left.equalTo(self.view).offset(frame.origin.x);
        make.right.equalTo(self.view).offset(- frame.origin.x);
        make.height.mas_equalTo(frame.size.height);
        make.bottom.equalTo(self.view).offset(- screenSize.height + frame.origin.y + frame.size.height);
    }];
}

#pragma  mark  - text view
- (void)textViewDidChange:(UITextView *)textView{
    if (textView == _textView) {
        [_textView textDidChanged];
        CGPoint textViewOrigin = _textView.frame.origin;
        CGFloat contentHeight = _tableView.contentSize.height;
        
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            //修改table view frame
            CGPoint tableViewOrigin = _tableView.frame.origin;
            CGSize  tableViewSize   = _tableView.frame.size;
            CGRect  tableViewAimFrame = CGRectMake(tableViewOrigin.x, tableViewOrigin.y, tableViewSize.width, textViewOrigin.y - tableViewOrigin.y);
            _tableView.frame = tableViewAimFrame;
            
            //显示最后一个cell
            if (contentHeight > tableViewAimFrame.size.height){
                [_tableView setContentOffset:CGPointMake(0, contentHeight - tableViewAimFrame.size.height)];
            }
        } completion:^(BOOL finished) {
            [self refreshLayout];
        }];
    }
}

#pragma  mark  - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return KnumberOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
    }
    
    cell.textLabel.text = @"我爱北京天安门，天安门前太阳升";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"今天第 %ld 天",indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self tapAction];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //需要拖动cell时隐藏键盘在此处理
//    [self tapAction];
}

#pragma  mark  - other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
