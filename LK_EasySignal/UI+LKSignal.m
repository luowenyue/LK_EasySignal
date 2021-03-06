//
//  UILKSignal.m
//  LK_EasySignal
//
//  Created by hesh on 13-9-4.
//  Copyright (c) 2013年 ilikeido. All rights reserved.
//

#import "UI+LKSignal.h"
#import "LKSignal.h"
#import <objc/runtime.h>
#import "UIResponder+LKSignal.h"
#import <BILib.h>

#pragma mark -

@implementation UIButton (LK_EasySignal)

+(NSString *)UPINSIDE;{
    return @"UPINSIDE";
}

@end

@interface UISlider (LK_EasySignal_Private)
-(void)__valueChange;
@end

@implementation UISlider(LK_EasySignal_Private)

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self addTarget:self action:@selector(__valueChange) forControlEvents:UIControlEventValueChanged];
}

-(void)__valueChange{
    [self sendSignalName:[self class].VALUECHANGE];
}

@end

@implementation UISlider(LK_EasySignal)
+(NSString *)VALUECHANGE;{
    return @"VALUECHANGE";
}

@end

@interface UISwitch (LK_EasySignal_Private)
-(void)__valueChange;
@end

@implementation UISwitch(LK_EasySignal_Private)

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self addTarget:self action:@selector(__valueChange) forControlEvents:UIControlEventValueChanged];
}

-(void)__valueChange{
    [self sendSignalName:[self class].VALUECHANGE];
}

@end

@implementation UISwitch(LK_EasySignal)
+(NSString *)VALUECHANGE;{
    return @"VALUECHANGE";
}

@end

@interface UIAlertView(LK_EasySignal_Private)

@property(nonatomic,strong) LKSignal *cancelSignal;

@property(nonatomic,strong) LKSignal *submitSignal;

@property(nonatomic,weak) UIView *targetView;

-(void)setCancelSignalObject:(NSObject *)object;

-(void)setSumbitSignalObject:(NSObject *)object;

@end

@implementation UIAlertView(LK_EasySignal_Private)

@dynamic cancelSignal;
@dynamic submitSignal;

-(void)setCancelSignal:(LKSignal *)cancelSignal{
    if (self.cancelSignal) {
        objc_setAssociatedObject (self, "cancelSignal", nil, OBJC_ASSOCIATION_ASSIGN );
    }
    objc_setAssociatedObject( self, "cancelSignal", cancelSignal, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

-(LKSignal *)cancelSignal{
    NSObject * obj = objc_getAssociatedObject( self, "cancelSignal" );
	if ( obj && [obj isKindOfClass:[LKSignal class]] )
		return (LKSignal *)obj;
	return nil;
}

-(void)setSubmitSignal:(LKSignal *)submitSignal{
    if (self.submitSignal) {
        objc_setAssociatedObject (self, "submitSignal", nil, OBJC_ASSOCIATION_ASSIGN );
    }
    objc_setAssociatedObject( self, "submitSignal", submitSignal, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

-(LKSignal *)submitSignal{
    NSObject * obj = objc_getAssociatedObject( self, "submitSignal" );
	if ( obj && [obj isKindOfClass:[LKSignal class]] )
		return (LKSignal *)obj;
	return nil;
}

-(UIView *)targetView{
    NSObject * obj = objc_getAssociatedObject( self, "targetView" );
	if ( obj && [obj isKindOfClass:[UIView class]] )
		return (UIView *)obj;
	return nil;
}

-(void)setTargetView:(UIView *)targetView{
    objc_setAssociatedObject( self, "targetView", targetView, OBJC_ASSOCIATION_ASSIGN );
}

-(void)setCancelSignalObject:(NSObject *)object;{
    self.cancelSignal = [[LKSignal alloc]initWithSender:self firstRouter:self.targetView object:object signalName:UIAlertView.CANCEL tag:0  tagString:self.tagString];
}

-(void)setSumbitSignalObject:(NSObject *)object{
    self.submitSignal = [[LKSignal alloc]initWithSender:self firstRouter:self.targetView object:object signalName:UIAlertView.SUMBIT tag:0  tagString:self.tagString];
}

@end

@implementation UIAlertView(LK_EasySignal)

-(void)showInView:(UIView *)view cancelSignalObject:(NSObject *)cancelSignalObject sumbitSignalObject:(NSObject *)sumbitSignalObject;{
    self.targetView = view;
    [self setCancelSignalObject:cancelSignalObject];
    [self setSumbitSignalObject:sumbitSignalObject];
    [self show];
    self.delegate = self;
}

#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;{
    if (buttonIndex != alertView.cancelButtonIndex) {
        alertView.submitSignal.tag = buttonIndex;
        [alertView.targetView sendSignal:alertView.submitSignal];
    }else{
        [alertView.targetView sendSignal:alertView.cancelSignal];
    }
    alertView.delegate = nil;
    alertView.submitSignal = nil;
    alertView.cancelSignal = nil;
    alertView.targetView = nil;
}


+(NSString *)CANCEL;{
    return @"CANCEL";
}

+(NSString *)SUMBIT;{
    return @"SUMBIT";
}

@end

@interface UIActionSheet (LK_EasySignal_Private)<UIActionSheetDelegate>
-(NSMutableDictionary *)signlaDic;
-(LKSignal *)defaultSignal;
@end

@implementation UIActionSheet (LK_EasySignal_Private)

-(id)init{
    self = [super init];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [BILib injectToClass:[UIActionSheet class] selector:@selector(showInView:) preprocess:^(UIActionSheet *_sheet,UIView *view){
                __weak id<UIActionSheetDelegate> delegate = (id<UIActionSheetDelegate>)_sheet;
                if (!_sheet.delegate) {
                    _sheet.delegate = delegate;
                    NSDictionary *signlaDic = _sheet.signlaDic;
                    if (signlaDic.count> 0) {
                        for (LKSignal *signal in signlaDic.allValues) {
                            signal.firstRouter = view;
                        }
                    }else{
                        _sheet.defaultSignal.firstRouter = view;
                    }
                }
            }];

            [BILib injectToClass:[UIActionSheet class] selector:@selector(setTagString:) preprocess:^(UIActionSheet *_sheet,NSString *tagString){
                NSDictionary *signlaDic = _sheet.signlaDic;
                if (signlaDic.count>0) {
                    for (LKSignal *signal in signlaDic.allValues) {
                        signal.tagString = tagString;
                    }
                }else{
                    _sheet.defaultSignal.tagString = tagString;
                }
            }];
        });
        
    }
    return self;
}

-(NSMutableDictionary *)signlaDic{
    NSMutableDictionary *signlaDic = objc_getAssociatedObject(self, @"signlaDic");
    if (!signlaDic) {
        signlaDic = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, @"signlaDic", signlaDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return signlaDic;
}

-(LKSignal *)defaultSignal{
    LKSignal *defaultSignal = objc_getAssociatedObject(self, @"defaultSignal");
    if (!defaultSignal) {
        defaultSignal =  [[LKSignal alloc]initWithSender:self firstRouter:self object:nil signalName:UIActionSheet.CLICKED tag:0 tagString:self.tagString];
        objc_setAssociatedObject(self, @"defaultSignal", defaultSignal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return defaultSignal;
}

#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;{
    LKSignal *signal = [self.signlaDic objectForKey:[NSNumber numberWithInt:buttonIndex]];
    if (!signal) {
         signal = self.defaultSignal;
    }
    [signal.firstRouter sendSignal:signal];
    self.delegate = nil;
}

-(void)dealloc{
    objc_setAssociatedObject(self, @"signlaDic", nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, @"defaultSignal", nil, OBJC_ASSOCIATION_ASSIGN);
}

@end

@implementation UIActionSheet(LK_EasySignal)

+(NSString *)CLICKED;{
    return @"CLICKED";
}

-(void)setSignalObject:(NSObject *)object index:(int)index{
    LKSignal *signal = [[LKSignal alloc]initWithSender:self firstRouter:self object:object signalName:UIActionSheet.CLICKED tag:index tagString:nil];
    [self.signlaDic setObject:signal forKey:[NSNumber numberWithInt:index]];
}

-(void)addButtonWithTitle:(NSString *)title signalObject:(NSObject *)object;{
    int index = [self addButtonWithTitle:title];
    [self setSignalObject:object index:index];
}

@end

#pragma mark -

@interface UIView (LK_EasySignal_Private)

@property(nonatomic,strong) UIGestureRecognizer *tagRecongizer;

@end

@implementation UIView (LK_EasySignal_Private)

@dynamic tagRecongizer;

-(UIGestureRecognizer *)tagRecongizer{
    NSObject * obj = objc_getAssociatedObject( self, "tagRecongizer" );
	if ( obj && [obj isKindOfClass:[UIGestureRecognizer class]] )
		return (UIGestureRecognizer *)obj;
	return nil;
}

-(void)setTagRecongizer:(UIGestureRecognizer *)tagRecongizer{
    UIGestureRecognizer *_tagRecongizer = self.tagRecongizer;
    if (_tagRecongizer) {
        [self removeGestureRecognizer:_tagRecongizer];
        _tagRecongizer = nil;
    }
    objc_setAssociatedObject( self, "tagRecongizer", tagRecongizer, OBJC_ASSOCIATION_ASSIGN );
}

@end

@implementation UIView (LK_EasySignal)

-(void)setTapable:(BOOL)_tapable{
    if (_tapable) {
        UITapGestureRecognizer *_tagRecongizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSignal)];
        [self addGestureRecognizer:_tagRecongizer];
        self.tagRecongizer = _tagRecongizer;
    }else{
        self.tagRecongizer = nil;
    }
}

-(BOOL)tapable{
    if (self.tagRecongizer) {
        return YES;
    }else{
        return NO;
    }
}

+(NSString *)TAPED;{
    return @"TAPED";
}

-(void)tapSignal{
    [self sendSignalName:[self class].TAPED];
}

@end


@interface UITextFieldWrapper : NSObject<UITextFieldDelegate>

@property(nonatomic,assign) UITextField *textField;

@end

@implementation UITextFieldWrapper

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;{
    if (range.location > textField.maxLength && ![string isEqual:@""] && ![string isEqual:@"\n"]) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;{
    LKSignal *signal = [[LKSignal alloc]initWithSender:textField firstRouter:textField object:nil signalName:UITextField.BEGIN_EDITING tag:textField.tag tagString:textField.tagString];
    [textField sendSignal:signal];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    LKSignal *signal = [[LKSignal alloc]initWithSender:textField firstRouter:textField object:nil signalName:UITextField.RETURN tag:textField.tag tagString:textField.tagString];
    [textField sendSignal:signal];
    return YES;
}

@end

@interface UITextField(LK_EasySignal_Private)

-(UITextFieldWrapper *) wrapper;

@end

@implementation UITextField(LK_EasySignal_Private)


-(UITextFieldWrapper *) wrapper;{
    UITextFieldWrapper *wrapper = objc_getAssociatedObject(self, @"wrapper");
    if (!wrapper) {
        wrapper =  [[UITextFieldWrapper alloc]init];
        wrapper.textField = self;
        objc_setAssociatedObject(self, @"wrapper", wrapper, OBJC_ASSOCIATION_RETAIN);
    }
    return wrapper;
}

-(void)addNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(__addDelegate:) name:UITextFieldTextDidBeginEditingNotification object:self];
    [center addObserver:self selector:@selector(__textChanged:) name:UITextFieldTextDidChangeNotification object:self];
}

-(void)awakeFromNib{
    [self addNotification];
}

-(id)init{
    self = [super init];
    [self addNotification];
    return self;
}

-(void)__addDelegate:(NSNotification *)notification{
    if (notification.object == self && !self.delegate) {
        self.delegate = self.wrapper;
    }
}

-(void)__textChanged:(NSNotification *)notification{
    if (notification.object == self) {
        LKSignal *signal = [[LKSignal alloc]initWithSender:self firstRouter:self object:nil signalName:[self class].TEXTCHANGED tag:self.tag tagString:self.tagString];
        [self sendSignal:signal];
    }
}

@end

@implementation UITextField(LK_EasySignal)

@dynamic maxLength;

-(int)maxLength{
    NSObject * obj = objc_getAssociatedObject( self, "maxLength" );
	if ( obj && [obj isKindOfClass:[NSNumber class]] )
		return ((NSNumber *)obj).intValue;
	return NSMaximumStringLength;
}

-(void)setMaxLength:(int)maxLength{
    NSObject * obj = objc_getAssociatedObject( self, "maxLength" );
	if ( obj && [obj isKindOfClass:[NSNumber class]] )
    {
        obj = nil;
    }
    objc_setAssociatedObject( self, "maxLength", [NSNumber numberWithInt:maxLength], OBJC_ASSOCIATION_RETAIN );
}


+(NSString *)RETURN;{
    return @"RETURN";
}

+(NSString *)TEXTCHANGED;{
    return @"TEXTCHANGED";
}

+(NSString *)BEGIN_EDITING;{
    return @"BEGIN_EDITING";
}




@end

@interface UITextViewWrapper : NSObject<UITextViewDelegate>

@property(nonatomic,assign) UITextView *textView;

@end

@implementation UITextViewWrapper

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (range.location > textView.maxLength && ![text isEqual:@"\n"] && ![text isEqual:@""]) {
        return NO;
    }
    if ([text isEqual:@"\n"]) {
        LKSignal *signal = [[LKSignal alloc]initWithSender:textView firstRouter:textView object:nil signalName:UITextView.RETURN tag:textView.tag tagString:textView.tagString];
        [textView sendSignal:signal];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView;{
    LKSignal *signal = [[LKSignal alloc]initWithSender:textView firstRouter:textView object:nil signalName:UITextView.BEGIN_EDITING tag:textView.tag tagString:textView.tagString];
    [textView sendSignal:signal];
}

-(void)textViewDidChange:(UITextView *)textView{
    LKSignal *signal = [[LKSignal alloc]initWithSender:textView firstRouter:textView object:nil signalName:UITextView.TEXTCHANGED tag:textView.tag tagString:textView.tagString];
    [textView sendSignal:signal];
}

@end

@interface UITextView(LK_EasySignal_Private)

-(UITextViewWrapper *) wrapper;

@end

@implementation UITextView(LK_EasySignal_Private)

-(void)addPlaceHolderLable{
    UILabel *placeHolderLable = (UILabel *)[self viewWithTag:109932];
    if (!placeHolderLable) {
        placeHolderLable = [[UILabel alloc]init];
        placeHolderLable.tag = 109932;
        placeHolderLable.numberOfLines = 100;
        placeHolderLable.textColor = [UIColor grayColor];
        placeHolderLable.font = self.font;
        placeHolderLable.backgroundColor = [UIColor clearColor];
        placeHolderLable.frame = CGRectMake(8.0f, 0.0f, self.frame.size.width - 16.0f, self.frame.size.height - 16.0f);
        [self addSubview:placeHolderLable];
    }
}

-(void)addNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(__addDelegate:) name:UITextViewTextDidBeginEditingNotification object:self];
    [center addObserver:self selector:@selector(__updatePlaceHolder:) name:UITextViewTextDidChangeNotification object:self];
}

-(void)awakeFromNib{
    [self addPlaceHolderLable];
    [self addNotification];
}

-(id)init{
    self = [super init];
    if (self) {
        [self addPlaceHolderLable];
        [self addNotification];
    }
    return self;
}


-(void)__addDelegate:(NSNotification *)notification{
    if (!self.delegate) {
        if (notification.object == self) {
            self.delegate = self.wrapper;
        }
    }
}

-(void)__updatePlaceHolder:(NSNotification *)notification{
    if (notification.object == self) {
        UILabel *placeHolderLable = (UILabel *)[self viewWithTag:109932];
        if (self.text.length > 0) {
            placeHolderLable.text = nil;
        }else{
            placeHolderLable.text = self.placeHolder;
        }
    }
}


-(UITextViewWrapper *) wrapper;{
    UITextViewWrapper *wrapper = objc_getAssociatedObject(self, @"wrapper");
    if (!wrapper) {
        wrapper =  [[UITextViewWrapper alloc]init];
        wrapper.textView = self;
        objc_setAssociatedObject(self, @"wrapper", wrapper, OBJC_ASSOCIATION_RETAIN);
    }
    return wrapper;
}


@end

@implementation UITextView(LK_EasySignal)

@dynamic maxLength;
@dynamic placeHolder;

-(NSString *)placeHolder{
    NSObject * obj = objc_getAssociatedObject( self, "placeHolder" );
	if ( obj && [obj isKindOfClass:[NSString class]] )
		return (NSString *)obj;
	return nil;

}

-(void)setPlaceHolder:(NSString *)placeHolder{
    NSObject * obj = objc_getAssociatedObject( self, "placeHolder" );
	if ( obj && [obj isKindOfClass:[NSString class]] )
    {
        obj = nil;
    }
    objc_setAssociatedObject( self, "placeHolder", placeHolder, OBJC_ASSOCIATION_RETAIN );
    UILabel *placeHolderLable = (UILabel *)[self viewWithTag:109932];
    if (placeHolderLable) {
        [placeHolderLable setText:placeHolder];
    }
}

-(int)maxLength{
    NSObject * obj = objc_getAssociatedObject( self, "maxLength" );
	if ( obj && [obj isKindOfClass:[NSNumber class]] )
		return ((NSNumber *)obj).intValue;
	return NSMaximumStringLength;
}

-(void)setMaxLength:(int)maxLength{
    NSObject * obj = objc_getAssociatedObject( self, "maxLength" );
	if ( obj && [obj isKindOfClass:[NSNumber class]] )
    {
        obj = nil;
    }
    objc_setAssociatedObject( self, "maxLength", [NSNumber numberWithInt:maxLength], OBJC_ASSOCIATION_RETAIN );
}

+(NSString *)RETURN;{
    return @"RETURN";
}

+(NSString *)TEXTCHANGED;{
    return @"TEXTCHANGED";
}

+(NSString *)BEGIN_EDITING;{
    return @"BEGIN_EDITING";
}

@end

@interface UIDatePicker (LK_EasySignal_Private)<UIActionSheetDelegate>

@property(nonatomic,weak) UIView *parentView;

@end

@implementation UIDatePicker (LK_EasySignal_Private)

@dynamic parentView;

-(void)setParentView:(UIView *)parentView{
    NSObject * obj = objc_getAssociatedObject( self, "_parentView" );
	if ( obj && [obj isKindOfClass:[UIView class]] )
    {
        obj = nil;
    }
    objc_setAssociatedObject( self, "_parentView", parentView, OBJC_ASSOCIATION_ASSIGN );
}

-(UIView *)parentView{
    NSObject * obj = objc_getAssociatedObject( self, "_parentView" );
	if ( obj && [obj isKindOfClass:[UIView class]] )
		return (UIView *)obj;
	return nil;
}


- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex;{
    LKSignal *_signal = [[LKSignal alloc]initWithSender:self firstRouter:self.parentView object:self.date signalName:UIDatePicker.COMFIRM tag:self.tag tagString:self.tagString];
    [self.parentView sendSignal:_signal];
}

-(void)dateChanged{
    LKSignal *_signal = [[LKSignal alloc]initWithSender:self firstRouter:self.parentView object:self.date signalName:UIDatePicker.DATECHANGED tag:self.tag tagString:self.tagString];
    [self.parentView sendSignal:_signal];
}

@end


@implementation UIDatePicker (LK_EasySignal)

-(void)showTitle:(NSString *)title inView:(UIView *)view;{
    self.frame = CGRectMake(0, 0, 320, 200);
     UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"\n\n\n\\n\n\n\\n\n\n\n\n\n\n\n" delegate:self cancelButtonTitle:@"确定" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    [sheet addSubview:self];
    self.parentView = view;
    [self addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    [sheet showInView:view];
}

+(NSString *)DATECHANGED;{
    return @"DATECHANGED";
}

+(NSString *)COMFIRM;{
    return @"COMFIRM";
}

@end

