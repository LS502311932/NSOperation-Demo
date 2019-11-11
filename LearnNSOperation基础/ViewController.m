//
//  ViewController.m
//  LearnNSOperation基础
//
//  Created by 刘帅 on 2019/11/9.
//  Copyright © 2019 刘帅. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSOperationQueue *opQueue;
@end

@implementation ViewController

- (NSOperationQueue *)opQueue{
    if (!_opQueue) {
        _opQueue = [[NSOperationQueue alloc]init];
    }
    return _opQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self demo1];
//    [self demo5];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"暂停/继续" forState:UIControlStateNormal];
    btn.frame = CGRectMake(100, 100, 80, 40);
    [btn addTarget:self action:@selector(pressBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn1 setTitle:@"取消所有" forState:UIControlStateNormal];
    btn1.frame = CGRectMake(100, 150, 80, 40);
    [btn1 addTarget:self action:@selector(pressBtn1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
}
/**
NSOperation 的核心概念：将”操作“添加到"队列"
GCD：将“任务” 添加到"队列"

NSOperation 是一个抽象类
特点： 不能直接调用
目的：定义子类共有的属性和方法
子类：
NSInvocationOperation
NSBlockOperation
 
 GCD & NSOperation
 GCD 在iOS4.0推出的 主要针对多核处理器做的优化并发技术 基于C语言
   -将任务 block 添加到队列（串行，并发，全局），并且指定r执行任务的函数（同步/异步）
   -线程间的通讯 disPatch_get_queue()
   -提供了一些 NSOperation 不具备的功能
    1一次执行
    2延迟操作
    3调度组（在op中也可以做到 有点麻烦）
 
 
 NSOperation 在iOS2.0推出的  苹果推出GCD后 对NSOperation的底层 重写
   —将操作（异步执行任务）添加到队列【并发】，就会立刻异步执行
   -mainQueue
   -提供了一些GCD 实现起来比较困难的功能
    -最大并发线程
    -队列的暂停/继续
    -取消所有操作
    -指定操作之间的依赖关系（GCD 用同步来实现）
 
*/

//线程间通讯
- (void)demo6{
    [self.opQueue addOperationWithBlock:^{
        NSLog(@"%@---",[NSThread currentThread]);
        //
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"UI---%@",[NSThread currentThread]);
        }];
    }];
}

//全局队列 -- 只要是NSOperation的子类 都可以添加到队列
- (void)demo5{
    
    //直接添加任务
    for (int i=0; i<10; i++) {
        [self.opQueue addOperationWithBlock:^{
            NSLog(@"%@------%d",[NSThread currentThread],i);
        }];
    }//节约代码行数
    
    //block operation
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Block%@----%d",[NSThread currentThread],100);
    }];
    [self.opQueue addOperation:op1];
    
    //Invocation  Operation
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(downLoadImage:) object:@"Invocation"];
    [self.opQueue addOperation:op2];
}


//更简单
- (void)demo4{
    //队列 队列每次分配会比较浪费
    //在实际开发中用到全局队列
    NSOperationQueue *q =[[NSOperationQueue alloc]init];
    //操作
    for (int i=0; i<10; i++) {
        [q addOperationWithBlock:^{
            NSLog(@"%@------%d",[NSThread currentThread],i);
        }];
    }
}

//NSBlockOperation 所有代码都写在一起 便于维护
- (void)demo3{
    //队列
    NSOperationQueue *q =[[NSOperationQueue alloc]init];
    //操作
    for (int i=0; i<10; i++) {
        NSBlockOperation *ob = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"%@------%d",[NSThread currentThread],i);
        }];
        //添加到队列
        [q addOperation:ob];
    }
    
}

/**
 队列：本质上 就是GCD并发队列
 操作：异步执行
 
 NSOperation 本质上就是GCD面向对象的封装
 */
- (void)demo2{
    //队列
    NSOperationQueue *q =[[NSOperationQueue alloc]init];
    for (int i=0; i<10; i++) {
        NSInvocationOperation *op = [[NSInvocationOperation alloc ]initWithTarget:self selector:@selector(downLoadImage:) object:@(i)];
        //添加到队列
        [q addOperation:op];
    }
}

//NSInvocationOperation 演示
- (void)demo1{
    NSInvocationOperation *op = [[NSInvocationOperation alloc ]initWithTarget:self selector:@selector(downLoadImage:) object:@"Invocation"];
    //start 方法 会在当前线程执行调度方法
//    [op start];
    //队列
    NSOperationQueue *q = [[NSOperationQueue alloc]init];
    //将操作添加到队列 会自动异步执行调度方法
    [q addOperation:op];

    
}
- (void)downLoadImage:(id)obj{
    NSLog(@"%@  %@",[NSThread currentThread],obj);
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self demo7];
    [self dependecy];
}
#pragma Mark 依赖关系
- (void)dependecy{
    /**
     例子：下载/解压/通知用户
     */
    //下载
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"下载---%@",[NSThread currentThread]);
    }];
    //解压
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"解压---%@",[NSThread currentThread]);
    }];
    //通知用户
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"通知用户---%@",[NSThread currentThread]);
    }];
    //dependecy 提供依赖关系
    [op2 addDependency:op1];
    [op3 addDependency:op2];
    
    //！！！不要指定循环依赖关系 会造成 队列就不工作了
//    [op1 addDependency:op3];
    
    //添加到队列。waitUntilFinished 是否等待 //YES 会卡住当前线程
//    [self.opQueue addOperations:@[op1,op2,op3] waitUntilFinished:YES];
    
    //主线程通知用户
    [self.opQueue addOperations:@[op1,op2] waitUntilFinished:YES];
    [[NSOperationQueue mainQueue] addOperation:op3];
    
    NSLog(@"over %@",[NSThread currentThread]);
}

#pragma Mark 最大并发数
//取消所有操作
/**
 队列挂起时 不会清空内部的操作 只有在队列继续的时候才会清空；
 正在的执行的操作也不会被取消
 */
- (void)pressBtn1{
    NSLog(@"取消所有操作");
    //  取消操作
    [self.opQueue cancelAllOperations];
    NSLog(@"取消之后的操作数  %tu",self.opQueue.operationCount);
}

// 当前队列挂起时 正在执行的操作不受影响
//Suspended 决定队列暂停/继续
//operationCount 队列操作数
- (void)pressBtn{
    //判断队列是否挂起
    if (self.opQueue.isSuspended) {
        NSLog(@"继续  %tu",self.opQueue.operationCount);
        self.opQueue.suspended = NO;
    }else{
        NSLog(@"暂停  %tu",self.opQueue.operationCount);
        self.opQueue.suspended = YES;
    }
}


- (void)demo7{
    //设置同时最大的并发操作量
    self.opQueue.maxConcurrentOperationCount = 2;
    
    
    //添加操作队列
    /**
     从iOS8.0 开始 无论使用GCD还是NSOperation 都会开始很对线程
     在iOS7.0 以前 GCD通常只会开5，6条
     目前多了：
        1.底层的线程池更大了 能够拿到更多线程资源
        2.多控制同时并发的线程数 需求就更高了
     */
    for (int i=0 ; i< 20; i++) {
        [self.opQueue addOperationWithBlock:^{
            [NSThread sleepForTimeInterval:1];
            NSLog(@"%@----%d",[NSThread currentThread],i);
        }];
    }
    
}

@end
