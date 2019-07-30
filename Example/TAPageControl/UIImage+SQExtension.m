//
//  UIImage+Extension.m
//  BasicFramework
//
//  Created by Rainy on 16/10/26.
//  Copyright © 2016年 Rainy. All rights reserved.
//

#import "UIImage+SQExtension.h"

@import Accelerate;

static UIImage *_img = nil;

@implementation UIImage (SQExtension)

#pragma mark -- 识别图片中的二维码
-(BOOL)HaveQRCode
{
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:self.CGImage]];
    if (features.count >=1) {
        
//        *结果对象
//        CIQRCodeFeature *feature = [features objectAtIndex:0];
//        NSString *scannedResult = feature.messageString;
//        if (scannedResult) {
//            NSString *contents = scannedResult;
//            if ([contents containsString:@"http://"]) {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:contents]];
//            }else{
//                NSLog(@"扫描结果：%@",contents);
//            }
//        }
        
        return YES;
    }
    else{
        
        
        return NO;
    }
}

#pragma mark -- 读取图片
+(UIImage *)sq_imageNamed:(NSString *)IMGName InBundleNamed:(NSString *)BundleName
{
    
    NSString * bundlePath = [[ NSBundle mainBundle] pathForResource: BundleName ofType:@"bundle"];
    NSString *imgPath= [bundlePath stringByAppendingPathComponent:IMGName];
    return [UIImage imageWithContentsOfFile:imgPath];
    
}

+ (UIImage *)sq_imageWithName:(NSString *)imageName withRenderingMode:(UIImageRenderingMode)imageRenderingMode {
    UIImage *image = [UIImage imageNamed:imageName];
    image = [image imageWithRenderingMode:imageRenderingMode];
    return image;
}
#pragma mark -- resize
+ (UIImage *)sq_resizedImage:(NSString *)name
{
    return [self sq_resizedImage:name left:0.5 top:0.5];
}

+ (UIImage *)sq_resizedImage:(NSString *)name left:(CGFloat)left top:(CGFloat)top
{
    UIImage *image = [self imageNamed:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width * left topCapHeight:image.size.height * top];
}

- (UIImage*)sq_scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    _img = self;
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}
//UIImage自定长宽缩放
+(UIImage *)sq_reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
    
}

//UIImage等比例缩放
+(UIImage *)sq_scaleImage:(UIImage *)image toScale:(CGFloat)scale
{
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scale, image.size.height * scale));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scale, image.size.height * scale)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
}

+(UIImage *)sq_compressImage:(UIImage *)sourceImage toTargetWidth:(CGFloat)defineWidth
{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        
        NSAssert(!newImage,@"图片压缩失败");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}
//压缩图片至内存长度
+ (NSData *)sq_compressImage:(UIImage *)image toDataLength:(CGFloat)length
{
    CGFloat i = 1.0;
    
    // 将image转为data，第二个参数为图片压缩系数
    NSData *data = UIImageJPEGRepresentation(image, i);
    
//    DLog(@"原始图片大小%likb", data.length / 1000)
    
    while (data.length / 1000 >= length) {
        // 若最小压缩比例下仍大于目标大小，直接采用最小压缩比例
        if (UIImageJPEGRepresentation(image, 0.1) .length / 1000 >= length) {
            data = UIImageJPEGRepresentation(image, 0.1);
            break;
        }
        
        i -= 0.2;
        
        if (i < 0.2) {
            // 最小压缩比例0.1
            data = UIImageJPEGRepresentation(image, 0.1);
            break;
        }
        
        data = UIImageJPEGRepresentation(image, i);
//        DLog(@"压缩比例%f，压缩后图片大小%likb", i, data.length / 1000)
    }
    
//    DLog(@"压缩完图片大小%likb", data.length / 1000)
    
    return data;
}

+ (NSData *)getThumbnail:(UIImage *)image
{
    // 生成缩略图（宽度缩至120）
    if (image.size.width > 120) {
//        DLog(@"宽度缩小至120")
        image = [self sq_compressImage:image toTargetWidth:120.0];
    }
    
    // 压缩到50kb以内
    return [self sq_compressImage:image toDataLength:50];
}

#pragma mark restore image to befor
-(UIImage *)sq_restoreMyimage
{
    return _img;
}

#pragma mark-- 裁剪圆形图片
+ (UIImage *)sq_roundBezierImage:(UIImage *)image
{
    //开启上下文
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    //画圆：正切于上下文
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    //设为裁剪区域
    [path addClip];
    //画图片
    [image drawAtPoint:CGPointZero];
    //生成一个新的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

/**
 *  图片剪切为圆形
 *  @return 剪切后的圆形图片
 */
+ (UIImage *)sq_roundImage{
    return [self sq_roundImage];
}
- (UIImage *)sq_roundImage{
    
    //获取size
    CGSize size = [self sq_sizeFromImage:self];
    
    CGRect rect = (CGRect){CGPointZero,size};
    
    //新建一个图片图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    //获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //绘制圆形路径
    CGContextAddEllipseInRect(ctx, rect);
    
    //剪裁上下文
    CGContextClip(ctx);
    
    //绘制图片
    [self drawInRect:rect];
    
    //取出图片
    UIImage *roundImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //结束上下文
    UIGraphicsEndImageContext();
    
    return roundImage;
}

/**
 *  将image转换为圆型带边框的图片（最好写一个UIImage的类扩展）
 *
 *  @param name        图片的名字
 *  @param borderWidth 外层边框的宽度
 *  @param borderColor 外层边框的颜色
 *
 *  @return 返回已经处理好的圆形图片
 */
+ (UIImage *)sq_circleImageWithName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    // 1.加载原图
    UIImage *oldImage = [UIImage imageNamed:name];
    
    return [self sq_circleImageWithImage:oldImage borderWidth:borderWidth borderColor:borderColor];
}
+ (UIImage *)sq_circleImageWithImage:(UIImage *)oldImage borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor{
    
    // 2.开启上下文
    CGFloat imageW = oldImage.size.width + 2 * borderWidth;
    CGFloat imageH = oldImage.size.height + 2 * borderWidth;
    CGSize imageSize = CGSizeMake(imageW, imageH);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    // 3.取得当前的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 4.画边框(大圆)
    [borderColor set];
    CGFloat diameter = imageW > imageH ? imageH : imageW;
    CGFloat bigRadius = diameter * 0.5; // 大圆半径
    CGFloat centerX = bigRadius; // 圆心
    CGFloat centerY = bigRadius;
    CGContextAddArc(ctx, centerX, centerY, bigRadius, 0, M_PI * 2, 0);
    CGContextFillPath(ctx); // 画圆
    
    // 5.小圆
    CGFloat smallRadius = bigRadius - borderWidth;
    CGContextAddArc(ctx, centerX, centerY, smallRadius, 0, M_PI * 2, 0);
    // 裁剪(后面画的东西才会受裁剪的影响)
    CGContextClip(ctx);
    
    // 6.画图
    [oldImage drawInRect:CGRectMake(borderWidth, borderWidth, oldImage.size.width, oldImage.size.height)];
    
    // 7.取图
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 8.结束上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

/**我创建了一个分类用于创建相应的遮罩图片*/

/**提供一个在一个指定的size中绘制图片的便捷方法*/
+ (UIImage *)sq_imageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef context))drawBlock {
    if (!drawBlock) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return nil;
    drawBlock(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**绘制方法的具体逻辑，遮罩图片的逻辑是绘制一个矩形，然后在绘制一个相应的圆角矩形，然后填充矩形和圆角矩形的中间部分为父视图的背景色*/
+ (UIImage *)sq_circleImageRoundCornerRadiusImageWithColor:(UIColor *)color cornerRadii:(CGSize)cornerRadii size:(CGSize)size corners:(UIRectCorner)corners borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth{
    return [UIImage sq_imageWithSize:size drawBlock:^(CGContextRef  _Nonnull context) {
        CGContextSetLineWidth(context, 0);
        [color set];
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        //绘制一个矩形，这里发-0.3是为了防止边缘的锯齿，
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:CGRectInset(rect, -0.3, -0.3)];
        //绘制圆角矩形，这里的0.3是为了防止内边框的锯齿
        UIBezierPath *roundPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 0.3, 0.3) byRoundingCorners:corners cornerRadii:cornerRadii];
        [rectPath appendPath:roundPath];
        CGContextAddPath(context, rectPath.CGPath);
        //注意要用EOFill方式进行填充而非Fill方式
        CGContextEOFillPath(context);
        //如下是绘制边框，原理依旧是绘制一个外边框然后根据边框宽度绘制一个内边框同样采取EOFill的方式进行填充即可
        if (!borderColor || !borderWidth) return;
        [borderColor set];
        UIBezierPath *borderOutterPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:cornerRadii];
        UIBezierPath *borderInnerPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, borderWidth, borderWidth) byRoundingCorners:corners cornerRadii:cornerRadii];
        [borderOutterPath appendPath:borderInnerPath];
        CGContextAddPath(context, borderOutterPath.CGPath);
        CGContextEOFillPath(context);
    }];
}
- (CGSize)sq_sizeFromImage:(UIImage *)image{
    
    CGSize size = image.size;
    
    CGFloat wh =MIN(size.width, size.height);
    
    return CGSizeMake(wh, wh);
}


#pragma mark-- 修正图片方向
/**
 *  修正图片方向
 *
 *  @return 修改后的图片
 */
- (UIImage *)sq_fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
//图片旋转到指定角度
- (UIImage*)sq_image_RotatedByAngle:(CGFloat)Angle
{
    
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    CGSize rotatedSize;
    
    rotatedSize.width = width;
    rotatedSize.height = height;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    CGContextRotateCTM(bitmap, Angle * M_PI / 180); //* M_PI / 180
    CGContextRotateCTM(bitmap, M_PI);
    CGContextScaleCTM(bitmap, -1.0, 1.0);
    CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
/**
 *  旋转图片
 *
 *  @param isHorizontal 方向
 *
 *  @return 结果图片
 */
- (UIImage *)sq_image_RotatedByFlip:(BOOL)isHorizontal {
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClipToRect(ctx, rect);
    if (isHorizontal) {
        CGContextRotateCTM(ctx, M_PI); // 旋转
        CGContextTranslateCTM(ctx, -rect.size.width, -rect.size.height);// 平移
    }
    CGContextDrawImage(ctx, rect, self.CGImage);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
#pragma mark -- color -> image
//UIColor 转UIImage
+ (UIImage*)sq_imageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
/**
 *  返回指定颜色生成的图片
 *
 *  @param color 颜色
 *  @param size  尺寸
 *
 *  @return img
 */
+ (UIImage *)sq_imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
/**
 *  获取指定尺寸（50*50）的图片
 *
 *  @param color 图片颜色
 *  @param name  文本,居中显示
 *
 *  @return img
 */
+ (UIImage *)sq_imageWithColor:(UIColor *)color text:(NSString *)name
{
    CGRect rect = CGRectMake(0, 0, 50, 50);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    [name drawAtPoint:CGPointMake(10, 15) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
/**
 *  获取指定尺寸（size）的图片
 *
 *  @param color 图片颜色
 *  @param name  文本,居中显示
 *
 *  @return img
 */
+ (UIImage *)sq_imageWithColor:(UIColor *)color text:(NSString *)name andImageSize:(CGSize)imageSize
{
    CGRect rect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    NSDictionary *dict=@{NSFontAttributeName : [UIFont systemFontOfSize:15]};
    CGRect nameRect = [name boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dict context:nil];
    CGSize nameSize = CGSizeMake(ceil(CGRectGetWidth(nameRect)), ceil(CGRectGetHeight(nameRect)));
    CGFloat originX = (imageSize.width - nameSize.width)/2.0;
    CGFloat originY = (imageSize.height - nameSize.height)/2.0;
    CGPoint origin = CGPointMake(originX, originY);
    [name drawAtPoint:origin withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
/**
 *  获取指定尺寸（size）的图片
 *
 *  @param color 图片颜色
 *  @param name  文本,居中显示
 *  @param textfont  文本,字体大小
 *  @param imageSize 图片尺寸
 *  @return img
 */
+ (UIImage *)sq_imageWithColor:(UIColor *)color text:(NSString *)name textFont:(UIFont *)textfont andImageSize:(CGSize)imageSize
{
    CGRect rect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    NSDictionary *dict=@{NSFontAttributeName : textfont};
    CGRect nameRect = [name boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dict context:nil];
    CGSize nameSize = CGSizeMake(ceil(CGRectGetWidth(nameRect)), ceil(CGRectGetHeight(nameRect)));
    CGFloat originX = (imageSize.width - nameSize.width)/2.0;
    CGFloat originY = (imageSize.height - nameSize.height)/2.0;
    CGPoint origin = CGPointMake(originX, originY);
    [name drawAtPoint:origin withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
- (UIImage *)sq_imageWithColorFitToScale:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//圆形的[用颜色生成]
+ (UIImage *)sq_ImageRoundWithColor:(UIColor *)color size:(CGSize)size radius:(CGFloat)radius{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    CGContextAddPath(context, path.CGPath);
    CGContextFillPath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
//圆形带边框[用颜色生成]
+ (UIImage *)sq_ImageRoundWithSize:(CGFloat)size fillColor:(UIColor *)fillColor borderWith:(CGFloat)borderWidth borderColor:(UIColor *)borderColor{
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(nil,size,size,8,0, colorSpace,kCGImageAlphaPremultipliedLast);
    
    CFRelease(colorSpace);
    CGContextBeginPath(context);
    
    CGColorRef strokeCGColor = borderColor.CGColor;
    CGContextSetFillColor(context, CGColorGetComponents(strokeCGColor));
    
    CGContextAddArc(context, size/2.0, size/2.0, size/2.0, 0, 2 * M_PI, 1);
    CGContextFillPath(context);
    
    CGColorRef fillCGColor = fillColor.CGColor;
    CGContextSetFillColor(context, CGColorGetComponents(fillCGColor));
    
    CGContextAddArc(context, size/2.0, size/2.0, size/2.0 - 1, 0, 2 * M_PI, 1);
    
    //    　　CGContextClosePath(context);
    
    CGContextFillPath(context);
    
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    
    UIImage* image2 = [UIImage imageWithCGImage:image];
    return image2;
}

#pragma mark-- 截屏
+ (UIImage *)sq_imageFromShortScrollView:(UIScrollView *)scrollView{
    UIImage* image = nil;
    UIGraphicsBeginImageContext(scrollView.contentSize);
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    
    if (image != nil) {
        return image;
    }
    return nil;
}
+ (UIImage *)sq_imageFromView:(UIView *)theView
{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
/**
 *  从给定UIImage和指定Frame截图：
 */
- (UIImage *)sq_imageCutWithFrame:(CGRect)frame{
    
    //创建CGImage
    CGImageRef cgimage = CGImageCreateWithImageInRect(self.CGImage, frame);
    
    //创建image
    UIImage *newImage=[UIImage imageWithCGImage:cgimage];
    
    //释放CGImage
    CGImageRelease(cgimage);
    
    return newImage;
}
/*
 *  直接截屏
 */
+ (UIImage *)sq_imageFromScreen{
    return [self sq_imageFromView:[UIApplication sharedApplication].keyWindow];
}
+ (UIImage *)sq_imageFromLongScrollView:(UIScrollView *)scrollView
{
    // 1.获取WebView的宽高
    CGSize boundsSize = scrollView.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    // 2.获取contentSize
    CGSize contentSize = scrollView.contentSize;
    CGFloat contentHeight = contentSize.height;
    // 3.保存原始偏移量，便于截图后复位
    CGPoint offset = scrollView.contentOffset;
    // 4.设置最初的偏移量为(0,0);
    [scrollView setContentOffset:CGPointMake(0, 0)];
    
    NSMutableArray *images = [NSMutableArray array];
    while (contentHeight > 0) {
        // 5.获取CGContext 5.获取CGContext
        UIGraphicsBeginImageContextWithOptions(boundsSize, NO, 0.0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        // 6.渲染要截取的区域
        [scrollView.layer renderInContext:ctx];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // 7.截取的图片保存起来
        [images addObject:image];
        
        CGFloat offsetY = scrollView.contentOffset.y;
        [scrollView setContentOffset:CGPointMake(0, offsetY + boundsHeight)];
        contentHeight -= boundsHeight;
    }
    // 8 webView 恢复到之前的显示区域
    [scrollView setContentOffset:offset];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize imageSize = CGSizeMake(contentSize.width * scale,
                                  contentSize.height * scale);
    // 9.根据设备的分辨率重新绘制、拼接成完整清晰图片
    UIGraphicsBeginImageContext(imageSize);
    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
        [image drawInRect:CGRectMake(0,scale * boundsHeight * idx,scale * boundsWidth,scale * boundsHeight)];
    }];
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return fullImage;
}




- (UIImage *)sq_blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if ((blur < 0.0f) || (blur > 1.0f)) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
                                       0, 0, boxSize, boxSize, NULL,
                                       kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}




/**
 *  @brief  取图片某一点的颜色
 *
 *  @param point 某一点
 *
 *  @return 颜色
 */
- (UIColor *)sq_colorAtPoint:(CGPoint )point
{
    if (point.x < 0 || point.y < 0) return nil;
    
    CGImageRef imageRef = self.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    if (point.x >= width || point.y >= height) return nil;
    
    unsigned char *rawData = malloc(height * width * 4);
    if (!rawData) return nil;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast
                                                 | kCGBitmapByteOrder32Big);
    if (!context) {
        free(rawData);
        return nil;
    }
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    int byteIndex = (bytesPerRow * point.y) + point.x * bytesPerPixel;
    CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
    CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
    CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
    CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
    
    UIColor *result = nil;
    result = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    free(rawData);
    return result;
}
/**
 *  @brief  取某一像素的颜色
 *
 *  @param point 一像素
 *
 *  @return 颜色
 */
- (UIColor *)sq_colorAtPixel:(CGPoint)point
{
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point)) {
        return nil;
    }
    
    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    // Reference: http://stackoverflow.com/questions/1042830/retrieving-a-pixel-alpha-value-for-a-uiimage
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
#pragma mark - 变灰
/**
 *  @brief  获得灰度图
 *
 *  @param sourceImage 图片
 *
 *  @return 获得灰度图片
 */

+ (UIImage*)sq_grayImageWithImage:(UIImage*)sourceImage
{
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,width,height,8,0,colorSpace,kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) {
        return nil;
    }
    
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), sourceImage.CGImage);
    CGImageRef contextRef = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:contextRef];
    CGContextRelease(context);
    CGImageRelease(contextRef);
    
    return grayImage;
}

+ (UIImage *)sq_grayImageWithImage:(UIImage *)sourceImage type:(int)type
{
    CGImageRef imageRef = sourceImage.CGImage;
    
    size_t width  = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
    
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    bool shouldInterpolate = CGImageGetShouldInterpolate(imageRef);
    
    CGColorRenderingIntent intent = CGImageGetRenderingIntent(imageRef);
    
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    
    if (data) {
        UInt8 *buffer = (UInt8 *)CFDataGetBytePtr(data);
        
        NSUInteger  x, y;
        for (y = 0; y < height; y++) {
            for (x = 0; x < width; x++) {
                UInt8 *tmp;
                tmp = buffer + y * bytesPerRow + x * 4;
                
                UInt8 red,green,blue;
                red = *(tmp + 0);
                green = *(tmp + 1);
                blue = *(tmp + 2);
                
                UInt8 brightness;
                switch (type) {
                    case 1:
                        brightness = (77 * red + 28 * green + 151 * blue) / 256;
                        *(tmp + 0) = brightness;
                        *(tmp + 1) = brightness;
                        *(tmp + 2) = brightness;
                        break;
                    case 2:
                        *(tmp + 0) = red;
                        *(tmp + 1) = green * 0.7;
                        *(tmp + 2) = blue * 0.4;
                        break;
                    case 3:
                        *(tmp + 0) = 255 - red;
                        *(tmp + 1) = 255 - green;
                        *(tmp + 2) = 255 - blue;
                        break;
                    default:
                        *(tmp + 0) = red;
                        *(tmp + 1) = green;
                        *(tmp + 2) = blue;
                        break;
                }
            }
        }
        
        CFDataRef effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
        
        CGDataProviderRef effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
        
        CGImageRef effectedCgImage = CGImageCreate(
                                                   width, height,
                                                   bitsPerComponent, bitsPerPixel, bytesPerRow,
                                                   colorSpace, bitmapInfo, effectedDataProvider,
                                                   NULL, shouldInterpolate, intent);
        
        UIImage *effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage];
        
        CGImageRelease(effectedCgImage);
        
        CFRelease(effectedDataProvider);
        
        CFRelease(effectedData);
        
        CFRelease(data);
        
        return effectedImage;
    }
    
    return nil;
}

#pragma mark - blur image
//| ----------------------------------------------------------------------------
- (UIImage *)sq_lightImage
{
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    return [self sq_blurredImageWithSize:CGSizeMake(60, 60) tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


//| ----------------------------------------------------------------------------
- (UIImage *)sq_extraLightImage
{
    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
    return [self sq_blurredImageWithSize:CGSizeMake(40, 40) tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


//| ----------------------------------------------------------------------------
- (UIImage *)sq_darkImage
{
    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
    return [self sq_blurredImageWithSize:CGSizeMake(40, 40) tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


//| ----------------------------------------------------------------------------
- (UIImage *)sq_tintedImageWithColor:(UIColor *)tintColor
{
    const CGFloat EffectColorAlpha = 0.6;
    UIColor *effectColor = tintColor;
    size_t componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    if (componentCount == 2) {
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    }
    else {
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    return [self sq_blurredImageWithSize:CGSizeMake(20, 20) tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
}


//| ----------------------------------------------------------------------------
- (UIImage *)sq_blurredImageWithRadius:(CGFloat)blurRadius
{
    return [self sq_blurredImageWithSize:CGSizeMake(blurRadius, blurRadius)];
}


//| ----------------------------------------------------------------------------
- (UIImage *)sq_blurredImageWithSize:(CGSize)blurSize
{
    return [self sq_blurredImageWithSize:blurSize tintColor:nil saturationDeltaFactor:1.0 maskImage:nil];
}

//| ----------------------------------------------------------------------------
- (UIImage *)sq_blurredImageWithSize:(CGSize)blurSize tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
#define ENABLE_BLUR                     1
#define ENABLE_SATURATION_ADJUSTMENT    1
#define ENABLE_TINT                     1
    
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1)
    {
        NSLog(@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage)
    {
        NSLog(@"*** error: inputImage must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage)
    {
        NSLog(@"*** error: effectMaskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    BOOL hasBlur = blurSize.width > __FLT_EPSILON__ || blurSize.height > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    
    CGImageRef inputCGImage = self.CGImage;
    CGFloat inputImageScale = self.scale;
    CGBitmapInfo inputImageBitmapInfo = CGImageGetBitmapInfo(inputCGImage);
    CGImageAlphaInfo inputImageAlphaInfo = (inputImageBitmapInfo & kCGBitmapAlphaInfoMask);
    
    CGSize outputImageSizeInPoints = self.size;
    CGRect outputImageRectInPoints = { CGPointZero, outputImageSizeInPoints };
    
    // Set up output context.
    BOOL useOpaqueContext;
    if (inputImageAlphaInfo == kCGImageAlphaNone || inputImageAlphaInfo == kCGImageAlphaNoneSkipLast || inputImageAlphaInfo == kCGImageAlphaNoneSkipFirst)
        useOpaqueContext = YES;
    else
        useOpaqueContext = NO;
    UIGraphicsBeginImageContextWithOptions(outputImageRectInPoints.size, useOpaqueContext, inputImageScale);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -outputImageRectInPoints.size.height);
    
    if (hasBlur || hasSaturationChange)
    {
        vImage_Buffer effectInBuffer;
        vImage_Buffer scratchBuffer1;
        
        vImage_Buffer *inputBuffer;
        vImage_Buffer *outputBuffer;
        
        vImage_CGImageFormat format = {
            .bitsPerComponent = 8,
            .bitsPerPixel = 32,
            .colorSpace = NULL,
            // (kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little)
            // requests a BGRA buffer.
            .bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little,
            .version = 0,
            .decode = NULL,
            .renderingIntent = kCGRenderingIntentDefault
        };
        
        vImage_Error e = vImageBuffer_InitWithCGImage(&effectInBuffer, &format, NULL, self.CGImage, kvImagePrintDiagnosticsToConsole);
        if (e != kvImageNoError)
        {
            NSLog(@"*** error: vImageBuffer_InitWithCGImage returned error code %zi for inputImage: %@", e, self);
            UIGraphicsEndImageContext();
            return nil;
        }
        
        vImageBuffer_Init(&scratchBuffer1, effectInBuffer.height, effectInBuffer.width, format.bitsPerPixel, kvImageNoFlags);
        inputBuffer = &effectInBuffer;
        outputBuffer = &scratchBuffer1;
        
#if ENABLE_BLUR
        if (hasBlur)
        {
            CGFloat radiusX = [self sq_gaussianBlurRadiusWithBlurRadius:blurSize.width * inputImageScale];
            CGFloat radiusY = [self sq_gaussianBlurRadiusWithBlurRadius:blurSize.height * inputImageScale];
            
            NSInteger tempBufferSize = vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, NULL, 0, 0, radiusY, radiusX, NULL, kvImageGetTempBufferSize | kvImageEdgeExtend);
            void *tempBuffer = malloc(tempBufferSize);
            
            vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, radiusY, radiusX, NULL, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(outputBuffer, inputBuffer, tempBuffer, 0, 0, radiusY, radiusX, NULL, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, radiusY, radiusX, NULL, kvImageEdgeExtend);
            
            free(tempBuffer);
            
            vImage_Buffer *temp = inputBuffer;
            inputBuffer = outputBuffer;
            outputBuffer = temp;
        }
#endif
        
#if ENABLE_SATURATION_ADJUSTMENT
        if (hasSaturationChange)
        {
            CGFloat s = saturationDeltaFactor;
            // These values appear in the W3C Filter Effects spec:
            // https://dvcs.w3.org/hg/FXTF/raw-file/default/filters/index.html#grayscaleEquivalent
            //
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,                    1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            vImageMatrixMultiply_ARGB8888(inputBuffer, outputBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            
            vImage_Buffer *temp = inputBuffer;
            inputBuffer = outputBuffer;
            outputBuffer = temp;
        }
#endif
        
        CGImageRef effectCGImage;
        if ( (effectCGImage = vImageCreateCGImageFromBuffer(inputBuffer, &format, &cleanupBuffer, NULL, kvImageNoAllocate, NULL)) == NULL ) {
            effectCGImage = vImageCreateCGImageFromBuffer(inputBuffer, &format, NULL, NULL, kvImageNoFlags, NULL);
            free(inputBuffer->data);
        }
        if (maskImage) {
            // Only need to draw the base image if the effect image will be masked.
            CGContextDrawImage(outputContext, outputImageRectInPoints, inputCGImage);
        }
        
        // draw effect image
        CGContextSaveGState(outputContext);
        if (maskImage)
            CGContextClipToMask(outputContext, outputImageRectInPoints, maskImage.CGImage);
        CGContextDrawImage(outputContext, outputImageRectInPoints, effectCGImage);
        CGContextRestoreGState(outputContext);
        
        // Cleanup
        CGImageRelease(effectCGImage);
        free(outputBuffer->data);
    }
    else
    {
        // draw base image
        CGContextDrawImage(outputContext, outputImageRectInPoints, inputCGImage);
    }
    
#if ENABLE_TINT
    // Add in color tint.
    if (tintColor)
    {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, outputImageRectInPoints);
        CGContextRestoreGState(outputContext);
    }
#endif
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
#undef ENABLE_BLUR
#undef ENABLE_SATURATION_ADJUSTMENT
#undef ENABLE_TINT
}

/// 对图片进行模糊处理
+ (UIImage *)sq_gaussianBlurImage:(UIImage *)image andInputRadius:(CGFloat)radius
{
    if (!image) {
        return nil;
    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    UIImage *resultImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return resultImage;
}

/// 由颜色生成模糊图片
+ (UIImage *)sq_gaussianBlurImageWithColor:(UIColor *)color andSize:(CGSize)size andInputRadius:(CGFloat)radius
{
    UIImage *image = [UIImage sq_imageWithColor:color andSize:size];
    if (image) {
        return [UIImage sq_gaussianBlurImage:image andInputRadius:radius];
    }
    else {
        return nil;
    }
}
// A description of how to compute the box kernel width from the Gaussian
// radius (aka standard deviation) appears in the SVG spec:
// http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
//
// For larger values of 's' (s >= 2.0), an approximation can be used: Three
// successive box-blurs build a piece-wise quadratic convolution kernel, which
// approximates the Gaussian kernel to within roughly 3%.
//
// let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
//
// ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
//
- (CGFloat)sq_gaussianBlurRadiusWithBlurRadius:(CGFloat)blurRadius
{
    if (blurRadius - 2. < __FLT_EPSILON__) {
        blurRadius = 2.;
    }
    uint32_t radius = floor((blurRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5) / 2);
    radius |= 1; // force radius to be odd so that the three box-blur methodology works.
    return radius;
}

#pragma mark - 透明效果图片
/// 如果含有透明通道就返回TRUE
- (BOOL)sq_hasAlpha {
    // 获取图片的Alpha信息
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
    // 只要满足一下一种就含有透明通道
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

/// 如果不存在透明通道就添加透明通道并返回结果
- (UIImage *)sq_imageWithAlpha {
    if ([self sq_hasAlpha]) {
        return self; // 已有，直接返回
    }
    
    CGFloat scale = MAX(self.scale, 1.0f);
    CGImageRef imageRef = self.CGImage;
    size_t width = CGImageGetWidth(imageRef)*scale;
    size_t height = CGImageGetHeight(imageRef)*scale;
    
    // 创建位图上下文
    CGContextRef offscreenContext =
    CGBitmapContextCreate(NULL, // 渲染内存，为NULL表示由Quartz自动分配
                          width,//
                          height,
                          8,// bitsPerComponent 每个像素组件的位数
                          0,// 位图每行的字节数，0表示自动
                          CGImageGetColorSpace(imageRef),// 颜色空间
                          kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);// 位图信息，这里添加透明通道
    
    
    // 绘制图片
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha scale:self.scale orientation:UIImageOrientationUp];
    
    // 清理内存
    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithAlpha);
    
    return imageWithAlpha;
}

/// 给图片增加透明边框，将图片进行缩放
- (UIImage *)sq_transparentBorderImage:(NSUInteger)borderSize {
    // 如果没有透明通道，那就增加一个
    UIImage *image = [self sq_imageWithAlpha];
    CGFloat scale = MAX(self.scale, 1.0f);
    NSUInteger scaledBorderSize = borderSize * scale;
    // 新图片大小
    CGRect newRect = CGRectMake(0, 0, image.size.width * scale + scaledBorderSize * 2, image.size.height * scale + scaledBorderSize * 2);
    
    // 创建位图
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(self.CGImage),
                                                0,
                                                CGImageGetColorSpace(self.CGImage),
                                                CGImageGetBitmapInfo(self.CGImage));
    
    // 绘制位图，预留一个空白的外边框
    CGRect imageLocation = CGRectMake(scaledBorderSize, scaledBorderSize, image.size.width*scale, image.size.height*scale);
    CGContextDrawImage(bitmap, imageLocation, self.CGImage);
    CGImageRef borderImageRef = CGBitmapContextCreateImage(bitmap);
    
    // 创建图片掩码，边框透明，然后和原图合并
    CGImageRef maskImageRef = [self sq_newBorderMask:scaledBorderSize size:newRect.size];
    CGImageRef transparentBorderImageRef = CGImageCreateWithMask(borderImageRef, maskImageRef);
    UIImage *transparentBorderImage = [UIImage imageWithCGImage:transparentBorderImageRef scale:self.scale orientation:UIImageOrientationUp];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(borderImageRef);
    CGImageRelease(maskImageRef);
    CGImageRelease(transparentBorderImageRef);
    
    return transparentBorderImage;
}

/*  创建透明边框
*
*  @param borderSize 边框宽度
*  @param size       尺寸
*
*  @return maskImageRef
*/
- (CGImageRef)sq_newBorderMask:(NSUInteger)borderSize size:(CGSize)size {
    // 颜色空间-灰度
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // 图像上下文
    CGContextRef maskContext = CGBitmapContextCreate(NULL,
                                                     size.width,
                                                     size.height,
                                                     8, // 8-bit grayscale
                                                     0,
                                                     colorSpace,
                                                     kCGBitmapByteOrderDefault | kCGImageAlphaNone);
    
    // 透明
    CGContextSetFillColorWithColor(maskContext, [UIColor blackColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(0, 0, size.width, size.height));
    
    // 中心不透明
    CGContextSetFillColorWithColor(maskContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(borderSize, borderSize, size.width - borderSize * 2, size.height - borderSize * 2));
    
    // 获取图片掩码
    CGImageRef maskImageRef = CGBitmapContextCreateImage(maskContext);
    
    // 清理
    CGContextRelease(maskContext);
    CGColorSpaceRelease(colorSpace);
    
    return maskImageRef;
}


#pragma mark - 水印
/**
 *  文字水印
 *
 *  @param text      文字
 *  @param direction 文字方向
 *  @param fontColor 文字颜色
 *  @param fontPoint 字体
 *  @param marginXY   对齐点
 *
 *  @return newImage
 */
- (UIImage *)sq_waterWithText:(NSString *)text
                 direction:(SQImageWaterDirect)direction
                 fontColor:(UIColor *)fontColor
                 fontPoint:(CGFloat)fontPoint
                  marginXY:(CGPoint)marginXY{
    
    CGSize size = self.size;
    
    CGRect rect = (CGRect){CGPointZero,size};
    
    //新建图片图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    //绘制图片
    [self drawInRect:rect];
    
    //绘制文本
    NSDictionary *attr =@{NSFontAttributeName : [UIFont systemFontOfSize:fontPoint],NSForegroundColorAttributeName:fontColor};
    
    CGRect strRect = [self sq_calWidth:text attr:attr direction:direction rect:rect marginXY:marginXY];
    
    [text drawInRect:strRect withAttributes:attr];
    
    //获取图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //结束图片图形上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

/**
 *  绘制图片水印
 *
 *  @param waterImage 图片水印
 *  @param direction  方向
 *  @param waterSize  水印大小
 *  @param marginXY   对齐点
 *
 *  @return newImage
 */
- (UIImage *)sq_waterWithWaterImage:(UIImage *)waterImage
                       direction:(SQImageWaterDirect)direction
                       waterSize:(CGSize)waterSize
                        marginXY:(CGPoint)marginXY{
    
    CGSize size = self.size;
    
    CGRect rect = (CGRect){CGPointZero,size};
    
    //新建图片图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    //绘制图片
    [self drawInRect:rect];
    
    //计算水印的rect
    CGSize waterImageSize = CGSizeEqualToSize(waterSize, CGSizeZero)?waterImage.size:waterSize;
    CGRect calRect = [self sq_rectWithRect:rect size:waterImageSize direction:direction marginXY:marginXY];
    
    //绘制水印图片
    [waterImage drawInRect:calRect];
    
    //获取图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //结束图片图形上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

/**
 *  文字水印位置
 *
 *  @param str       字符串
 *  @param attr      字符串属性
 *  @param direction 方向
 *  @param rect      图片Rect
 *  @param marginXY  对齐点
 *
 *  @return calRect
 */
- (CGRect)sq_calWidth:(NSString *)str
              attr:(NSDictionary *)attr
         direction:(SQImageWaterDirect)direction
              rect:(CGRect)rect
          marginXY:(CGPoint)marginXY{
    
    CGSize size =  [str sizeWithAttributes:attr];
    
    CGRect calRect = [self sq_rectWithRect:rect size:size direction:direction marginXY:marginXY];
    
    return calRect;
}

/**
 *  计算水印位置
 *
 *  @param rect      图片rect
 *  @param size      size
 *  @param direction 文字方向
 *  @param marginXY   对齐点
 *
 *  @return calRect
 */
- (CGRect)sq_rectWithRect:(CGRect)rect
                  size:(CGSize)size
             direction:(SQImageWaterDirect)direction
              marginXY:(CGPoint)marginXY{
    
    CGPoint point = CGPointZero;
    
    //右上
    if(SQImageWaterDirectTopRight == direction) point = CGPointMake(rect.size.width - size.width, 0);
    
    //左下
    if(SQImageWaterDirectBottomLeft == direction) point = CGPointMake(0, rect.size.height - size.height);
    
    //右下
    if(SQImageWaterDirectBottomRight == direction) point = CGPointMake(rect.size.width - size.width, rect.size.height - size.height);
    
    //正中
    if(SQImageWaterDirectCenter == direction) point = CGPointMake((rect.size.width - size.width)*.5f, (rect.size.height - size.height)*.5f);
    
    point.x+=marginXY.x;
    point.y+=marginXY.y;
    
    CGRect calRect = (CGRect){point,size};
    
    return calRect;
}

#pragma mark - Gif
/**
 *  播放动画
 *
 *  @param data 源文件（图片源）
 *
 *  @return image
 */
+ (UIImage *)sq_animatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    // 加载所有图片
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    // 图片数量
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    // 只有一张，直接加载
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    // 多张图片，循环播放
    else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            // 图片播放时间累加
            duration += [self sq_frameDurationAtIndex:i source:source];
            
            [images addObject:[UIImage imageWithCGImage:image
                                                  scale:[UIScreen mainScreen].scale
                                            orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        // 加载动画图片，指定动画播放时间
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

/**
 *  计算动画中每一张图片的播放时间
 *
 *  @param index  图片索引
 *  @param source 图片组
 *
 *  @return  播放时间
 */
+ (float)sq_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    
    // 字典转换
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    // 如果有延迟时间
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    // 否则就获取播放下一张图片需要等待的时间
    else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // 设置最小值
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

/**
 *  播放gif动画
 *
 *  @param name 文件名
 *
 *  @return
 */
+ (UIImage *)sq_animatedGIFNamed:(NSString *)name {
    CGFloat scale = [UIScreen mainScreen].scale;
    
    // 视网膜屏，可能要加载高清图
    if (scale > 1.0f) {
        // 文件名1
        NSString *retinaPath = [[NSBundle mainBundle] pathForResource:[name stringByAppendingString:@"@2x"] ofType:@"gif"];
        
        NSData *data = [NSData dataWithContentsOfFile:retinaPath];
        
        if (data) {
            return [UIImage sq_animatedGIFWithData:data];
        }
        
        // 文件名2
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
        
        data = [NSData dataWithContentsOfFile:path];
        
        if (data) {
            return [UIImage sq_animatedGIFWithData:data];
        }
        
        return [UIImage imageNamed:name];
    }
    // 普通屏幕
    else {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        if (data) {
            return [UIImage sq_animatedGIFWithData:data];
        }
        
        return [UIImage imageNamed:name];
    }
}

/**
 *  缩放动画
 *
 *  @param size 大小
 *
 *  @return image
 */
- (UIImage *)sq_animatedImageByScalingAndCroppingToSize:(CGSize)size {
    if (CGSizeEqualToSize(self.size, size) || CGSizeEqualToSize(size, CGSizeZero)) {
        return self;
    }
    
    CGSize scaledSize = size;
    CGPoint thumbnailPoint = CGPointZero;
    
    CGFloat widthFactor = size.width / self.size.width;
    CGFloat heightFactor = size.height / self.size.height;
    CGFloat scaleFactor = (widthFactor > heightFactor) ? widthFactor : heightFactor;
    scaledSize.width = self.size.width * scaleFactor;
    scaledSize.height = self.size.height * scaleFactor;
    
    if (widthFactor > heightFactor) {
        thumbnailPoint.y = (size.height - scaledSize.height) * 0.5;
    }
    else if (widthFactor < heightFactor) {
        thumbnailPoint.x = (size.width - scaledSize.width) * 0.5;
    }
    
    NSMutableArray *scaledImages = [NSMutableArray array];
    
    // 重绘制图片
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    for (UIImage *image in self.images) {
        [image drawInRect:CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledSize.width, scaledSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        [scaledImages addObject:newImage];
    }
    
    UIGraphicsEndImageContext();
    
    return [UIImage animatedImageWithImages:scaledImages duration:self.duration];
}

#pragma mark --  由CIImage生成UIImage

//用到CIImage时可能需要转换，直接生成指定尺寸的UIInage
/**
 *  根据CIImage生成指定大小的UIImage
 *
 *  @param image CIImage
 *  @param size  图片宽度
 */
+ (UIImage *)sq_createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size{
    return [self sq_createNonInterpolatedUIImageFormCIImage:image withSize:size];
}
- (UIImage *)sq_createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    UIImage *resultImage = [UIImage imageWithCGImage:scaledImage];
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGColorSpaceRelease(cs);
    CGImageRelease(scaledImage);
    return resultImage;
}
//| ----------------------------------------------------------------------------
//  Helper function to handle deferred cleanup of a buffer.
//
void cleanupBuffer(void *userData, void *buf_data)
{ free(buf_data); }

@end
