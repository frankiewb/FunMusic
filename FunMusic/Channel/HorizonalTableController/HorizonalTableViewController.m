//
//  HorizonalTableViewController.m
//  FunMusic
//
//  Created by frankie on 15/12/26.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "HorizonalTableViewController.h"
#import "Common.h"


static NSString *kHorizonalCellID = @"HorizonalCell";

@interface HorizonalTableViewController ()

@end

@implementation HorizonalTableViewController

- (instancetype)initWithViewControllers:(NSArray *)controllers
{
    self = [super init];
    if (self)
    {
        _controllers = [NSMutableArray arrayWithArray:controllers];
        for (UIViewController *controller in controllers)
        {
            //加强理解
            [self addChildViewController:controller];
        }
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] init];
    //去掉分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //点击屏幕的status bar即可回到顶部
    self.tableView.scrollsToTop = NO;
    //将tableview逆时针旋转90度
    self.tableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    //去掉竖行滚动条 (由于table被横向放置，故对于屏幕来说相当于去掉左右横向滚动条)
    self.tableView.showsVerticalScrollIndicator = NO;
    //实现手势每次滑动一次只移动一页或者一页的倍数（cell），默认的paging机制时每个page的高度和tableview frame的高度一样
    //个人使用过程中不太好使，有误操作和bug，还是决定手动实现翻页，确保一次只能翻一页
    self.tableView.pagingEnabled = YES;
    self.tableView.backgroundColor = HORIZONALBACKGROUNDCOLOR;
    //当scrollview滚动到边界时，再继续滚动不让其反弹
    self.tableView.bounces = NO;
    
    //采用registerClass方式注册CellID，代码更简洁，IOS 6新增
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kHorizonalCellID];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _controllers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //注意：此时table已经逆时针旋转90度，而且每个cell又顺时针旋转90度，又由于一个cell占满整个tableviewframe
    //所有table中每个row的高度实际上是一个tableviewframe的宽度。
    
    return tableView.frame.size.width;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kHorizonalCellID forIndexPath:indexPath];
    
    //将已经逆时针90度转向的tableview中的cell再顺时针转向90度，这样cell就正过来了
    cell.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
    cell.contentView.backgroundColor = [UIColor blueColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //每当选中哪个cell，展示哪个controller对应的view
    UIViewController *controller = _controllers[indexPath.row];
    
    //严重区分！！Frame和size区别！！真是大坑！！ 
    controller.view.frame = cell.contentView.bounds;
    
    
    
    [cell.contentView addSubview:controller.view];
    
    return cell;
}


#pragma <UIScrollViewDelegate>

//当拖拽停止后
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollStop:YES];
}
//当正在拖拽行为当中时
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self scrollStop:NO];
}



#pragma Class Function

//当拖拽停止前实现TitleBar大小和颜色的渐变效果
//当拖拽停止后实现页面切换
- (void) scrollStop:(BOOL)isScrollStop
{
    //由滑动停止后执行的scrollStop，人工判断是否翻过一页    
    //contentSize是UIScrollView可以滚动的区域。ContentOffSet是UIScrollView当前显示区域的顶点相对于frame顶点的偏移量
    //这里指当前页面相对于最左边滑动了多少偏移量，因为table被逆时针90度放置，所以偏移量为y
    CGFloat horizonalOffset = self.tableView.contentOffset.y;
    CGFloat screenWidth = self.tableView.frame.size.width;
    //用来判断到底目前应该显示哪个页面，如果当前页面滑动过半，则判断已经转到下一页面，否则认为仍然停留在上一页面
    NSUInteger focusPageIndex = (horizonalOffset + screenWidth/2) /screenWidth;
    
    if (isScrollStop)
    {
        _currentIndex = focusPageIndex;
        _changeIndex(_currentIndex);
    }
    //没有停止的话就进行颜色和大小的渐变效果
    
    //TO DO......
}




- (void)scrollToViewAtIndex:(NSInteger)index
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                          atScrollPosition:UITableViewScrollPositionNone
                                  animated:NO];
    _currentIndex = index;
}


@end
