//
//  ViewController.m
//  WebpTest
//
//  Created by KakaCompany on 13/1/15.
//  Copyright (c) 2015 KakaCompany. All rights reserved.
//

#import "ViewController.h"
#import "WAImgCompressUtil.h"
#import "UIImage+WebP.h"

@interface ViewController ()

@end

static CGFloat quality = 75.0f;
static CGFloat alpha = 1.0f;

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
//  NSUInteger i = 0;
////  NSUInteger k = 1;
//  int j = i - 1;
//  if (j > 0)
//  {
//    NSLog(@">");
//  }
//  NSLog(@"j: %lu",j);
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)addPhoto:(id)sender
{
  UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"本地",nil];
  [sheet showInView:self.view];
  [sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 0)
  {
    [self takePhoto];
  }
  else if(buttonIndex == 1)
  {
    [self chooseFromLocal];
  }
}

- (void)takePhoto
{
  UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
  if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
  {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //设置拍照后的图片可被编辑
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
    [picker release];
  }else
  {
    NSLog(@"模拟其中无法打开照相机,请在真机中使用");
  }
}

- (void)chooseFromLocal
{
  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
  
  picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  picker.delegate = self;
  //设置选择后的图片可被编辑
  picker.allowsEditing = YES;
  [self presentViewController:picker animated:YES completion:nil];
  [picker release];
}

//CGImageRef

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
  NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
  //当选择的类型是图片
  if ([type isEqualToString:@"public.image"])
  {
    UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
//    [self writeToPhotoAlbum:image];
    NSData *data75 = UIImageJPEGRepresentation(image, 0.75f);
    [self writeToPhotoAlbum:[UIImage imageWithData:data75]];
    NSData *originaldata = UIImageJPEGRepresentation([UIImage imageWithData:data75], 1.0f);
    [self writeToPhotoAlbum:[UIImage imageWithData:originaldata]];
    [picker dismissViewControllerAnimated:YES completion:nil];

    NSURL *imageurl = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    NSString *typestr = [imageurl absoluteString];
    NSString *imageType = nil;
//    //本地读取，png格式
//    if ([typestr containsString:@"png"] || [typestr containsString:@"PNG"])
//    {
//      imageType = @"png";
//    }
//    //本地读取，jpg格式
//    if ([typestr containsString:@"jpg"] || [typestr containsString:@"JPG"])
//    {
//      imageType = @"jpg";
//    }
//    //本地读取，gif格式
//    if ([typestr containsString:@"gif"] || [typestr containsString:@"GIF"])
//    {
//      imageType = @"gif";
//    }
//    //来自拍照，jpg格式
//    if (!typestr)
//    {
      imageType = @"jpg";
//    }

    NSDate *datenow = [NSDate date];
    NSString *nowtimeStr = [NSString stringWithFormat:@"%f",[datenow timeIntervalSinceReferenceDate]];
    //执行方案A，先压缩再转换为webp
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//      [self normalThenWebpCompress:[UIImage imageWithData:originaldata]
//                      withFileName:[nowtimeStr substringToIndex:9]
//                      andPhotoType:imageType];
//    });
//    //执行方案B，直接转为webp
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//      [self newWebpCompress:[UIImage imageWithData:originaldata]
//               withFileName:[nowtimeStr substringToIndex:9]];
//    });
//    //原图保存
//    NSString *originalPath = [[self filePath:[nowtimeStr substringToIndex:9]]stringByAppendingPathComponent:[NSString stringWithFormat:@"originalimage.%@",imageType]];
//    if([originaldata writeToFile:originalPath atomically:YES])
//    {
//      uint64_t originalFileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:originalPath error:nil] fileSize];
//      [iOriginalLabel setText:[NSString stringWithFormat:@"%@图大小: %.2fMB",imageType,(double)originalFileSize/1024.0/1024.0]];
//    }
    
  }
}

- (void)writeToPhotoAlbum:(UIImage *)aImage
{
  UIImageWriteToSavedPhotosAlbum(aImage, nil, nil, nil);
}
//先执行压缩，再进行webp压缩
- (void)normalThenWebpCompress:(UIImage *)aImage withFileName:(NSString *)aFilename andPhotoType:(NSString *)photoType
{
  NSDate *firstDate = [NSDate date];
  NSData *firstData = [CWAImgCompressUtil compressImageWAStyle:aImage];
  NSString *firstTime = [self compareCurrentTime:firstDate];
  //压缩后写入
  NSString *firstPath = [[self filePath:aFilename]stringByAppendingPathComponent:[NSString stringWithFormat:@"compressimage.%@",photoType]];
  uint64_t firstfileSize = 0;
  if ([firstData writeToFile:firstPath atomically:YES])
  {
    firstfileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:firstPath error:nil] fileSize];
  }
  NSDate *secondDate = [NSDate date];
  [UIImage imageToWebP:[UIImage imageWithData:firstData] quality:quality alpha:alpha preset:WEBP_PRESET_PHOTO
       completionBlock:^(NSData *result) {
         NSString *secondTime = [self compareCurrentTime:secondDate];
         UIImage *secondImage = [UIImage imageWithWebPData:result];
         NSString *webPPath = [[self filePath:aFilename]stringByAppendingPathComponent:@"image.webp"];
         
         if ([result writeToFile:webPPath atomically:YES]) {
           uint64_t fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:webPPath error:nil] fileSize];
           dispatch_async(dispatch_get_main_queue(), ^{
             [iNormView setImage:secondImage];
             [iNormalLabel setText:[NSString stringWithFormat:@"Size1:%.2f KB, Size2:%.2f KB, Time1:%@, Time2:%@ ",(double)firstfileSize/1024, (double)fileSize/1024,firstTime,secondTime]];
           });
           
         }
       } failureBlock:^(NSError *error) {
         
       }];
  
}

//原图进行webp压缩
- (void)newWebpCompress:(UIImage *)aImage withFileName:(NSString *)aFilename
{
  NSDate *timenow = [NSDate date];
  [UIImage imageToWebP:aImage quality:quality alpha:alpha preset:WEBP_PRESET_PHOTO
       completionBlock:^(NSData *result) {
         NSString *timefull = [self compareCurrentTime:timenow];
         UIImage *secondImage = [UIImage imageWithWebPData:result];
         NSString *webPPath = [[self filePath:aFilename]stringByAppendingPathComponent:@"newimage.webp"];
         if ([result writeToFile:webPPath atomically:YES]) {
           uint64_t fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:webPPath error:nil] fileSize];
           dispatch_async(dispatch_get_main_queue(), ^{
             [iConvertView setImage:secondImage];
             [iConvertLabel setText:[NSString stringWithFormat:@"File size: %.2f KB, Time:%@", (double)fileSize/1024,timefull]];
           });
         }
       } failureBlock:^(NSError *error) {
         
       }];
}

//由时间戳创建文件夹
- (NSString *)filePath:(NSString *)timestr
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *webPPath = [paths[0] stringByAppendingPathComponent:timestr];
  //  createfile
  [[NSFileManager defaultManager]createDirectoryAtPath:webPPath withIntermediateDirectories:YES attributes:nil error:nil];
  return webPPath;
}

//计算时间差
- (NSString *) compareCurrentTime:(NSDate*) compareDate
{
  NSTimeInterval  timeInterval = [compareDate timeIntervalSinceNow];
  timeInterval = -timeInterval;
  NSString *result = [NSString stringWithFormat:@"%.3fs",timeInterval];
  return  result;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  NSLog(@"您取消了选择图片");
  [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)dealloc
{
  [iNormView release];
  [iConvertView release];
  [iNormalLabel release];
  [iConvertLabel release];
  [iOriginalLabel release];
  [super dealloc];
}
@end
