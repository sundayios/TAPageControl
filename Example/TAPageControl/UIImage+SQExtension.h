//
//  UIImage+Extension.h
//  BasicFramework
//
//  Created by Rainy on 16/10/26.
//  Copyright © 2016年 Rainy. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 *  水印方向
 */
typedef enum {
    
    //左上
    SQImageWaterDirectTopLeft=0,
    
    //右上
    SQImageWaterDirectTopRight,
    
    //左下
    SQImageWaterDirectBottomLeft,
    
    //右下
    SQImageWaterDirectBottomRight,
    
    //正中
    SQImageWaterDirectCenter
    
}SQImageWaterDirect;


@interface UIImage (SQExtension)

#pragma mark -- 识别图片中的二维码
-(BOOL)HaveQRCode;

#pragma mark -- 读取图片
+(UIImage *)sq_imageNamed:(NSString *)IMGName InBundleNamed:(NSString *)BundleName;
+ (UIImage *)sq_imageWithName:(NSString *)imageName withRenderingMode:(UIImageRenderingMode)imageRenderingMode;

#pragma mark -- resize
-(UIImage*)sq_scaleToSize:(CGSize)size;
//聊天的文字气泡拉伸
+ (UIImage *)sq_resizedImage:(NSString *)name;
//调整图片大小
+ (UIImage *)sq_resizedImage:(NSString *)name left:(CGFloat)left top:(CGFloat)top;

//UIImage自定长宽缩放
+(UIImage *)sq_reSizeImage:(UIImage *)image toSize:(CGSize)reSize;

//UIImage等比例缩放
+(UIImage *)sq_scaleImage:(UIImage *)image toScale:(CGFloat)scale;
/**
 *  图片的压缩方法
 *
 *  @param sourceImg   要被压缩的图片
 *  @param defineWidth 要被压缩的尺寸(宽)
 *
 *  @return 被压缩的图片
 */
+(UIImage *)sq_compressImage:(UIImage *)sourceImg toTargetWidth:(CGFloat)defineWidth;
//压缩图片至内存长度
+ (NSData *)sq_compressImage:(UIImage *)image toDataLength:(CGFloat)length;

#pragma mark restore image to befor
-(UIImage *)sq_restoreMyimage;

#pragma mark-- 裁剪圆形图片
/* 裁剪圆形图片 例如：头像 */
+ (UIImage *)sq_roundBezierImage:(UIImage *)image;
/**
 *  图片剪切为圆形
 *
 *  @return 剪切后的圆形图片
 */
+ (UIImage *)sq_roundImage;
- (UIImage *)sq_roundImage;
/**
 *  将image转换为圆型带边框的图片（最好写一个UIImage的类扩展）
 *
 *  @param name        图片的名字
 *  @param borderWidth 外层边框的宽度
 *  @param borderColor 外层边框的颜色
 *
 *  @return 返回已经处理好的圆形图片
 */
+ (UIImage *)sq_circleImageWithName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
+ (UIImage *)sq_circleImageWithImage:(UIImage *)oldImage borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
/**绘制方法的具体逻辑，遮罩图片的逻辑是绘制一个矩形，然后在绘制一个相应的圆角矩形，然后填充矩形和圆角矩形的中间部分为父视图的背景色*/
+ (UIImage *)sq_circleImageRoundCornerRadiusImageWithColor:(UIColor *)color cornerRadii:(CGSize)cornerRadii size:(CGSize)size corners:(UIRectCorner)corners borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;
- (CGSize)sq_sizeFromImage:(UIImage *)image;

#pragma mark-- 修正图片方向
/**
 *  修正图片方向
 *
 *  @return 修改后的图片
 */
- (UIImage *)sq_fixOrientation;
#pragma mark - Set the image rotation Angle
- (UIImage*)sq_image_RotatedByAngle:(CGFloat)Angle;
/**
 *  旋转图片
 *
 *  @param isHorizontal 方向
 *
 *  @return 结果图片
 */
- (UIImage *)sq_image_RotatedByFlip:(BOOL)isHorizontal;

#pragma mark -- color -> image
+ (UIImage*)sq_imageWithColor: (UIColor*) color;
- (UIImage *)sq_imageWithColorFitToScale:(UIColor *)color;
/**
 *  返回指定颜色生成的图片
 *
 *  @param color 颜色
 *  @param size  尺寸
 */
+ (UIImage *)sq_imageWithColor:(UIColor *)color andSize:(CGSize)size;
/**
 *  获取指定尺寸（50*50）的图片
 *
 *  @param color 图片颜色
 *  @param name  文本,居中显示
 *
 *  @return img
 */
+ (UIImage *)sq_imageWithColor:(UIColor *)color text:(NSString *)name;
/**
 *  获取指定尺寸（size）的图片
 *
 *  @param color 图片颜色
 *  @param name  文本,居中显示
 *
 *  @return img
 */
+ (UIImage *)sq_imageWithColor:(UIColor *)color text:(NSString *)name andImageSize:(CGSize)imageSize;
/**
 *  获取指定尺寸（size）的图片
 *
 *  @param color 图片颜色
 *  @param name  文本,居中显示
 *  @param textfont  文本,字体大小
 *  @param imageSize 图片尺寸
 *  @return img
 */
+ (UIImage *)sq_imageWithColor:(UIColor *)color text:(NSString *)name textFont:(UIFont *)textfont andImageSize:(CGSize)imageSize;

//圆形的[用颜色生成]
+ (UIImage *)sq_ImageRoundWithColor:(UIColor *)color size:(CGSize)size radius:(CGFloat)radius;
//圆形带边框[用颜色生成]
+ (UIImage *)sq_ImageRoundWithSize:(CGFloat)size fillColor:(UIColor *)fillColor borderWith:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
#pragma mark-- 截屏
/***image from view ***/
+ (UIImage *)sq_imageFromView:(UIView *)theView;
/*** scrollView ***/
+ (UIImage *)sq_imageFromShortScrollView:(UIScrollView *)scrollView;
/**  直接截屏*/
+ (UIImage *)sq_imageFromScreen;
+ (UIImage *)sq_imageFromLongScrollView:(UIScrollView *)scrollView;
/**
 *  从给定UIImage和指定Frame截图：
 */
- (UIImage *)sq_imageCutWithFrame:(CGRect)frame;


/**
 *  @brief  取图片某一点的颜色
 *
 *  @param point 某一点
 *
 *  @return 颜色
 */
- (UIColor *)sq_colorAtPoint:(CGPoint )point;
//more accurate method ,colorAtPixel 1x1 pixel
/**
 *  @brief  取某一像素的颜色
 *
 *  @param point 一像素
 *
 *  @return 颜色
 */
- (UIColor *)sq_colorAtPixel:(CGPoint)point;

#pragma mark - 变灰

/**
 *  @brief  获得灰度图
 *
 *  @param sourceImage 图片
 *
 *  @return 获得灰度图片
 */
+ (UIImage*)sq_grayImageWithImage:(UIImage*)sourceImage;
// 将彩色图片变为黑白的（type = 1）
+ (UIImage *)sq_grayImageWithImage:(UIImage *)anImage type:(int)type;


#pragma mark - blur image
- (UIImage *)sq_lightImage;
- (UIImage *)sq_extraLightImage;
- (UIImage *)sq_darkImage;
- (UIImage *)sq_tintedImageWithColor:(UIColor *)tintColor;

- (UIImage *)sq_blurredImageWithRadius:(CGFloat)blurRadius;
- (UIImage *)sq_blurredImageWithSize:(CGSize)blurSize;
- (UIImage *)sq_blurredImageWithSize:(CGSize)blurSize
                        tintColor:(UIColor *)tintColor
            saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                        maskImage:(UIImage *)maskImage;
- (UIImage *)sq_blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;
/// 对图片进行模糊处理
+ (UIImage *)sq_gaussianBlurImage:(UIImage *)image andInputRadius:(CGFloat)radius;

/// 由颜色生成模糊图片
+ (UIImage *)sq_gaussianBlurImageWithColor:(UIColor *)color andSize:(CGSize)size andInputRadius:(CGFloat)radius;


#pragma mark - 透明效果图片
/// 如果含有透明通道就返回TRUE
- (BOOL)sq_hasAlpha;

/// 如果不存在透明通道就添加透明通道并返回结果
- (UIImage *)sq_imageWithAlpha;

/// 给图片增加透明边框，将图片进行缩放
- (UIImage *)sq_transparentBorderImage:(NSUInteger)borderSize;

/*  创建透明边框
*
*  @param borderSize 边框宽度
*  @param size       尺寸
*
*  @return
*/
- (CGImageRef)sq_newBorderMask:(NSUInteger)borderSize size:(CGSize)size;


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
 *  @return
 */
- (UIImage *)sq_waterWithText:(NSString *)text
                 direction:(SQImageWaterDirect)direction
                 fontColor:(UIColor *)fontColor
                 fontPoint:(CGFloat)fontPoint
                  marginXY:(CGPoint)marginXY;

/**
 *  绘制图片水印
 *
 *  @param waterImage 图片水印
 *  @param direction  方向
 *  @param waterSize  水印大小
 *  @param marginXY   对齐点
 *
 *  @return
 */
- (UIImage *)sq_waterWithWaterImage:(UIImage *)waterImage
                       direction:(SQImageWaterDirect)direction
                       waterSize:(CGSize)waterSize
                        marginXY:(CGPoint)marginXY;

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
             marginXY:(CGPoint)marginXY;

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
                 marginXY:(CGPoint)marginXY;
#pragma mark - Gif
/**
 *  播放动画
 *
 *  @param data 源文件（图片源）
 *
 *  @return image
 */
+ (UIImage *)sq_animatedGIFWithData:(NSData *)data;
/**
 *  计算动画中每一张图片的播放时间
 *
 *  @param index  图片索引
 *  @param source 图片组
 *
 *  @return  播放时间
 */
+ (float)sq_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source;

/**
 *  播放gif动画
 *
 *  @param name 文件名
 *
 *  @return image
 */
+ (UIImage *)sq_animatedGIFNamed:(NSString *)name;

/**
 *  缩放动画
 *
 *  @param size 大小
 *
 *  @return image
 */
- (UIImage *)sq_animatedImageByScalingAndCroppingToSize:(CGSize)size;

#pragma mark --  由CIImage生成UIImage

//用到CIImage时可能需要转换，直接生成指定尺寸的UIInage
/**
 *  根据CIImage生成指定大小的UIImage
 *
 *  @param image CIImage
 *  @param size  图片宽度
 */
+ (UIImage *)sq_createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size;
- (UIImage *)sq_createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size;
@end
