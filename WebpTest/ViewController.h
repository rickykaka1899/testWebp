//
//  ViewController.h
//  WebpTest
//
//  Created by KakaCompany on 13/1/15.
//  Copyright (c) 2015 KakaCompany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
  
  IBOutlet UILabel *iOriginalLabel;
  IBOutlet UILabel *iConvertLabel;
  IBOutlet UIImageView *iConvertView;
  IBOutlet UIImageView *iNormView;
  IBOutlet UILabel *iNormalLabel;
}
- (IBAction)addPhoto:(id)sender;

@end
