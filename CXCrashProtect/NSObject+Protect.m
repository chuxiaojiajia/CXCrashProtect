//
//  NSObject+Protect.m
//  CXProtect
//
//  Created by chuxiao on 2018/5/21.
//  Copyright © 2018年 CXProtect. All rights reserved.
//

#import "NSObject+Protect.h"
#import <objc/runtime.h>

@implementation NSObject (Protect)

/**
 实例方法替换

 @param cxClass class
 @param originalSel 源方法
 @param swizzledSel 替换方法
 */
+ (void)exchangeInstanceMethod:(Class)cxClass
                   originalSel:(SEL)originalSel
                   swizzledSel:(SEL)swizzledSel
{
    Method originalMethod = class_getInstanceMethod(cxClass, originalSel);
    Method swizzledMethod = class_getInstanceMethod(cxClass, swizzledSel);
    
    // 这里用这个方法做判断，看看origin方法是否有实现，如果没实现，直接用我们自己的方法，如果有实现，则进行交换
    BOOL isAddMethod =
    class_addMethod(cxClass,
                    originalSel,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (isAddMethod) {
        class_replaceMethod(cxClass,
                            swizzledSel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

/**
 类方法替换

 @param cxClass class
 @param originalSel 源方法
 @param swizzledSel 替换方法
 */
+ (void)exchangeClassMethod:(Class _Nonnull )cxClass
                originalSel:(SEL _Nonnull )originalSel
                swizzledSel:(SEL _Nonnull )swizzledSel
{
    
    Method origMethod = class_getClassMethod(cxClass, originalSel);
    Method replaceMeathod = class_getClassMethod(cxClass, swizzledSel);
    Class metaKlass = objc_getMetaClass(NSStringFromClass(cxClass).UTF8String);

    /**
     *  我们在这里使用class_addMethod()函数对Method Swizzling做了一层验证，如果self没有实现被交换的方法，会导致失败。
     *  而且self没有交换的方法实现，但是父类有这个方法，这样就会调用父类的方法，结果就不是我们想要的结果了。
     *  所以我们在这里通过class_addMethod()的验证，如果self实现了这个方法，class_addMethod()函数将会返回NO，我们就可以对其进行交换了。
     */
    BOOL didAddMethod = class_addMethod(metaKlass,
                                        originalSel,
                                        method_getImplementation(replaceMeathod),
                                        method_getTypeEncoding(replaceMeathod));
    if (didAddMethod) {
        class_replaceMethod(metaKlass,
                            swizzledSel,
                            method_getImplementation(origMethod),
                            method_getTypeEncoding(origMethod));
    }else {
        method_exchangeImplementations(origMethod, replaceMeathod);
    }
}

@end
