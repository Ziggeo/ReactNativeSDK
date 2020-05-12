@import Foundation;
@import UIKit;

@implementation RotatingImagePickerController: UIImagePickerController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end
