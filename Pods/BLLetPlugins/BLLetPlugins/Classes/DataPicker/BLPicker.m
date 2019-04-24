//
//  Picker.m
//  BLAppApi
//
//  Created by milliwave-Zs on 16/2/22.
//  Copyright © 2016年 broadlink. All rights reserved.
//

#import "BLPicker.h"
#import "BLCatchCrash.h"

#import <BLLetBase/BLLetBase.h>
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIDevice.h>
#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import <zlib.h>


@interface BLPicker()

@property (nonatomic, strong) NSString *pickUpdateDataURL;

@property (nonatomic, strong) NSCache *pageCache;

@property (nonatomic, strong) NSDateFormatter *formatter;

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) BLApiUrls *apiUrls;

@property (nonatomic, strong) BLConfigParam *configParam;
@end

@implementation BLPicker {
    NSTimer *_timer;
    
    sqlite3 *database;
    int appDid;
    BOOL isPageEnd;
    BOOL isStartPick;
    dispatch_queue_t _queue;
}

static BLPicker *sharedPicker = nil;

+ (instancetype _Nullable)sharedPicker {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPicker = [[BLPicker alloc] init];
    });
    
    return sharedPicker;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _apiUrls = [BLApiUrls sharedApiUrl];
        isPageEnd = NO;
        isStartPick = NO;
        _queue = dispatch_queue_create("test.queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

#pragma mark - notice method
- (void)initAppInfo {
    
    //Crash 日志捕获
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [dic setObject:[infoDictionary objectForKey:@"CFBundleShortVersionString"] forKey:@"appVerName"];
    [dic setObject:[infoDictionary objectForKey:@"CFBundleVersion"] forKey:@"appVerCode"];
    
    NSString *sdkversion = @"2.10";
    [dic setObject:sdkversion forKey:@"sdkVerName"];
    
    NSString *language = [BLCommonTools getCurrentLanguage];
    [dic setObject:language forKey:@"language"];
    [dic setObject:[self.formatter stringFromDate:[NSDate date]] forKey:@"start"];
    
    NSString *carriername = [BLNetworkImp getCurrentNetworkCarriername];
    if (carriername) {
        [dic setObject:carriername forKey:@"operator"];
    }
    
//    NSString *networkType = [BLNetworkImp getCurrentNetworkType];
//    if (networkType) {
//        [dic setObject:networkType forKey:@"net"];
//    }

    //创建数据库
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"database"];
    if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        BLLogError(@"数据库打开失败");
    }
    else {
        sqlite3_exec(database,"PRAGMA synchronous = OFF; ",0,0,0);
//        sqlite3_exec(database,"PRAGMA journal_mode=WAL; ",0,0,0);
        NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS PickerInfo (did INTEGER PRIMARY KEY, type INTEGER, data TEXT)";
        dispatch_sync(_queue, ^{
            [self execSql:sqlCreateTable];
        });
        
    }
    appDid = [[self insetSqlWithType:1 dic:dic] intValue];
    
    __weak __typeof__(self) weakSelf = self;
    /*set notifications.*/
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        //从数据库中读取统计数据
        NSArray *array = [strongSelf readSqlWithDid:appDid];
        if (array.count > 0) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[array objectAtIndex:0]];
            NSString *tempJSONString = [dic objectForKey:@"data"];
            NSError *error;
            //json-->dic
            NSDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:[tempJSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
            NSMutableDictionary *tempAppDic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
            [tempAppDic setObject:[strongSelf getNowTimeString] forKey:@"finish"];
            [self updateSqlWithDid:appDid dic:tempAppDic];
            appDid = -1;
        }
    }];
}

- (void)startPick {
    if (_timer == nil) {
        [self initAppInfo];
        isStartPick = YES;
        //定时上报统计数据 100s 上报一次
        _timer = [NSTimer scheduledTimerWithTimeInterval:100 target:self selector:@selector(uploadData) userInfo:nil repeats:YES];
        [_timer fire];
    }
}

- (void)stopPick {
    if (_timer && [_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - notice method
- (NSString*)getNowTimeString
{
    NSString *timeString = [self.formatter stringFromDate:[NSDate date]];
    return timeString;
}

- (void)execSql:(NSString *)sql
{
    char *err;
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        BLLogError(@"数据库操作数据失败 err = %s", err);
    }
    
}

#pragma mark ***批量提交***
-(void)execInsertTransactionSql:(NSMutableArray *)transactionSql
{
    //使用事务，提交插入sql语句
    @try{
        char *errorMsg;
        if (sqlite3_exec(database, "BEGIN", NULL, NULL, &errorMsg)==SQLITE_OK)
        {
            sqlite3_free(errorMsg);
            sqlite3_stmt *statement;
            for (int i = 0; i < transactionSql.count; i ++)
            {
                if (sqlite3_prepare_v2(database,[[transactionSql objectAtIndex:i] UTF8String], -1, &statement,NULL)==SQLITE_OK)
                {
                    if (sqlite3_step(statement)!=SQLITE_DONE) sqlite3_finalize(statement);
                }
            }
            if (sqlite3_exec(database, "COMMIT", NULL, NULL, &errorMsg)==SQLITE_OK)
                BLLogVerbose(@"Log Commit Success");
            sqlite3_free(errorMsg);
        }
        else sqlite3_free(errorMsg);
    }
    @catch(NSException *e)
    {
        char *errorMsg;
        if (sqlite3_exec(database, "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)
        sqlite3_free(errorMsg);
        BLLogVerbose(@"Log Commit Fail,error:%s",errorMsg);
    }
    @finally{}
}

- (void)updateSqlWithDid:(NSInteger) did dic:(NSDictionary*) dic
{
    NSError *error;
    //dic-->json
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *sql1 = [NSString stringWithFormat:
                      @"UPDATE PickerInfo SET data = '%@' WHERE did = '%@'", string, [NSNumber numberWithInteger:did]];
    dispatch_async(_queue, ^{
        [self execSql:sql1];
    });
    
}

- (void)putData:(NSDictionary *)pyramidDbData {
    [self.dataList addObject:pyramidDbData];
    if (self.dataList.count >= [BLConfigParam sharedConfigParam].dataReportCount) {
        @synchronized (self.dataList) {
        NSMutableArray *transactionSql = [NSMutableArray array];
        for (int i = 0; i < self.dataList.count; i++) {
                NSInteger pyramType = [[self.dataList[i] objectForKey:@"pyramtype"] integerValue];
                NSDictionary *event = [self.dataList[i] objectForKey:@"event"];
                NSString *sql = [self insetSqlWithType:pyramType dic:event];
                if ([sql integerValue] < 0) {
                    break;
                } else {
                    [transactionSql addObject:sql];
                    [self.dataList removeObjectAtIndex:i];
                }
            }
                dispatch_sync(_queue, ^{
                    [self execInsertTransactionSql:transactionSql];
                });
        }
    }
    
}

- (void)putDataStraightWay:(NSDictionary *)pyramidDbData {
    [self.dataList insertObject:pyramidDbData atIndex:0];
    if (self.dataList.count > 0) {
        @synchronized (self.dataList) {
            NSMutableArray *transactionSql = [NSMutableArray array];
            for (int i = 0; i < self.dataList.count; i++) {
                NSInteger pyramType = [[self.dataList[i] objectForKey:@"pyramtype"] integerValue];
                NSDictionary *event = [self.dataList[i] objectForKey:@"event"];
                NSString *sql = [self insetSqlWithType:pyramType dic:event];
                if ([sql integerValue] < 0) {
                    break;
                } else {
                    [transactionSql addObject:sql];
                    [self.dataList removeObjectAtIndex:i];
                }
            }
            dispatch_sync(_queue, ^{
                [self execInsertTransactionSql:transactionSql];
            });
        }
        
    }
}

- (NSString *)insetSqlWithType:(NSInteger) type dic:(NSDictionary*) dic
{
    NSError *error;
    if (dic == nil) {
        return  @"-1";
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    string = [string stringByReplacingOccurrencesOfString:@"'" withString:@""""];
    
    NSString *sqlQuery = @"SELECT max(did) FROM PickerInfo";
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int did = sqlite3_column_int(statement, 0);
            did++;
            NSString *sql1 = [NSString stringWithFormat:
                              @"INSERT INTO PickerInfo (type, data) VALUES ('%@', '%@')",  [NSNumber numberWithInteger:type], string];
            return sql1;
        }
    }

    return @"-1";
}

- (NSString *)deleteSqlWithDid:(int) did
{
    return [NSString stringWithFormat:@"DELETE FROM PickerInfo WHERE did = '%d'",did];
    //    [self execSql:[NSString stringWithFormat:@"DELETE FROM PickerInfo WHERE did = '%d'",did]];
}

- (NSArray*)readSqlWithType:(int) type
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *sqlQuery =[NSString stringWithFormat:@"SELECT * FROM PickerInfo WHERE type = '%d'", type];
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int did = sqlite3_column_int(statement, 0);
            const unsigned char *data = sqlite3_column_text(statement, 2);
            NSString *dataStr = [[NSString alloc]initWithUTF8String:(const char*)data];
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:did], @"did", dataStr, @"data", nil]];
        }
    }
    return array;
}

- (NSArray*)readSqlWithDid:(int) did
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *sqlQuery =[NSString stringWithFormat:@"SELECT * FROM PickerInfo WHERE did = '%d'", did];
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int did = sqlite3_column_int(statement, 0);
            const unsigned char *data = sqlite3_column_text(statement, 2);
            NSString *dataStr = [[NSString alloc]initWithUTF8String:(const char*)data];

            [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:did], @"did", dataStr, @"data", nil]];
        }
    }
    return array;
}

- (void)trackPageBegin:(NSString *)pageName
{
    if (!isPageEnd)
        [self.pageCache removeAllObjects];
    
    isPageEnd = NO;
    [self.pageCache setObject:pageName forKey:@"pageName"];
    [self.pageCache setObject:[self getNowTimeString] forKey:@"start"];
}

- (void)trackPageEnd:(NSString *)pageName
{
    if (isStartPick) {
        if (isPageEnd)
            return;
        if (![pageName isEqualToString:[self.pageCache objectForKey:@"pageName"]])
            return;
        
        isPageEnd = YES;
        
        //结束时间
        NSDate *end = [NSDate date];
        [self.pageCache setObject:[self.formatter stringFromDate:end] forKey:@"finish"];
        
        //停留时间
        NSDate *start = [self.formatter dateFromString:[self.pageCache objectForKey:@"start"]];
        NSTimeInterval diff = [end timeIntervalSinceDate:start];
        [self.pageCache setObject:[NSString stringWithFormat:@"%d", (int)diff] forKey:@"useTime"];

        NSDictionary *dataDic = [[NSDictionary alloc] initWithObjectsAndKeys: @2, @"pyramtype", self.pageCache, @"event", nil];
        [self putData:dataDic];
    }
    
}

- (void)setLatitude:(NSString *)latitude longitude:(NSString *)longitude
{
    NSString *coordinate = [NSString stringWithFormat:@"%@, %@", latitude, longitude];
    NSArray *array = [self readSqlWithDid:appDid];
    if (array.count > 0)
    {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[array objectAtIndex:0]];
        NSString *tempJSONString = [dic objectForKey:@"data"];
        
        NSError *error;
        NSDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:[tempJSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
        NSMutableDictionary *tempAppDic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
        
        [tempAppDic setObject:coordinate forKey:@"coordinate"];
        
        [self updateSqlWithDid:appDid dic:tempAppDic];
    }
}

- (void)trackErrorWithErrorNo:(NSInteger)err msg:(NSString *)msg function:(NSString *)function externData:(NSDictionary *)externData{
    if (err == 0 || msg == nil || function == nil) {
        return;
    }
    
    NSMutableDictionary *dataDic;
    if (externData) {
        dataDic = [[NSMutableDictionary alloc] initWithDictionary:externData];
    } else {
        dataDic = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    
    [dataDic setObject:[NSString stringWithFormat:@"%ld", (long)err] forKey:@"errno"];
    [dataDic setObject:msg forKey:@"msg"];
    [dataDic setObject:function forKey:@"function"];
    
    [self trackEvent:(NSString *)kPickErrorEventId label:(NSString *)kPickErrorEventLabel parameters:dataDic];
}

- (void)trackEvent:(NSString *)eventId {
    [self trackEvent:eventId label:nil parameters:nil];
}

- (void)trackEvent:(NSString *)eventId label:(NSString *)eventLabel {
    [self trackEvent:eventId label:eventLabel parameters:nil];
}

- (void)trackEvent:(NSString *)eventId label:(NSString *)eventLabel parameters:(NSDictionary *)parameters {
    if (isStartPick) {
        NSMutableDictionary *event = [[NSMutableDictionary alloc] init];
        [event setObject:eventId forKey:@"type"];
        
        [event setObject:[self.formatter stringFromDate:[NSDate date]] forKey:@"time"];
        if (eventLabel)
            [event setObject:eventLabel forKey:@"tag"];
        if (parameters)
            [event setObject:parameters forKey:@"data"];
        
        NSString *userid = [BLConfigParam sharedConfigParam].userid;
        if (userid) {
            [event setObject:userid forKey:@"userId"];
        }
        NSDictionary *dataDic = [[NSDictionary alloc]initWithObjectsAndKeys:@3,@"pyramtype",event,@"event", nil];
        if ([eventId isEqualToString: (NSString *)kPickCrashEventId]) {
            [self putDataStraightWay:dataDic];
        }else {
            [self putData:dataDic];
        }
        BLLogVerbose(@"Add a event: %@", event);
    }
    
}

- (void)finish:(void (^)(NSData *data, NSError *))result {
    NSMutableArray *phoneArray = [[NSMutableArray alloc] init];
    NSMutableArray *pageArray = [[NSMutableArray alloc] init];
    NSMutableArray *eventArray = [[NSMutableArray alloc] init];
    NSMutableArray *deleteDidArray = [[NSMutableArray alloc] init];

    int count = 0;
    NSArray *tempEventArray = [self readSqlWithType:3];
    for (NSDictionary *dic in tempEventArray) {
        if (count >= 98) {
            break;
        } else {
            count++;
        }
        NSString *tempJSONString = [dic objectForKey:@"data"];
        NSError *error;
        NSDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:[tempJSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
        [eventArray addObject:tempDic];
        [deleteDidArray addObject:[dic objectForKey:@"did"]];
    }
    NSArray *tempPageArray = [self readSqlWithType:2];
    for (NSDictionary *dic in tempPageArray) {
        if (count >= 98) {
            break;
        } else {
            count++;
        }
        NSString *tempJSONString = [dic objectForKey:@"data"];
        NSError *error;
        NSDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:[tempJSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
        [pageArray addObject:tempDic];
        [deleteDidArray addObject:[dic objectForKey:@"did"]];
    }
    if (count == 0) {
        //若没有记录数据 则不上报
        return;
    }
    
    NSArray *tempPhoneArray = [self readSqlWithType:1];
    for(NSDictionary *appDic in tempPhoneArray) {
        if (count >= 98) {
            break;
        } else {
            count++;
        }
        if ([[appDic objectForKey:@"did"] intValue] != appDid) {
            NSString *tempJSONString = [appDic objectForKey:@"data"];
            NSError *error;
            NSDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:[tempJSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
            if (error != nil){
                BLLogDebug(@"error:%@,%@",error.localizedDescription,tempJSONString);
            }else{
                [phoneArray addObject:tempDic];
            }
            [deleteDidArray addObject:[appDic objectForKey:@"did"]];
        }
    }

    NSDictionary *phoneDic = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"iPhone", @"brand",
                              [[UIDevice currentDevice] model], @"model",
                              [[UIDevice currentDevice] systemVersion], @"os",
                              @"iOS", @"type",
                              nil];

    NSDictionary *infodic = [[NSBundle mainBundle] infoDictionary];
    NSString *identifier = [infodic objectForKey:@"CFBundleIdentifier"];
    
    NSString *signStr = [NSString stringWithFormat:@"%@%@9#$*05", identifier, [BLConfigParam sharedConfigParam].sdkLicense];
    NSString *sign = [self md5:signStr];
    
    NSArray *wifiArray = [[NSArray alloc] init];
    NSString *uploadTime = [self.formatter stringFromDate:[NSDate date]];
    
    NSDictionary *uploadDic = [NSDictionary dictionaryWithObjectsAndKeys:
                               [BLConfigParam sharedConfigParam].sdkLicense , @"license",
                               [BLConfigParam sharedConfigParam].licenseId, @"uid",
                               sign, @"sign",
                               identifier, @"bundle",
                               @"", @"channel",
                               phoneArray, @"app",
                               eventArray, @"event",
                               wifiArray, @"wifi",
                               pageArray, @"page",
                               uploadTime, @"uploadtime",
                               nil];

    NSError *error;
    NSData *uploadData = [NSJSONSerialization dataWithJSONObject:uploadDic options:0 error:&error];
    if (error && result) {
        return;
    }
    
    NSString *uploadStr = [[NSString alloc] initWithData:uploadData encoding:NSUTF8StringEncoding];
    
    [self statisticUpload:uploadStr deleteDidArray:deleteDidArray];
}

#pragma mark ***上传统计数据***
- (void)statisticUpload:(NSString*) uploadStr deleteDidArray:(NSMutableArray*)deleteDidArray {
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    req.URL = [NSURL URLWithString:[self.apiUrls pickUpdateDataURL]];
    
    //获取时间戳
    NSString *timestamp = [self timestamp];
    
    //计算上传数据的md5
    NSString *md5 = [self strMd5:uploadStr timestamp:timestamp];
    
    //设置头
    [req setValue:md5 forHTTPHeaderField:@"Signature"];
    [req setValue:timestamp forHTTPHeaderField:@"Timestamp"];
    [req setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    [req setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    
    //设置内容
    NSError *err;
    NSData *gzipData = [self compressStr:uploadStr error:&err];
    if(err != nil){
            BLLogError(@"%@",err.localizedDescription);
    }
    req.HTTPBody = gzipData;
    
    //方法
    req.HTTPMethod = @"POST";
    
    //超时
    [req setTimeoutInterval:10.0f];//若10秒钟连不上服务器， 则超时
    
    //任务
    //NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    BLLogDebug(@"%@",req.URL);
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask  *task =  [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable err) {
        typeof(self) strongSelf = weakSelf;
        if (strongSelf){
            [weakSelf uploadResultHandler:data response:response error:err deleteDidArray:deleteDidArray];
        }
    }];
    
    //执行
    [task resume];
}

- (void)uploadResultHandler: (NSData * _Nullable) data response:(NSURLResponse * _Nullable)res error:( NSError * _Nullable)err
                 deleteDidArray:(NSMutableArray*)deleteDidArray {
        if ((err == nil) && (((NSHTTPURLResponse*)res).statusCode == 200)){
            
            
            BLLogDebug(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSError *err;
            //json->dic
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err];
            
            if (err != nil){
                BLLogError(@"1upload err: %@", err.localizedDescription);
                return;
            }
            
            //
            if ([res[@"code"] intValue] == 0){
                BLLogDebug(@"upload return code : %d", [res[@"code"] intValue]);
                NSMutableArray *transactionSql = [NSMutableArray array];
                for (NSNumber *didNum in deleteDidArray)
                {
                    NSString *sqlStr = [self deleteSqlWithDid:[didNum intValue]];
                    [transactionSql addObject:sqlStr];
                }
                dispatch_sync(_queue, ^{
                    [self execInsertTransactionSql:transactionSql];
                });
            }else{
                NSString *msg = [res objectForKey:@"msg"];
                BLLogError(@"2upload err: %@",msg);
            }
            
        }else{
            BLLogError(@"3upload err: %@", err.localizedDescription);
            return;
        }
    
    return ;
}


- (NSString*)timestamp{
    NSDate *date = [NSDate date];
    return  [NSString stringWithFormat:@"%lld", (unsigned long long)[date timeIntervalSince1970]];
}

- (NSString *)strMd5:(NSString *)str timestamp:(NSString*)timestamp{
    NSMutableString *md5Str = [NSMutableString stringWithString:str];
    [md5Str appendString:@"^&*%Y$#"];
    [md5Str appendString:timestamp];
    
    return [self md5:md5Str];
    
}

- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (uint32_t)strlen(cStr), result);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

- (void) uploadData {
    [self finish:nil];
}

#pragma mark ***数据压缩***
- (NSData *)compressStr:(NSString *)str error:(NSError **)err{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [self compressBytes:(Bytef*)[data bytes] length:[data length] error:err];
}

- (NSData *)compressData:(NSData *)data error:(NSError **)err{
    return [self compressBytes:(Bytef*)[data bytes] length:[data length] error:err];
}

- (NSData *)compressBytes:(Bytef *) bytes length:(NSUInteger)length error:(NSError **)err
{
	if (length == 0) return nil;
	
	NSUInteger halfLength = length/2;
	
	// We'll take a guess that the compressed data will fit in half the size of the original (ie the max to compress at once is half DATA_CHUNK_SIZE), if not, we'll increase it below
	NSMutableData *outputData = [NSMutableData dataWithLength:length/2]; 
	
	int status;
    BOOL shouldFinish = YES;
	z_stream zStream;
    [self setupStream:&zStream];
	
	zStream.next_in = bytes;
	zStream.avail_in = (unsigned int)length;
	zStream.avail_out = 0;

	NSUInteger bytesProcessedAlready = zStream.total_out;
	while (zStream.avail_out == 0) {
		
		if (zStream.total_out-bytesProcessedAlready >= [outputData length]) {
			[outputData increaseLengthBy:halfLength];
		}
		
		zStream.next_out = (Bytef*)[outputData mutableBytes] + zStream.total_out-bytesProcessedAlready;
		zStream.avail_out = (unsigned int)([outputData length] - (zStream.total_out-bytesProcessedAlready));
		status = deflate(&zStream, shouldFinish ? Z_FINISH : Z_NO_FLUSH);
        
		if (status == Z_STREAM_END) {
			break;
		} else if (status != Z_OK) {
			if (err) {
				*err = [NSError errorWithDomain:@"cn.com.broadlink" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Compression of data failed with code %d",status],NSLocalizedDescriptionKey,nil]];
			}
            
            [self closeStream:&zStream];
            return nil;
		}
	}

	// Set real length
	[outputData setLength: zStream.total_out-bytesProcessedAlready];
    [self closeStream:&zStream];
	return outputData;
}

- (void)setupStream:(z_stream*)zStream
{
    // Setup the inflate stream
    zStream->zalloc = Z_NULL;
    zStream->zfree = Z_NULL;
    zStream->opaque = Z_NULL;
    zStream->avail_in = 0;
    zStream->next_in = 0;
    deflateInit2(zStream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);
}

- (void)closeStream:(z_stream*)zStream
{                   
    deflateEnd(zStream);
}

#pragma mark - property get/set
- (NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _formatter;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] initWithCapacity:20];
    }
    return _dataList;
}

- (NSCache *)pageCache {
    if (!_pageCache) {
        _pageCache = [[NSCache alloc] init];
    }
    return _pageCache;
}

@end
