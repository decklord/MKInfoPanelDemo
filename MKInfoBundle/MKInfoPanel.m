//
//  MKInfoPanel.m
//  HorizontalMenu
//
//  Created by Mugunth on 25/04/11.
//  Copyright 2011 Steinlogic. All rights reserved.
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above
//  Read my blog post at http://mk.sg/8e on how to use this code

//  As a side note on using this code, you might consider giving some credit to me by
//	1) linking my website from your app's website 
//	2) or crediting me inside the app's credits page 
//	3) or a tweet mentioning @mugunthkumar
//	4) A paypal donation to mugunth.kumar@gmail.com
//
//  A note on redistribution
//	While I'm ok with modifications to this source code, 
//	if you are re-publishing after editing, please retain the above copyright notices

#import "MKInfoPanel.h"
#import <QuartzCore/QuartzCore.h>

#define kLabelsMarginLeft       67.0
#define kLabelsMarginLeftNoIcon 20.0
#define kLabelsMarginRight      15.0

@implementation MKInfoPanel

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    [_delegate performSelector:_onFinished];
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter
////////////////////////////////////////////////////////////////////////

-(void)setType:(MKInfoPanelType)type {
    
    _type = type;
    
    self.backgroundGradient.image = [[UIImage imageNamed:@"background_toast.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:5];
    
    if(self.type == MKInfoPanelTypeError) {
        self.thumbImage.image = [UIImage imageNamed:@"icon_error.png"];
    }else if(self.type == MKInfoPanelTypeSuccess) {
        self.thumbImage.image = [UIImage imageNamed:@"icon_success.png"];
    }else if(self.type == MKInfoPanelTypeInfo) {
        self.thumbImage.image = [UIImage imageNamed:@"icon_info.png"];
    }else if(self.type == MKInfoPanelTypeToast){
        
        self.backgroundGradient.image = nil;
        self.thumbImage.image = nil;
        self.thumbImage.hidden = TRUE;
        self.titleLabel.hidden = TRUE;
        self.backgroundColor = [UIColor blackColor];
    
    }

}

#pragma mark -
#pragma mark Set Frame Dynamically

- (void)setLabelsFrameForViewWidth:(CGFloat)viewWidth{
    
    CGRect titleLabelFrame = self.titleLabel.frame;
    CGRect detailLabelFrame = self.detailLabel.frame;
    
    int leftMargin = kLabelsMarginLeft;
    int xPosition = detailLabelFrame.origin.x;
    int yPosition = detailLabelFrame.origin.y;
    
    if (self.type == MKInfoPanelTypeToast){
        
        leftMargin = kLabelsMarginLeftNoIcon;
        xPosition = kLabelsMarginLeftNoIcon;
        yPosition = titleLabelFrame.origin.y;
        
    }

    titleLabelFrame.size.width = viewWidth - leftMargin - kLabelsMarginRight;
    self.titleLabel.frame = titleLabelFrame;
    
    detailLabelFrame.size.width = viewWidth - leftMargin - kLabelsMarginRight;
    detailLabelFrame.origin.x = xPosition;
    detailLabelFrame.origin.y = yPosition;
    self.detailLabel.frame = detailLabelFrame;
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Show/Hide
////////////////////////////////////////////////////////////////////////

+ (MKInfoPanel *)showPanelInView:(UIView *)view type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle {
    return [self showPanelInView:view type:type title:title subtitle:subtitle hideAfter:-1];
}

+(MKInfoPanel *)showPanelInView:(UIView *)view type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle hideAfter:(NSTimeInterval)interval {

    return [self showPanelInView:view type:type title:title subtitle:subtitle hideAfter:interval executing:nil];

}

+(MKInfoPanel *)showPanelInView:(UIView *)view type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle hideAfter:(NSTimeInterval)interval executing:(MKVoidBlock)block{
    
    MKInfoPanel *panel = [MKInfoPanel infoPanel];
    CGFloat panelHeight = 50;   // panel height when no subtitle set
    
    panel.type = type;
    panel.titleLabel.text = title;
    panel.block = block;
    
    if (panel.block) {
        panel.onTouched = @selector(executeBlock);
    }
    
    //Set the Frame for Label and Detail Labels dynamically according to device/orientation.
    [panel setLabelsFrameForViewWidth:view.bounds.size.width];
    
    if(subtitle) {
        panel.detailLabel.text = subtitle;
        [panel.detailLabel sizeToFit];
        
        if (type == MKInfoPanelTypeToast) {
            panelHeight = panel.detailLabel.frame.size.height;
        }else{
            panelHeight = MAX(CGRectGetMaxY(panel.thumbImage.frame), CGRectGetMaxY(panel.detailLabel.frame));
        }
        
        panelHeight += 10.f;    // padding at bottom
    } else {
        panel.detailLabel.hidden = YES;
        panel.thumbImage.frame = CGRectMake(15, 5, 35, 35);
        panel.titleLabel.frame = CGRectMake(kLabelsMarginLeft, 12, view.bounds.size.width - kLabelsMarginLeft, 21);
    }
    
    // update frame of panel
    panel.frame = CGRectMake(0, 0, view.bounds.size.width, panelHeight);
    [view addSubview:panel];
    
    if (interval > 0) {
        [panel performSelector:@selector(hidePanel) withObject:view afterDelay:interval];
    }
    
    return panel;

}

+ (MKInfoPanel *)showPanelInWindow:(UIWindow *)window type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle {
    return [self showPanelInWindow:window type:type title:title subtitle:subtitle hideAfter:-1];
}

+(MKInfoPanel *)showPanelInWindow:(UIWindow *)window type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle hideAfter:(NSTimeInterval)interval {
    
    return [self showPanelInWindow:window type:type title:title subtitle:subtitle hideAfter:interval executing:nil];
    
}

+ (MKInfoPanel *)showPanelInWindow:(UIWindow *)window type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle hideAfter:(NSTimeInterval)interval executing:(MKVoidBlock) block{

    MKInfoPanel *panel = [self showPanelInView:window type:type title:title subtitle:subtitle hideAfter:interval executing:block];
    
    if (![UIApplication sharedApplication].statusBarHidden) {
        CGRect frame = panel.frame;
        frame.origin.y += [UIApplication sharedApplication].statusBarFrame.size.height;
        panel.frame = frame;
    }
    
    return panel;
    
}

- (void) hidePanel {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    CATransition *transition = [CATransition animation];
	transition.duration = 0.25;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionPush;	
	transition.subtype = kCATransitionFromTop;
	[self.layer addAnimation:transition forKey:nil];
    self.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height); 
    
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.25];

}

- (void) executeBlock {

    [self hidePanel];
    if (self.block != nil) {
        self.block();
    }

}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Touch Recognition
////////////////////////////////////////////////////////////////////////

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self performSelector:_onTouched];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

+ (MKInfoPanel *) infoPanel {

    MKInfoPanel *panel =  (MKInfoPanel*) [[[UINib nibWithNibName:@"MKInfoPanel" bundle:nil] 
                                           instantiateWithOwner:self options:nil] objectAtIndex:0];

    CATransition *transition = [CATransition animation];
	transition.duration = 0.25;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionPush;	
	transition.subtype = kCATransitionFromBottom;
	[panel.layer addAnimation:transition forKey:nil];
    
    return panel;

}

- (void)setup {

    self.onTouched = @selector(hidePanel);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

}

@end
