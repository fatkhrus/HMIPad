//
//  SWDictionaryPickerItemController.m
//  HmiPad
//
//  Created by Lluch Joan on 05/25/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWDictionaryPickerItemController.h"

#import "SWTableSelectionController.h"

#import "ColoredButton.h"
#import "SWDictionaryPickerItem.h"
#import "SWEnumTypes.h"

#import "FPPopoverController.h"

#import "SWColor.h"


@interface SWDictionaryPickerItemController()<SWTableSelectionControllerDelegate,UIPopoverControllerDelegate,FPPopoverControllerDelegate>
@end


@implementation SWDictionaryPickerItemController
{
    UIPopoverController *_popover;
    FPPopoverController *_fpPopover;
}

@synthesize buttonView = _buttonView;

- (void)loadView
{
    _buttonView = [[ColoredButton alloc] init];
    [_buttonView setFrame:CGRectMake(0,0,100,100)];
    [_buttonView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [_buttonView addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_buttonView addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    //[_buttonView addTarget:self action:@selector(buttonTouchUpOther:) forControlEvents:UIControlEventTouchUpOutside];
    //[_buttonView addTarget:self action:@selector(buttonTouchUpOther:) forControlEvents:UIControlEventTouchCancel];
    self.view = _buttonView;
}

- (void)viewDidUnload
{
    _buttonView = nil;
    [super viewDidUnload];
}


#pragma mark - Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    [self _updateActivedState];
    [self _updateView];
}

//- (void)refreshZoomScaleFactor:(CGFloat)zoomScaleFactor
//{
//    [super refreshZoomScaleFactor:zoomScaleFactor];
//    [_buttonView setZoomScaleFactor:zoomScaleFactor];
//}


#pragma mark - Main Methods

//- (void)_checkPointForValue:(NSInteger)index
//{
//    SWDictionaryPickerItem *item = [self _buttonItem];
//    __weak id theSelf = self;
//    [theSelf checkPointVerification:nil completion:^(BOOL success)
//    {
//        if ( success )
//        {
//            [item.value evalWithConstantValue:(double)index];
//        }
//        else
//        {
//            [item.continuousValue evalWithValue:item.value];   // tornem al valor original
//            [theSelf _updateValue];    // updatem el view
//        }
//    }];
//}


- (void)_checkPointForKey:(NSString*)key
{
    SWDictionaryPickerItem *item = [self _buttonItem];
    __weak id theSelf = self;
    [theSelf checkPointVerification:nil completion:^(BOOL verified, BOOL success)
    {
        if ( success )
        {
            [item.key evalWithStringConstant:(CFStringRef)(key)];
        }
        else
        {
            [item.continuousValue evalWithValue:item.key];   // tornem al valor original
            [theSelf _updateValue];    // updatem el view
        }
    }];
}



- (void)buttonTouchDown:(id)sender
{
}


- (void)buttonTouchUpInside:(id)sender
{
    SWDictionaryPickerItem *item = [self _buttonItem];
    
    //SWValue *values = item.dictionary;
    //NSInteger count = [values count];
    
    //NSString *format = [item.format valueAsString];
    
    NSDictionary *dict = [item.dictionary valueAsDictionary];
    NSString *key = [item.key valueAsString];
    
    NSArray *options = [dict allKeys];
    NSInteger index = [options indexOfObject:key];
    
    SWTableSelectionController *tsc = [[SWTableSelectionController alloc] initWithStyle:UITableViewStylePlain options:options];
    [tsc setPreferredContentSizeForViewInPopover];
    
    tsc.delegate = self;
    tsc.title = @"Select";
    tsc.swselectedOptionIndex = index;
    
    if ( IS_IPHONE )
    {
        _fpPopover = [[FPPopoverController alloc] initWithViewController:tsc];
        _fpPopover.border = NO;
        _fpPopover.tint = FPPopoverWhiteTint;
        _fpPopover.delegate = self;
        [_fpPopover presentPopoverFromView:_buttonView];
    }
    else
    {
        _popover = [[UIPopoverController alloc] initWithContentViewController:tsc];
        _popover.delegate = self;
        [_popover presentPopoverFromRect:_buttonView.bounds inView:_buttonView
                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}


- (void)tableSelection:(SWTableSelectionController *)controller didSelectOption:(NSString *)option
{
    SWDictionaryPickerItem *item = [self _buttonItem];
    [item.continuousValue evalWithString:option];   // posem el valor temporal
    
    [self _setViewValueForKey:option];   // updatem el view amb el valor temporal.
    // ^ Agafara el valor del model pero ja ens interesa doncs en definitiva es el que el usuari acabara tenint
    
    [self _checkPointForKey:option];
    [_popover dismissPopoverAnimated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _popover = nil;
    _fpPopover = nil;
}


#pragma mark - Private Methods

- (SWDictionaryPickerItem*)_buttonItem
{
    return (SWDictionaryPickerItem*)self.item;
}

- (void)_updateView
{
    [self _updateEnabledState];
    [self _updateLabel];
    [self _updateValue];
    [self _updateColor];
    [self _updateFont];
    [self _updateTextAlignement];
    [self _updateVerticalTextAlignment];
    
}


- (void)_setViewValueForKey:(NSString*)key
{
    SWDictionaryPickerItem *item = [self _buttonItem];
    NSString *format = [item.format valueAsString];
    
    SWValue *value = [item.dictionary valueForStringKey:key];
    NSString *option = [value valueAsStringWithFormat:format];
    
    [_buttonView setOverTitle:option];
}


//- (void)_updateValue
//{
//    SWDictionaryPickerItem *item = [self _buttonItem];
//    NSInteger index = [item.value valueAsInteger];
//    [self _setViewIndex:index];
//}

- (void)_updateValue
{
    SWDictionaryPickerItem *item = [self _buttonItem];
    NSString *key = [item.key valueAsString];
    [self _setViewValueForKey:key];
}


- (void)_updateTextAlignement
{
    SWDictionaryPickerItem *item = [self _buttonItem];
    SWTextAlignment textAlignment = [item.textAlignment valueAsInteger];
    
    NSTextAlignment aligment;
    
    switch ( textAlignment )
    {
        case SWTextAlignmentLeft:
            aligment = NSTextAlignmentLeft;
            break;
            
        default:
        case SWTextAlignmentCenter:
            aligment = NSTextAlignmentCenter;
            break;
            
        case SWTextAlignmentRight:
            aligment = NSTextAlignmentRight;
            break;
    }
    
    [_buttonView setTextAlignment:aligment];
}


- (void)_updateVerticalTextAlignment
{
    SWDictionaryPickerItem *item = [self _buttonItem];
    SWVerticalTextAlignment textAlignment = [item.verticalTextAlignment valueAsInteger];
    
    VerticalAlignment aligment;
    
    switch ( textAlignment )
    {
        case SWVerticalTextAlignmentTop:
            aligment = VerticalAlignmentTop;
            break;
            
        default:
        case SWVerticalTextAlignmentCenter:
            aligment = VerticalAlignmentMiddle;
            break;
            
        case SWVerticalTextAlignmentBottom:
            aligment = VerticalAlignmentBottom;
            break;
    }
    
    [_buttonView setVerticalTextAlignment:aligment];
}



- (void)_updateLabel
{    
}

- (void)_updateFont
{
    SWDictionaryPickerItem *item = [self _buttonItem];
    
    UIFont *font = [UIFont fontWithName:[item.font valueAsString] size:[item.fontSize valueAsDouble]];
    _buttonView.overFont = font;
}

- (void)_updateColor
{
    SWDictionaryPickerItem *item = [self _buttonItem];
    
    UInt32 rgbColor = item.color.valueAsRGBColor;

    [_buttonView setRgbTintColor:rgbColor overWhite:NO];
}

- (void)_updateActivedState
{
    SWDictionaryPickerItem *item = [self _buttonItem];

    BOOL active = item.active.valueAsBool;
    
    [_buttonView setUnactived:!active];
}


- (void)_updateEnabledState
{
    SWDictionaryPickerItem *item = [self _buttonItem];

    BOOL enabled = item.enabled.valueAsBool;
    
    //[_buttonView setUnactived:!enabled];
    [_buttonView setEnabled:enabled];
}


#pragma mark - SWExpressionObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWDictionaryPickerItem *item = [self _buttonItem];
    
    if (value == item.value || value == item.format)
    {
        [self _updateValue];
    }
    
    else if (value == item.dictionary)
    {
        [self _updateValue];
    }
    
    else if (value == item.color)
    {
        [self _updateColor];
    }
    
    else if ( value == item.textAlignment)
    {
        [self _updateTextAlignement];
    }
    
    else if ( value == item.verticalTextAlignment)
    {
        [self _updateVerticalTextAlignment];
    }
    
    else if (value == item.font || value == item.fontSize) 
    {
        [self _updateFont];
    }
    
    else if (value == item.enabled) 
    {
        [self _updateEnabledState];
        //[self _updateView];
    }
    
    else if (value == item.active)
    {
        [self _updateActivedState];
    }
    
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}

@end
