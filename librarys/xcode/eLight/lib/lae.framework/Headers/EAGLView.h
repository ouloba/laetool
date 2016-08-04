//
//  EAGLView.h
//  LXZＧui
//
//  Created by  ouloba on 09-9-16.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#include "LXZWindowAPI.h"
/*
This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
The view content is basically an EAGL surface you render your OpenGL scene into.
Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
*/
@interface EAGLView : UIView <UIKeyInput, UITextInput>{
	uiHWND hRoot;
	BOOL landscape;
@private
    /* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;
     

    EAGLContext *context;
	
    
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint viewRenderbuffer, viewFramebuffer;
    
    /* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
    GLuint depthRenderbuffer;
    
   // NSTimer *animationTimer;
    NSTimeInterval animationInterval;
    
    BOOL                    isUseUITextField;
    NSString *              markedText_;
    CGRect                  caretRect_;
    CGRect                  originalRect_;
    NSNotification*         keyboardShowNotification_;
    BOOL                    isKeyboardShown_;
}
@property(nonatomic, readonly) UITextPosition *beginningOfDocument;
@property(nonatomic, readonly) UITextPosition *endOfDocument;
@property(nonatomic, assign) id<UITextInputDelegate> inputDelegate;
@property(nonatomic, readonly) UITextRange *markedTextRange;
@property (nonatomic, copy) NSDictionary *markedTextStyle;
@property(readwrite, copy) UITextRange *selectedTextRange;
@property(nonatomic, readonly) id<UITextInputTokenizer> tokenizer;
@property(nonatomic, readonly, getter = isKeyboardShown) BOOL isKeyboardShown;
@property(nonatomic, copy) NSNotification* keyboardShowNotification;
@property uiHWND hRoot;
@property NSTimeInterval animationInterval;

+ (EAGLView *) sharedInstance;
+ (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame1:(CGRect)frame;
- (void)startAnimation;
- (void)drawView;
- (void)hideInput;

@end
