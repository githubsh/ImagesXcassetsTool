//
//  main.m
//  ImagesXcassetsTool
//
//  Created by Steven on 15/12/11.
//  Copyright © 2015年 Steven. All rights reserved.
//

/*
 * Images.xcassets 自动处理图片工具
 * 功能列表:
 * 1.在开发中如果1x,2x,3x图片都使用相同的图片，写入Contents.json自动补图
 * 2.检测项目中完全相同的图片，手动比较删除
 * 3.检测项目中未使用到的图片，机器一键删除
 */

#import <Foundation/Foundation.h>

//  需要特殊的图片
static NSMutableArray *errorArray0 = nil;
static NSMutableArray *errorArray1 = nil;
static NSMutableArray *errorArray2 = nil;
static NSMutableArray *errorArray3 = nil;
static NSMutableArray *errorArray4 = nil;
static NSMutableArray *errorArray5 = nil;
static NSMutableArray *errorArray6 = nil;
static NSMutableArray *errorArray7 = nil;
static NSMutableArray *errorArray8 = nil;
static NSMutableArray *errorArray9 = nil;

//  写入次数
static int writeCount = 0;
//  删除次数
static int delCount = 0;
//  程序启动时间
static NSTimeInterval start = 0;

//  自动补充filename名，用于处理1x2x3x图片使用一副图，重写Contents.json
void autoSupplementFilenameKey(NSString *imagesXcassetsPath);
//  解析Json字典
void resolveJsonDict(NSString *fileName, NSString *filePath, NSDictionary *jsonDict);
//  字典写Json文件
void writeDictToFile(NSString *fileName, NSString *filePath, NSDictionary *writedDict);

//  检查有没有重名文件
void checkDumplicatedImage(NSString *imagesXcassetsPath);
//  检测没有使用到的文件
void checkUnusedImage(NSString *projPath);
//  删除未被使用到的图片
void deleteUnusedImage(NSArray *delPathArray);

NSDictionary *checkDump(NSArray *checkedArray)
{
    NSMutableArray *mCheckedArray = [[NSMutableArray alloc]initWithArray:checkedArray];
    NSMutableArray *mutableArray = [@[] mutableCopy];
    for (int i = 0; i < mCheckedArray.count; i++) {
        NSString *string = mCheckedArray[i];
        NSMutableArray *tempArray = [@[] mutableCopy];
        [tempArray addObject:string];
        for (int j = i+1; j < mCheckedArray.count; j++) {
            NSString *jstring = mCheckedArray[j];
            if([string isEqualToString:jstring]){
                [tempArray addObject:jstring];
            }
        }
        if ([tempArray count] > 1) {
            [mutableArray addObject:tempArray];
            [mCheckedArray removeObjectsInArray:tempArray];
            i--;
        }
    }
    NSLog(@"****************************>>>");
    NSLog(@"重复   %zd组",mutableArray.count);
    NSLog(@"不重复 %zd个",mCheckedArray.count);
    NSLog(@"****************************<<<");
    
    return @{@"dump":mutableArray,
             @"noDump":mCheckedArray};
}

NSString *trimFilePath(NSString *fileName)
{
    if ([fileName containsString:@"/Contents.json"]){
        fileName = [fileName stringByReplacingCharactersInRange:NSMakeRange(fileName.length-14,14) withString:@""];
    }
    
    if ([fileName containsString:@".imageset"]){
        fileName = [fileName stringByReplacingCharactersInRange:NSMakeRange(fileName.length-9,9) withString:@""];
    }
    
    return fileName;
}

NSMutableArray *getArrayKeys(NSArray *array)
{
    NSMutableArray *mArray = [[NSMutableArray alloc]init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    for (id obj in array) {
        [dict setObject:@"" forKey:obj];
    }
    
    [mArray addObjectsFromArray:[dict allKeys]];
    
    return mArray;
}

//  main

int main(int argc, const char * argv[]) {
    @autoreleasepool
    {
        start = [[NSDate date]timeIntervalSince1970];
        
        //  拖动文件到终端cd查询输入完整路径，路径设置要谨慎哦！
        NSString *projPath = [
                              @"/Users/Steven/Documents/OMengClient/OMengClient" stringByExpandingTildeInPath];
        NSString *imagesXcassetsPath = [
                                        @"/Users/Steven/Documents/OMengClient/OMengClient/Images.xcassets" stringByExpandingTildeInPath];
        
        //  自动补充文件名
        ///autoSupplementFilenameKey(imagesXcassetsPath);
        
        //  检查重名文件
        ///checkDumplicatedImage(imagesXcassetsPath);
        
        //  检查项目中未用到的图片
        ///checkUnusedImage(projPath);
        
        NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
        NSLog(@"运行时间=%.2f秒",end-start);//100s左右
    }
    
    return 0;
}

//  自动补充filename名
void autoSupplementFilenameKey(NSString *imagesXcassetsPath)
{
    errorArray0 = [[NSMutableArray alloc]init];
    errorArray1 = [[NSMutableArray alloc]init];
    errorArray2 = [[NSMutableArray alloc]init];
    errorArray3 = [[NSMutableArray alloc]init];
    errorArray4 = [[NSMutableArray alloc]init];
    errorArray5 = [[NSMutableArray alloc]init];
    errorArray6 = [[NSMutableArray alloc]init];
    errorArray7 = [[NSMutableArray alloc]init];
    errorArray8 = [[NSMutableArray alloc]init];
    errorArray9 = [[NSMutableArray alloc]init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:imagesXcassetsPath];
    
    NSMutableArray *files = [NSMutableArray arrayWithCapacity:0];
    NSString *fileName;
    while (fileName = [dirEnum nextObject]) {
        if ([[fileName pathExtension] isEqualTo:@"json"]) {
            [files addObject: fileName];
        }
    }
    NSLog(@"Contents.json文件数=%zd",files.count);
    
    NSEnumerator *fileEnum;
    fileEnum = [files objectEnumerator];
    
    while (fileName = [fileEnum nextObject])
    {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",imagesXcassetsPath,fileName];
        
        NSString *str = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if ([str containsString:@"jpg"] || [str containsString:@"gif"])
        {
            NSLog(@"含非png格式的图片=%@",filePath);
            [errorArray0 addObject:trimFilePath(fileName)];
        }
        
        NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
        
        NSError *error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
        if (error)
        {
            // 不能解析为json的情况，例如有中文“”,要改为英文""
            [errorArray1 addObject:trimFilePath(fileName)];
        }
        else
        {
            //  解析dict
            resolveJsonDict(fileName, filePath, jsonDict);
        }
    }
    
    NSLog(@"\n自动补充图片名时，需要特殊处理的图片如下：");
    NSLog(@"含有非png格式的图片=%@",errorArray0);
    NSLog(@"不能解析为json的情况，例如有中文“”,要改为英文""=%@",errorArray1);
    NSLog(@"目录=%@",errorArray2);
    NSLog(@"含有Unassigned=%@",errorArray3);
    NSLog(@"images数组中的字典包含其他的键=%@",errorArray4);
    NSLog(@"filename键不存在或值为空字符串或>3=%@",errorArray5);
    NSLog(@"filenameKeyCount为2其他错误=%@",errorArray6);
    NSLog(@"有两张一样的很少当错误处理=%@",errorArray7);
    NSLog(@"filenameKeyCount为3其他错误=%@",errorArray8);
    NSLog(@"有两种尺寸的图片正确配置了，不多需要看一下，有可能图片格式不一样=%@",errorArray9);
    
    NSLog(@"自动补充文件名时，机器写文件次数=%zd",writeCount);
}

//  解析Json字典
void resolveJsonDict(NSString *fileName, NSString *filePath, NSDictionary *jsonDict)
{
    NSArray *images = jsonDict[@"images"];
    
    if (images == nil || ![images isKindOfClass:[NSArray class]]) {
        // 目录
        [errorArray2 addObject:trimFilePath(fileName)];
    }
    else if (images.count != 3) {
        // 含有Unassigned
        [errorArray3 addObject:trimFilePath(fileName)];
    }
    else//images && [images isKindOfClass:[NSArray class]] && images.count == 3
    {
        int filenameKeyCount = 0;
        
        for (NSDictionary *dict in images)//for start
        {
            NSMutableArray *allKeys = [[NSMutableArray alloc]initWithArray:[dict allKeys]];
            if ([allKeys containsObject:@"idiom"]) {
                [allKeys removeObject:@"idiom"];
            }
            if ([allKeys containsObject:@"filename"]) {
                [allKeys removeObject:@"filename"];
            }
            if ([allKeys containsObject:@"scale"]) {
                [allKeys removeObject:@"scale"];
            }
            if (allKeys.count != 0) {
                // images数组中的字典包含其他的键
                [errorArray4 addObject:trimFilePath(fileName)];//errorArray4 == nil
            }
            
            NSString *filenameValue = dict[@"filename"];
            if (filenameValue &&
                [filenameValue isKindOfClass:[NSString class]] &&
                ![filenameValue isEqualToString:@""])
            {
                filenameKeyCount ++;
            }
        }// for end
        
        if (filenameKeyCount == 0 || filenameKeyCount > 3) {
            // filename键不存在或值为空字符串或>3
            [errorArray5 addObject:trimFilePath(fileName)];//errorArray5 == nil
        }
        
        //   处理
        if (filenameKeyCount == 1)
        {
            NSString *filenameValue = @"";
            //将一个键filename复制出来写到其他两个键
            for (NSDictionary *dict in images)//for start
            {
                if ([[dict allKeys] containsObject:@"filename"]) {
                    filenameValue = dict[@"filename"];
                    break;
                }
            }
            //写字典
            //NSLog(@"filenameValue=%@",filenameValue);
            ///writeDictToJsonFile(fileName, filePath, jsonDict, filenameValue);//主要是这里需要处理的很多//⭐️
            
            writeCount ++;
            NSMutableDictionary *mJsonDict = [[NSMutableDictionary alloc]initWithDictionary:jsonDict];
            mJsonDict[@"images"] = @[
                                     @{@"idiom" : @"universal",
                                       @"scale" : @"1x",
                                       @"filename" : filenameValue,},
                                     @{@"idiom" : @"universal",
                                       @"scale" : @"2x",
                                       @"filename" : filenameValue,},
                                     @{@"idiom" : @"universal",
                                       @"scale" : @"3x",
                                       @"filename" : filenameValue,},
                                     ];
            writeDictToFile(fileName, filePath, mJsonDict);
        }
        else if (filenameKeyCount == 2)
        {
            NSString *filenameValue1 = images[0][@"filename"];
            NSString *filenameValue2 = images[1][@"filename"];
            NSString *filenameValue3 = images[2][@"filename"];
            
            //比较2个filename键值是否全部相同
            if ( ((filenameValue1==nil || [filenameValue1 isEqualToString:@""]) &&
                  ![filenameValue2 isEqualToString:filenameValue3])
                ||
                ((filenameValue2==nil || [filenameValue2 isEqualToString:@""]) &&
                 ![filenameValue1 isEqualToString:filenameValue3])
                ||
                ((filenameValue3==nil || [filenameValue3 isEqualToString:@""]) &&
                 ![filenameValue1 isEqualToString:filenameValue2])
                )
            {
                //1x 2x有值(相同/不同) 补3x，3x用2x
                if (filenameValue1 && ![filenameValue1 isEqualToString:@""] &&
                    filenameValue2 && ![filenameValue2 isEqualToString:@""])
                {
                    NSRange range1 = [filenameValue1 rangeOfString:@".png"];
                    NSRange range2 = [filenameValue2 rangeOfString:@".png"];
                    NSString *str1 = [filenameValue1 stringByReplacingCharactersInRange:range1 withString:@""];
                    NSString *str2 = [filenameValue2 stringByReplacingCharactersInRange:range2 withString:@""];
                    if (range1.location == filenameValue1.length - 4 &&
                        range2.location == filenameValue2.length - 4 &&
                        [str2 isEqualToString:[NSString stringWithFormat:@"%@@2x",str1]])
                    {
                        writeCount ++;
                        NSMutableDictionary *mJsonDict = [[NSMutableDictionary alloc]initWithDictionary:jsonDict];
                        mJsonDict[@"images"] = @[
                                                 @{@"idiom" : @"universal",
                                                   @"scale" : @"1x",
                                                   @"filename" : filenameValue1,},
                                                 @{@"idiom" : @"universal",
                                                   @"scale" : @"2x",
                                                   @"filename" : filenameValue2,},
                                                 @{@"idiom" : @"universal",
                                                   @"scale" : @"3x",
                                                   @"filename" : filenameValue2,},
                                                 ];
                        writeDictToFile(fileName, filePath, mJsonDict);
                    }
                    else
                    {
                        [errorArray6 addObject:trimFilePath(fileName)];
                    }
                }
                //2x 3x有值(相同/不同)  补1x，1x用2x
                else if (filenameValue2 && ![filenameValue2 isEqualToString:@""] &&
                         filenameValue3 && ![filenameValue3 isEqualToString:@""])
                {
                    NSRange range2 = [filenameValue2 rangeOfString:@"@2x.png"];
                    NSRange range3 = [filenameValue3 rangeOfString:@"@3x.png"];
                    
                    NSString *str2 = @"";
                    NSString *str3 = @"";
                    
                    if (range2.location != NSNotFound &&
                        range3.location != NSNotFound)
                    {
                        str2 = [filenameValue2 stringByReplacingCharactersInRange:range2 withString:@""];
                        str3 = [filenameValue3 stringByReplacingCharactersInRange:range3 withString:@""];
                    }
                    if (![str2 isEqualToString:@""] &&
                        ![str3 isEqualToString:@""] &&
                        range2.location == filenameValue2.length - 7 &&
                        range3.location == filenameValue3.length - 7 &&
                        [str3 isEqualToString:str2])
                    {
                        writeCount ++;
                        NSMutableDictionary *mJsonDict = [[NSMutableDictionary alloc]initWithDictionary:jsonDict];
                        mJsonDict[@"images"] = @[
                                                 @{@"idiom" : @"universal",
                                                   @"scale" : @"1x",
                                                   @"filename" : filenameValue2,},
                                                 @{@"idiom" : @"universal",
                                                   @"scale" : @"2x",
                                                   @"filename" : filenameValue2,},
                                                 @{@"idiom" : @"universal",
                                                   @"scale" : @"3x",
                                                   @"filename" : filenameValue3,},
                                                 ];
                        writeDictToFile(fileName, filePath, mJsonDict);
                    }
                    else
                    {
                        [errorArray6 addObject:trimFilePath(fileName)];
                    }
                }
                else
                {
                    [errorArray6 addObject:trimFilePath(fileName)];//errorArray6 != nil
                }
            }
            //取出键值//写字典(省略)
            else
            {
                NSString *filenameValue = @"";
                if (filenameValue1 && ![filenameValue1 isEqualToString:@""]) {
                    filenameValue = filenameValue1;
                }else if (filenameValue2 && ![filenameValue2 isEqualToString:@""]){
                    filenameValue = filenameValue2;
                }else if (filenameValue3 && ![filenameValue3 isEqualToString:@""]){
                    filenameValue = filenameValue3;
                }
                
                // //  有两张一样的，很少，当错误处理
                [errorArray7 addObject:trimFilePath(fileName)];//errorArray7 != nil
                
                //写字典
                //NSLog(@"filenameValue=%@",filenameValue);
                //writeDictToJsonFile(fileName, filePath, jsonDict, filenameValue);
            }
        }
        else //filenameKeyCount == 3
        {
            //比较3个filename键值是否全部相同
            NSString *filenameValue1 = images[0][@"filename"];
            NSString *filenameValue2 = images[1][@"filename"];
            NSString *filenameValue3 = images[2][@"filename"];
            
            if(filenameValue1==nil ||
               filenameValue2==nil ||
               filenameValue3==nil ||
               [filenameValue1 isEqualToString:@""] ||
               [filenameValue2 isEqualToString:@""] ||
               [filenameValue3 isEqualToString:@""])
            {
                ////
                [errorArray8 addObject:trimFilePath(fileName)];//errorArray8 == nil
            }
            else if (![filenameValue1 isEqualToString:filenameValue2] ||
                     ![filenameValue1 isEqualToString:filenameValue3] ||
                     ![filenameValue2 isEqualToString:filenameValue3])
            {
                ////有两种尺寸的图片，且正确配置了，不是太多，需要看一下，有可能图片格式不一样
                [errorArray9 addObject:trimFilePath(fileName)];//errorArray9 != nil
            }
            else if ([filenameValue1 isEqualToString:filenameValue2] &&
                     [filenameValue1 isEqualToString:filenameValue3] &&
                     [filenameValue2 isEqualToString:filenameValue3] )
            {
                //  3个全部相同的情况
                //NSString *filenameValue = filenameValue1;
                //NSLog(@"filenameValue=%@",filenameValue);//在此检测
                //  写字典,全部是OK的，重写没有用的
                //writeDictToJsonFile(fileName, filePath, jsonDict, filenameValue);
                NSLog(@"🆗%@",trimFilePath(fileName));
            }
        }
    }
}

//  字典写Json文件
void writeDictToFile(NSString *fileName, NSString *filePath, NSDictionary *writedDict)
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:writedDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData || [jsonData length] == 0 || error != nil) {
        NSLog(@"dict转json错误:%@", error);
    }
    else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"jsonString=%@",jsonString);
        
        [jsonString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error){
            NSLog(@"json写文件错误:%@",error.localizedDescription);
        }
    }
}


//  检查有没有重名文件
void checkDumplicatedImage(NSString *imagesXcassetsPath)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:imagesXcassetsPath];
    NSMutableArray *tmDir = [[NSMutableArray alloc]init];
    NSString *fileName;
    while (fileName = [dirEnum nextObject]) {
        if ([[fileName pathExtension] isEqualTo:@"json"]) {
            [tmDir addObject: fileName];
        }
    }
    NSLog(@"tmDir=%@,tmDir.count=%zd",tmDir,tmDir.count);
    
    NSMutableArray *tmpDirs = [[NSMutableArray alloc]init];
    NSString *dir2 = @"";
    for (NSString *dir in tmDir) {
        
        if ([dir containsString:@".imageset"]) {
            dir2 = trimFilePath(dir);
            dir2 = [[dir2 componentsSeparatedByString:@"/"] lastObject];
            [tmpDirs addObject:dir2];
        }
    }
    //NSLog(@"tmpDirs=%@,tmpDirs.count=%zd",tmpDirs,tmpDirs.count);
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    for (int i=0; i<tmpDirs.count; i++) {
        NSString *key = tmpDirs[i];
        if (dic[key]==nil) {
            [dic setObject:@(i) forKey:key];
        }else{
            NSLog(@"重复key=%@",key);
        }
    }
    //NSLog(@"dic=%@,count=%zd",dic,dic.count);
    
    NSMutableArray *mutableArray = [@[] mutableCopy];
    for (int i = 0; i < tmpDirs.count; i ++) {
        NSString *string = tmpDirs[i];
        NSMutableArray *tempArray = [@[] mutableCopy];
        [tempArray addObject:string];
        for (int j = i+1; j < tmpDirs.count; j++) {
            NSString *jstring = tmpDirs[j];
            if([string isEqualToString:jstring]){
                [tempArray addObject:jstring];
            }
        }
        if ([tempArray count] > 1) {
            [mutableArray addObject:tempArray];
            [tmpDirs removeObjectsInArray:tempArray];
            i --;//去除重复数据 新数组开始遍历位置不变
        }
    }
    //NSLog(@"可能重名的文件/目录:%@,count=%zd",mutableArray,mutableArray.count);
    
    NSMutableArray *mAr = [[NSMutableArray alloc]init];//含有一个目录的
    for (NSArray *ar in mutableArray) {
        NSMutableArray *tmpAr = [NSMutableArray arrayWithArray:ar];
        for (NSString *s in tmDir) {
            if ([s containsString:[NSString stringWithFormat:@"%@/Contents.json",ar[0]]]) {
                [mAr addObject:tmpAr];
            }
        }
    }
    //NSLog(@"同名但是有一个是目录的数目=%zd",mAr.count);
    
    for (int i=0; i<mAr.count;i++) {
        NSArray *a = mAr[i];
        if (a.count == 2) {
            [mutableArray removeObject:a];
        }
    }
    
    NSLog(@"文件重名数:%@,count=%zd",mutableArray,mutableArray.count);
}


//  检测没有使用到的文件
void checkUnusedImage(NSString *projPath)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:projPath];
    NSMutableArray *tmDir = [[NSMutableArray alloc]init];
    NSString *fileName = @"";
    NSMutableDictionary *pathExtensionDict = [[NSMutableDictionary alloc]init];
    
    while (fileName = [dirEnum nextObject])
    {
        [pathExtensionDict setObject:@"" forKey:[fileName pathExtension]];
        
        if ([[fileName pathExtension] isEqualTo:@"h"] ||
            [[fileName pathExtension] isEqualTo:@"m"] ||
            [[fileName pathExtension] isEqualTo:@"mm"] ||
            [[fileName pathExtension] isEqualTo:@"c"] ||
            [[fileName pathExtension] isEqualTo:@"cpp"] ||
            [[fileName pathExtension] isEqualTo:@"pch"] ||
            [[fileName pathExtension] isEqualTo:@"xib"] ||
            [[fileName pathExtension] isEqualTo:@"storyboard"]
            )
        {
            [tmDir addObject:fileName];
        }
    }
    NSLog(@"pathExtension=%@",[pathExtensionDict allKeys]);
    
    NSString *fileFullPath = @"";
    NSMutableString *fileContent = [[NSMutableString alloc]init];
    for (NSString *s in tmDir) {
        fileFullPath = [NSString stringWithFormat:@"%@/%@",projPath,s];
        NSError *error;
        NSString *s = [NSString stringWithContentsOfFile:fileFullPath encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"读文件失败error=%@",error.localizedDescription);
        }else{
            [fileContent appendString:s];
        }
    }
    NSLog(@"文件内容长度=%.2f",(double)fileContent.length);
    
    dirEnum = [fileManager enumeratorAtPath:projPath];
    tmDir = [[NSMutableArray alloc]init];
    fileName = @"";
    while (fileName = [dirEnum nextObject]) {
        if ([[fileName pathExtension] isEqualTo:@"json"]) {
            [tmDir addObject: fileName];
        }
    }
    NSLog(@"json文件数目=%zd",tmDir.count);
    
    NSMutableArray *usedImagesetName = [[NSMutableArray alloc]init];
    NSMutableArray *unusedImagesetName = [[NSMutableArray alloc]init];
    NSMutableArray *directory = [[NSMutableArray alloc]init];
    NSMutableArray *delPathArray = [[NSMutableArray alloc]init];
    
    for (NSString *aTmDir in tmDir)
    {
        if ([aTmDir containsString:@".imageset"])
        {
            NSString *name = [[trimFilePath(aTmDir) componentsSeparatedByString:@"/"] lastObject];
            if ([fileContent containsString:name])
            {
                [usedImagesetName addObject:name];
            }
            else //未被使用的图片名字
            {
                [unusedImagesetName addObject:name];
                
                ///有的名字虽然未被使用，但在路径上却能找到多个
                if ([aTmDir containsString:[NSString stringWithFormat:@"/%@.imageset/Contents.json",name]])//图片imageset
                {
                    NSString *imagesetPath = [aTmDir stringByReplacingCharactersInRange:NSMakeRange(aTmDir.length-14, 14) withString:@""];
                    [delPathArray addObject:[NSString stringWithFormat:@"%@/%@",projPath,imagesetPath]];
                }
            }
        }
        else
        {
            [directory addObject:aTmDir];//目录（重复不检测）
        }
        NSLog(@"图片使用情况...正在检测中...执行时间=%.2f秒",[[NSDate date] timeIntervalSince1970]-start);
    }
    
    NSLog(@"总路径数=%zd",tmDir.count);
    NSLog(@"已使用=%zd",usedImagesetName.count);
    NSLog(@"未使用=%zd",unusedImagesetName.count);
    NSLog(@"目录=%zd",directory.count);
    NSLog(@"已使用+未使用+目录=%zd",(int)(usedImagesetName.count + unusedImagesetName.count + directory.count));
    NSLog(@"未使用占比=%.2f%%",(double)unusedImagesetName.count/(usedImagesetName.count + unusedImagesetName.count) *100);
    NSLog(@"要删除的文件的路径总数 = %zd",delPathArray.count);
    NSLog(@"要删除的文件的路径数去重复 = %zd",getArrayKeys(delPathArray).count);
    
    //  删除未被使用到的图片
    //deleteUnusedImage(getArrayKeys(delPathArray));
}

//  删除未被使用到的图片
#warning 用字符串格式化的图片名检测不到，也会被加入删除列表中，需要补上
void deleteUnusedImage(NSArray *delPathArray)
{
    NSLog(@"正在删除文件中...");
    NSMutableArray *errorArr = [[NSMutableArray alloc]init];
    for (NSString *path in delPathArray)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        [fileManager removeItemAtPath:path error:&error];
        if (error)
        {
            NSLog(@"删除文件失败%@,path=%@",error.localizedDescription,path);
            [errorArr addObject:error.localizedDescription];
        }
        else
        {
            //  删除文件成功
            delCount ++;
        }
    }
    if (errorArr.count != 0){
        NSLog(@"errorArr=%@",errorArr);
    }
    NSLog(@"机器删文件次数=%zd",delCount);
}

//end
