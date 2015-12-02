//
//  ViewController.m
//  exercise
//
//  Created by 悠然天地 on 15/8/28.
//  Copyright (c) 2015年 My. All rights reserved.
//

#define TABLENAME @"PersonList"
#define NAME @"Name"
#define Age  @"Age"
#define Sex  @"Sex"
#define Phone @"Phone"
#define Address @"Address"
#define Photo @"Photo"

#import "ViewController.h"
#import <sqlite3.h>
#import "FMDB.h"

@interface ViewController ()

@property(nonatomic, strong)FMDatabase * db;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //取得Document路径
    NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString * dbPath = [documentPath stringByAppendingPathComponent:@"database.db"];
    NSLog(@"dbPath = %@",dbPath);
    //创建数据库
    /**
     1、当数据库文件不存在时，fmdb会自己创建一个。
     2、如果你传入的参数是空串：@"" ，则fmdb会在临时文件目录下创建这个数据库，数据库断开连接时，数据库文件被删除。
     3、如果你传入的参数是 NULL，则它会建立一个在内存中的数据库，数据库断开连接时，数据库文件被删除。
     */
    FMDatabase * db = [FMDatabase databaseWithPath:dbPath];
    self.db = db;
    if (![db open]) {
        NSLog(@"could not open db,lastErrorMessage  = %@",db.lastErrorMessage);
        return;
    }else{
        NSLog(@"open success");
    }
    
    //创建table
    if ([db open]) {
        NSString * sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS PersonList (Name text PRIMARY KEY AUTOINCREMENT, Age integer, Sex integer, Phone text, Address text, Photo blob)"];
        
        //写入数据库
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating the table");
        }else{
            NSLog(@"success");
        }
        [db close];
    }else{
        NSLog(@"table 没有打开，或者tableView已经存在");
    }
    
    /**
     *  －插入资料
     插入资料跟前面一样，用executeUpdate后面加语法就可以了。比较不同的是，因為插入的资料会跟Objective-C的变数有关，所以在string裡使用?号来代表这些变数。
     */
    if ([db open]) {
        if ([db executeUpdate:@"INSERT INTO '%@' ('%@','%@','%@','%@','%@','%@') values (?,?,?,?,?,?)",TABLENAME,NAME,Age,Sex,Phone,Address,Photo,@"唐丽梅",22,1,@"18510860420",@"ruida",@""]) {
            NSLog(@"success");
        }else{
            NSLog(@"failed");
        }
        [db close];
    }
    
    //更新资料
    if ([db open]) {
        NSString * updateSql= [NSString stringWithFormat:@"UPDATE '%@' SET '%@' = '%d' WHERE '%@' = '%d'",TABLENAME,Age,15,Age,22];
        if ([db executeUpdate:updateSql]) {
            NSLog(@"更新成功");
        }else{
            NSLog(@"更新失败");
        }
    }
    
    if ([db open]) {
        //查询
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@",TABLENAME];
        FMResultSet * resultSet = [db executeQuery:sql];
        
        /**
         *  用[rs next]可以轮询query回来的资料，每一次的next可以得到一个row裡对应的数值，并用[rs stringForColumn:]或[rs intForColumn:]等方法把值转成Object-C的型态。取用完资料后则用[rs close]把结果关闭。
         */
        while ([resultSet next]) {
            NSString * name = [resultSet stringForColumn:NAME];
            int age = [resultSet intForColumn:Age];
            NSLog(@"name = %@--age = %d",name,age);
        }
    }
    
    if ([db open]) {
        //删除
        NSString * deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",TABLENAME,NAME,@"唐丽梅"];
        FMResultSet * resultSet = [db executeQuery:deleteSql];
        if ([db executeUpdate:deleteSql]) {
            NSLog(@"deleteSql成功");
        }else{
            NSLog(@"deleteSql失败");
        }
        
        [resultSet close];
    }
    
    //创建队列
    FMDatabaseQueue * databaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [databaseQueue inDatabase:^(FMDatabase *db) {
//        [db executeUpdate:@"INSERT INTO PersonList VALUES(?)",[NSNumber numberWithInt:2]];
        
        FMResultSet * resultSet = [db executeQuery:@"select * from PersonList"];
        while([resultSet next]){
            NSString * a = [resultSet stringForColumn:NAME];
            NSLog(@"a = %@",a);
        }
    }];
    
}



@end
