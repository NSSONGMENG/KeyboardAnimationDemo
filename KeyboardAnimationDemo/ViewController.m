//
//  ViewController.m
//  KeyboardAnimationDemo
//
//  Created by songmeng on 17/3/24.
//  Copyright © 2017年 songmeng. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"

#define KnumberOfRow 15

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic, strong)UITextField    * textField;
@property (nonatomic, strong)UITableView    * tableView;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    UITapGestureRecognizer  * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tap];
    
    _textField = [UITextField new];
    _textField.placeholder = @"请输入";
    _textField.layer.cornerRadius = 3.f;
    _textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _textField.layer.borderWidth = 1.f;
    _textField.clipsToBounds = YES;
    [self.view addSubview:_textField];
    
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self.view);
    }];
    
    [self createSubview];
}

- (void)createSubview{
    _tableView = [UITableView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(_textField.mas_top);
    }];
}

- (void)tapAction{
    [_textField resignFirstResponder];
}

#pragma  mark  - keyboard aniamtion

- (void)keyboardWillChangeFrame:(NSNotification *)notify{
    NSDictionary    * info = notify.userInfo;
    CGFloat animationDuration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
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
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        //text field
        CGPoint textFieldOrigin = _textField.frame.origin;
        CGSize  textFieldSize = _textField.frame.size;
        
        CGRect  textFieldAimFrame = CGRectMake(textFieldOrigin.x, keyboardOriginY - textFieldSize.height, textFieldSize.width, textFieldSize.height);
        _textField.frame = textFieldAimFrame;
        
        //table view
        CGPoint tableViewOrigin = _tableView.frame.origin;
        CGSize  tableViewSize   = _tableView.frame.size;
        CGRect  tableViewAimFrame = CGRectMake(tableViewOrigin.x, tableViewOrigin.y, tableViewSize.width, textFieldAimFrame.origin.y - tableViewOrigin.y);
        _tableView.frame = tableViewAimFrame;
        
        //显示最后一个cell
        if (contentHeight > tableViewAimFrame.size.height){
            [_tableView setContentOffset:CGPointMake(0, contentHeight - tableViewAimFrame.size.height)];
        }
    } completion:nil];
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
    [_textField resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
