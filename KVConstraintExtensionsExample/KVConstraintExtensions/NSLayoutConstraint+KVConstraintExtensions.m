//
//  NSLayoutConstraint+KVConstraintExtensions.m
//  KVConstraintExtensionsExample
//
//  Created by Welcome on 04/08/15.
//  Copyright (c) 2015 Keshav. All rights reserved.
//

#import "KVConstraintExtensions.h"

#pragma mark - Defualt constants values

const CGFloat defualtMultiplier = 1.0f;
const CGFloat defualtConstant =  0.0f;
const NSLayoutRelation defualtRelation = NSLayoutRelationEqual;
const CGFloat defualtLessMaxPriority = 999.99996 ;

@implementation NSLayoutConstraint (KVConstraintExtensions)

+ (CGFloat)defualtSpacingBetweenSiblings
{
    static NSLayoutConstraint *constraint;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIView *view = [UIView prepareNewViewForAutoLayout];
        constraint = [NSLayoutConstraint constraintsWithVisualFormat:@"[view]-[view]"                                                              options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)].firstObject;
    });
    
    return constraint.constant; // 20.0 expected
}

+ (CGFloat)defualtSpacingBetweenSuperview
{
    static NSLayoutConstraint *constraint;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIView *view = [UIView prepareNewViewForAutoLayout];
        UIView *Superview = [UIView prepareNewViewForAutoLayout];
        [Superview addSubview:view];
        constraint = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[view]"                                                                                 options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)].firstObject;
    });
    
    return constraint.constant; // 20.0 expected
}

+ (BOOL)isSelfConstraintAttribute:(NSLayoutAttribute)attribute {
    if ((attribute == NSLayoutAttributeWidth)||(attribute == NSLayoutAttributeHeight)||(attribute == (NSLayoutAttributeWidth|NSLayoutAttributeHeight))) {
        return YES;
    }
    return NO;
}

+ (BOOL)recognizedDirectionByAttribute:(NSLayoutAttribute)attribute toAttribute:(NSLayoutAttribute)toTttribute
{
    if (((attribute == NSLayoutAttributeTrailing) && (toTttribute == NSLayoutAttributeTrailing))) {
        return YES;    //   is Negative Direction
    }else if (((attribute == NSLayoutAttributeTrailing) && (toTttribute == NSLayoutAttributeLeading))) {
        return YES;    //   is Negative Direction
    }else if (((attribute == NSLayoutAttributeTrailing) && (toTttribute == NSLayoutAttributeLeft))) {
        return YES;    //   is Negative Direction
    } else if (((attribute == NSLayoutAttributeRight) && (toTttribute == NSLayoutAttributeRight))) {
        return YES;    //   is Negative Direction
    }else if (((attribute == NSLayoutAttributeRight) && (toTttribute == NSLayoutAttributeLeft))) {
        return YES;    //   is Negative Direction
    } else if (((attribute == NSLayoutAttributeRight) && (toTttribute == NSLayoutAttributeLeading))) {
        return YES;    //   is Negative Direction
    } else if (((attribute == NSLayoutAttributeBottom) && (toTttribute == NSLayoutAttributeBottom))) {
        return YES;    //   is Negative Direction
    } else if (((attribute == NSLayoutAttributeBottom) && (toTttribute == NSLayoutAttributeTop))) {
        return YES;    //   is Negative Direction
    }
    
    return NO;
}

+ (NSLayoutConstraint *)appliedConstraintForView:(UIView*)aView attribute:(NSLayoutAttribute)attribute {
    assert(aView!=nil);
    
    if ([self isSelfConstraintAttribute:attribute]) {
        
        KVLog(@"Tracing constrain in subview constraints, count = %@",@(aView.constraints.count));
        for (NSLayoutConstraint *actualConstraint in aView.constraints)
        {
            if ( (actualConstraint.firstItem == nil && actualConstraint.secondItem == aView)||
                (actualConstraint.firstItem == aView && actualConstraint.secondItem == nil) )
            {
                // In this case, this constraintint may be either widthConstraint or heightConstrain
                if (attribute == (actualConstraint.firstAttribute|actualConstraint.secondAttribute)) {
                    return actualConstraint;
                }
            }
            else if ( (actualConstraint.firstItem == aView )&&(actualConstraint.secondItem == aView ))
            {
                // In this case, this constraintint is only aspectRatioConstrain
                if (attribute == (actualConstraint.firstAttribute|actualConstraint.secondAttribute)) {
                    return actualConstraint;
                }
            } else {
                /* do some stuff for other work*/
            }
        }
    }
    else
    {
        KVLog(@"Tracing constrain in superview constraints, count = %@",@(aView.constraints.count));
        
        for (NSLayoutConstraint *actualConstraint in aView.superview.constraints)
        {
            if ( ((actualConstraint.firstItem == aView)&&(actualConstraint.secondItem == aView.superview))||
                ((actualConstraint.secondItem == aView )&&(actualConstraint.firstItem == aView.superview)) )
            {
                // In this case, this constraintint is only aspectRatioConstrain
                if ( (attribute == actualConstraint.firstAttribute)&&
                    (attribute == actualConstraint.secondAttribute) ) {
                    return actualConstraint;
                }
                else {
                    /* do some stuff for other work*/
                }
            }
        }
    }
    
    return nil;
}

- (BOOL)isEqualToConstraint:(NSLayoutConstraint *)aConstraint
{
    if (self.firstItem == aConstraint.firstItem &&
        self.firstAttribute == aConstraint.firstAttribute &&
        self.relation == aConstraint.relation &&
        self.secondItem == aConstraint.secondItem &&
        self.secondAttribute == aConstraint.secondAttribute &&
        self.multiplier == aConstraint.multiplier ) {
        return YES;
    }
    
    return NO;
}

- (NSLayoutConstraint *)swapConstraintItems
{
    return [NSLayoutConstraint constraintWithItem:self.secondItem
                                        attribute:self.secondAttribute
                                        relatedBy:self.relation
                                           toItem:self.firstItem
                                        attribute:self.firstAttribute
                                       multiplier:self.multiplier
                                         constant:self.constant];
}

- (NSLayoutConstraint *)modifyConstraintRelatedBy:(NSLayoutRelation)relation
{
    return [NSLayoutConstraint constraintWithItem:self.firstItem
                                        attribute:self.firstAttribute
                                        relatedBy:relation
                                           toItem:self.secondItem
                                        attribute:self.secondAttribute
                                       multiplier:self.multiplier
                                         constant:self.constant];
}

- (NSLayoutConstraint *)modifyConstraintMultiplierBy:(CGFloat)multiplier
{
    return [NSLayoutConstraint constraintWithItem:self.firstItem
                                        attribute:self.firstAttribute
                                        relatedBy:self.relation
                                           toItem:self.secondItem
                                        attribute:self.secondAttribute
                                       multiplier:multiplier
                                         constant:self.constant];
}

@end

@implementation NSArray (KV_ContainsConstraint)

- (NSLayoutConstraint *)containsAppliedConstraint:(NSLayoutConstraint *)appliedConstraint{
    for (NSLayoutConstraint *actualConstraint in self) {
        if ([actualConstraint isEqualToConstraint:appliedConstraint])
            return actualConstraint;
    }
    return nil;
}

@end