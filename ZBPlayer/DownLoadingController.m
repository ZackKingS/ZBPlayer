//
//  DownLoadingController.m
//  ZBPlayer
//
//  Created by 柏超曾 on 2017/8/24.
//  Copyright © 2017年 柏超曾. All rights reserved.
//

#import "DownLoadingController.h"
#import "AddingMovieController.h"

#import "MoviewCell.h"
@interface DownLoadingController ()<UITableViewDelegate,UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray   *movieArr ;
@end
NSString * const MYID = @"MovieCell";

@implementation DownLoadingController

- (NSMutableArray *)movieArr
{
    
    if (!_movieArr) {
        
        _movieArr = [NSMutableArray array];
        
        [_movieArr addObject:@"海贼王"];
        [_movieArr addObject:@"死神"];
        [_movieArr addObject:@"火影"];
    }
    return _movieArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
  
    
    [self setupTableView];
    
    [self setupNavigationItem];
    
    
    
}


-(void)setupTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource =self;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MoviewCell class]) bundle:nil] forCellReuseIdentifier:MYID];
    
}

-(void)setupNavigationItem
{
    
     self.navigationItem.title = @"下载中";
    
    UIBarButtonItem *addItem = [[UIBarButtonItem  alloc]initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(addMoview)];
    
    self.navigationItem.rightBarButtonItem = addItem;
    
}

-(void)addMoview{
    
    AddingMovieController *adding = [[AddingMovieController alloc]init];
    
    [self.navigationController pushViewController:adding animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MoviewCell *cell = [tableView dequeueReusableCellWithIdentifier:MYID forIndexPath:indexPath];
    
    cell.textLabel.text = self.movieArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MYID forIndexPath:indexPath];
//    
//    
//    NSLog(@"%@",self.movieArr);
//    
//    cell.textLabel.text =  self.movieArr[indexPath.row];
    
    return cell;
    
    
    
}

@end
