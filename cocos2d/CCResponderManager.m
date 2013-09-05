/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013 Lars Birkemose
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *
 * File autogenerated with Xcode. Adapted for cocos2d needs.
 */

#import "CCResponderManager.h"
#import "CCNode.h"
#import "CCDirector.h"
#import "CCDirectorMac.h"
#import "CCScene.h"

// -----------------------------------------------------------------
#pragma mark -
// -----------------------------------------------------------------

@implementation CCRunningResponder

@end

// -----------------------------------------------------------------
#pragma mark -
// -----------------------------------------------------------------

@implementation CCResponderManager
{
    __weak CCNode           *_responderList[CCResponderManagerBufferSize];
    int                     _responderListCount;
    BOOL                    _dirty;                                 // list of responders should be rebuild
    NSMutableArray          *_runningResponderList;                 // list of running responders
}

// -----------------------------------------------------------------
#pragma mark - create and destroy
// -----------------------------------------------------------------

+ (id)responderManager
{
    return([[self alloc] init]);
}

- (id)init
{
    self = [super init];
    NSAssert(self != nil, @"Unable to create class");
    
    // initalize
    _runningResponderList = [NSMutableArray array];
    // reset touch handling
    [self removeAllResponders];
    _dirty = YES;
    
    // done
    return(self);
}

// -----------------------------------------------------------------
#pragma mark - add and remove touch responders
// -----------------------------------------------------------------

- (void)buildResponderList
{
    // rebuild responder list
    [self removeAllResponders];
    [[CCDirector sharedDirector].runningScene buildResponderList];
    _dirty = NO;
}

// -----------------------------------------------------------------

- (void)addResponder:(CCNode *)responder
{
    _responderList[_responderListCount] = responder;
    _responderListCount ++;
    NSAssert(_responderListCount < CCResponderManagerBufferSize, @"Number of touchable nodes pr. scene can not exceed <%d>", CCResponderManagerBufferSize);
}

- (void)removeAllResponders
{    
    _responderListCount = 0;
}

// -----------------------------------------------------------------
#pragma mark - dirty
// -----------------------------------------------------------------

- (void)markAsDirty
{
    _dirty = YES;
}


// -----------------------------------------------------------------
#pragma mark - iOS touch handling -
// -----------------------------------------------------------------

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL responderCanAcceptTouch;
    
    if (_dirty != NO) [self buildResponderList];
    
    // go through all touches
    for (UITouch *touch in touches)
    {
        // scan backwards through touch responders
        for (int index = _responderListCount - 1; index >= 0; index --)
        {
            CCNode *node = _responderList[index];
            
            // check for hit test
            if ([node hitTestWithWorldPos:[[CCDirector sharedDirector] convertToGL:[touch locationInView:[CCDirector sharedDirector].view]]] != NO)
            {
                // if not a multi touch node, check if node already is being touched
                responderCanAcceptTouch = YES;
                if (node.isMultipleTouchEnabled == NO)
                {
                    // scan current touch objects, and break if object already has a touch
                    for (CCRunningResponder *responderEntry in _runningResponderList) if (responderEntry.target == node)
                    {
                        responderCanAcceptTouch = NO;
                        break;
                    }
                }                
                if (responderCanAcceptTouch == NO) break;
                
                // begin the touch
                self.eventProcessed = YES;
                if ([node respondsToSelector:@selector(touchesBegan:withEvent:)] != NO)
                    [node touchesBegan:[NSSet setWithObject:touch] withEvent:event];
 
                // if touch was processed, add it and break
                if (self.eventProcessed != NO)
                {
                    [self addResponder:node withTouch:touch andEvent:event];
                    break;
                }
            }
        }
    }
}

// -----------------------------------------------------------------

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_dirty != NO) [self buildResponderList];

    // go through all touches
    for (UITouch *touch in touches)
    {
        // get touch object
        CCRunningResponder *touchEntry = [self responderForEvent:event];
        
        // if a touch object was found
        if (touchEntry != nil)
        {
            CCNode *node = (CCNode *)touchEntry.target;
            
            // check if it locks touches
            if (node.isTouchLocked != NO)
            {
                // move the touch
                if ([node respondsToSelector:@selector(touchesMoved:withEvent:)] != NO)
                    [node touchesMoved:[NSSet setWithObject:touch] withEvent:event];
            }
            else
            {
                // as node does not lock touch, check if it was moved outside
                if ([node hitTestWithWorldPos:[[CCDirector sharedDirector] convertToGL:[touch locationInView:[CCDirector sharedDirector].view]]] == NO)
                {
                    // cancel the touch
                    if ([node respondsToSelector:@selector(touchesCancelled:withEvent:)] != NO)
                        [node touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
                    // remove from list
                    [_runningResponderList removeObject:touchEntry];
                }
                else
                {
                    // move the touch
                    if ([node respondsToSelector:@selector(touchesMoved:withEvent:)] != NO)
                        [node touchesMoved:[NSSet setWithObject:touch] withEvent:event];
                }
            }
        }
        else
        {
            // scan backwards through touch responders
            for (int index = _responderListCount - 1; index >= 0; index --)
            {
                CCNode *node = _responderList[index];
            
                // if the touch responder does not lock touch, it will receive a touchesBegan if a touch is moved inside
                if ((node.isTouchLocked == NO) && ([node hitTestWithWorldPos:[[CCDirector sharedDirector] convertToGL:[touch locationInView:[CCDirector sharedDirector].view ]]] != NO))
                {
                    // begin the touch
                    self.eventProcessed = YES;
                    if ([node respondsToSelector:@selector(touchesBegan:withEvent:)] != NO)
                        [node touchesBegan:[NSSet setWithObject:touch] withEvent:event];
                    
                    // if touch was accepted, add it and break
                    if (self.eventProcessed != NO)
                    {
                        [self addResponder:node withTouch:touch andEvent:event];
                        break;
                    }
                }
            }
        }
    }
}

// -----------------------------------------------------------------

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_dirty != NO) [self buildResponderList];

    // go through all touches
    for (UITouch *touch in touches)
    {
        // get touch object
        CCRunningResponder *touchEntry = [self responderForEvent:event];
        
        if (touchEntry != nil)
        {
            CCNode *node = (CCNode *)touchEntry.target;
            
            // end the touch
            if ([node respondsToSelector:@selector(touchesEnded:withEvent:)] != NO)
                [node touchesEnded:[NSSet setWithObject:touch] withEvent:event];
            // remove from list
            [_runningResponderList removeObject:touchEntry];
        }
    }
}

// -----------------------------------------------------------------

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_dirty != NO) [self buildResponderList];

    // go through all touches
    for (UITouch *touch in touches)
    {
        // get touch object
        CCRunningResponder *touchEntry = [self responderForEvent:event];
        
        if (touchEntry != nil)
        {
            CCNode *node = (CCNode *)touchEntry.target;

            // cancel the touch
            if ([node respondsToSelector:@selector(touchesCancelled:withEvent:)] != NO)
                [node touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
            // remove from list
            [_runningResponderList removeObject:touchEntry];
        }
    }
}

// -----------------------------------------------------------------
#pragma mark - iOS helper functions
// -----------------------------------------------------------------
// finds a responder object for an event

- (CCRunningResponder *)responderForEvent:(UIEvent *)event
{
    for (CCRunningResponder *touchEntry in _runningResponderList)
    {
        if (touchEntry.event == event) return(touchEntry);
    }
    return(nil);
}

// -----------------------------------------------------------------
// adds a responder object ( running responder ) to the responder object list

- (void)addResponder:(CCNode *)node withTouch:(UITouch *)touch andEvent:(UIEvent *)event
{
    CCRunningResponder *touchEntry;
    
    // create a new touch object
    touchEntry = [[CCRunningResponder alloc] init];
    touchEntry.target = node;
    touchEntry.touch = touch;
    touchEntry.event = event;
    [_runningResponderList addObject:touchEntry];
}

// -----------------------------------------------------------------

#else

// -----------------------------------------------------------------
#pragma mark - Mac mouse handling -
// -----------------------------------------------------------------

- (void)mouseDown:(NSEvent *)theEvent button:(CCMouseButton)button
{
    NSAssert([self responderForButton:button] == nil, @"Unexpected Mouse State");
    
    if (_dirty != NO) [self buildResponderList];
    
    // scan backwards through mouse responders
    for (int index = _responderListCount - 1; index >= 0; index --)
    {
        CCNode *node = _responderList[index];
        
        // check for hit test
        if ([node hitTestWithWorldPos:[[CCDirector sharedDirector] convertEventToGL:theEvent]] != NO)
        {
            // begin the mouse down
            self.eventProcessed = YES;
            switch (button)
            {
                case CCMouseButtonLeft: if ([node respondsToSelector:@selector(mouseDown:)] != NO) [node mouseDown:theEvent]; break;
                case CCMouseButtonRight: if ([node respondsToSelector:@selector(rightMouseDown:)] != NO) [node rightMouseDown:theEvent]; break;
                case CCMouseButtonOther: if ([node respondsToSelector:@selector(otherMouseDown:)] != NO) [node otherMouseDown:theEvent]; break;
            }
            
            // if mouse was processed, remember it and break
            if (self.eventProcessed != NO)
            {
                [self addResponder:node withButton:button];
                break;
            }
        }
    }
}

// TODO: Should all mouse buttons call mouseDragged?
// As it is now, only mouseDragged gets called if several buttons are pressed

- (void)mouseDragged:(NSEvent *)theEvent button:(CCMouseButton)button
{
    if (_dirty != NO) [self buildResponderList];
    
    CCRunningResponder *responder = [self responderForButton:button];
    
    if (responder != nil)
    {
        CCNode *node = (CCNode *)responder.target;
        
        // check if it locks mouse
        if (node.isTouchLocked != NO)
        {
            // move the mouse
            switch (button)
            {
                case CCMouseButtonLeft: if ([node respondsToSelector:@selector(mouseDragged:)] != NO) [node mouseDragged:theEvent]; break;
                case CCMouseButtonRight: if ([node respondsToSelector:@selector(rightMouseDragged:)] != NO) [node rightMouseDragged:theEvent]; break;
                case CCMouseButtonOther: if ([node respondsToSelector:@selector(otherMouseDragged:)] != NO) [node otherMouseDragged:theEvent]; break;
            }
        }
        else
        {
            // as node does not lock mouse, check if it was moved outside
            if ([node hitTestWithWorldPos:[[CCDirector sharedDirector] convertEventToGL:theEvent]] == NO)
            {
                [_runningResponderList removeObject:responder];
            }
            else
            {
                // move the mouse
                switch (button)
                {
                    case CCMouseButtonLeft: if ([node respondsToSelector:@selector(mouseDragged:)] != NO) [node mouseDragged:theEvent]; break;
                    case CCMouseButtonRight: if ([node respondsToSelector:@selector(rightMouseDragged:)] != NO) [node rightMouseDragged:theEvent]; break;
                    case CCMouseButtonOther: if ([node respondsToSelector:@selector(otherMouseDragged:)] != NO) [node otherMouseDragged:theEvent]; break;
                }
            }
        }
    }
    else
    {
        // scan backwards through mouse responders
        for (int index = _responderListCount - 1; index >= 0; index --)
        {
            CCNode *node = _responderList[index];
            
            // if the mouse responder does not lock mouse, it will receive a mouseDown if mouse is moved inside
            if ((node.isTouchLocked == NO) && ([node hitTestWithWorldPos:[[CCDirector sharedDirector] convertEventToGL:theEvent]] != NO))
            {
                // begin the mouse down
                self.eventProcessed = YES;
                switch (button)
                {
                    case CCMouseButtonLeft: if ([node respondsToSelector:@selector(mouseDown:)] != NO) [node mouseDown:theEvent]; break;
                    case CCMouseButtonRight: if ([node respondsToSelector:@selector(rightMouseDown:)] != NO) [node rightMouseDown:theEvent]; break;
                    case CCMouseButtonOther: if ([node respondsToSelector:@selector(otherMouseDown:)] != NO) [node otherMouseDown:theEvent]; break;
                }
                
                // if mouse was accepted, add it and break
                if (self.eventProcessed != NO)
                {
                    [self addResponder:node withButton:button];
                    break;
                }
            }
        }
    }
}

- (void)mouseUp:(NSEvent *)theEvent button:(CCMouseButton)button
{
    if (_dirty != NO) [self buildResponderList];
    
    CCRunningResponder *responder = [self responderForButton:button];
    if (responder != nil)
    {
        CCNode *node = (CCNode *)responder.target;
        
        // end the mouse
        switch (button)
        {
            case CCMouseButtonLeft: if ([node respondsToSelector:@selector(mouseUp:)] != NO) [node mouseUp:theEvent]; break;
            case CCMouseButtonRight: if ([node respondsToSelector:@selector(rightMouseUp:)] != NO) [node rightMouseUp:theEvent]; break;
            case CCMouseButtonOther: if ([node respondsToSelector:@selector(otherMouseUp:)] != NO) [node otherMouseUp:theEvent]; break;
        }
        // remove
        [_runningResponderList removeObject:responder];
    }
}

// -----------------------------------------------------------------

- (void)mouseDown:(NSEvent *)theEvent
{
    [self mouseDown:theEvent button:CCMouseButtonLeft];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [self mouseDragged:theEvent button:CCMouseButtonLeft];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self mouseUp:theEvent button:CCMouseButtonLeft];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    [self mouseDown:theEvent button:CCMouseButtonRight];
}

- (void)rightMouseDragged:(NSEvent *)theEvent
{
    [self mouseDragged:theEvent button:CCMouseButtonRight];
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    [self mouseUp:theEvent button:CCMouseButtonRight];
}

- (void)otherMouseDown:(NSEvent *)theEvent
{
    [self mouseDown:theEvent button:CCMouseButtonOther];
}

- (void)otherMouseDragged:(NSEvent *)theEvent
{
    [self mouseDragged:theEvent button:CCMouseButtonOther];
}

- (void)otherMouseUp:(NSEvent *)theEvent
{
    [self mouseUp:theEvent button:CCMouseButtonOther];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    if (_dirty != NO) [self buildResponderList];

    // if otherMouse is active, scrollWheel goes to that node
    // otherwise, scrollWheel goes to the node under the cursor
    CCRunningResponder *responder = [self responderForButton:CCMouseButtonOther];
    
    if (responder != nil)
    {
        CCNode *node = (CCNode *)responder.target;
        
        self.eventProcessed = YES;
        if ([node respondsToSelector:@selector(scrollWheel:)] != NO) [node scrollWheel:theEvent];
    
        // if mouse was accepted, return
        if (self.eventProcessed != NO) return;
    }
    
    // scan through responders, and find first one
    for (int index = _responderListCount - 1; index >= 0; index --)
    {
        CCNode *node = _responderList[index];
        
        // check for hit test
        if ([node hitTestWithWorldPos:[[CCDirector sharedDirector] convertEventToGL:theEvent]] != NO)
        {
            self.eventProcessed = YES;
            if ([node respondsToSelector:@selector(scrollWheel:)] != NO) [node scrollWheel:theEvent];
        
            // if mouse was accepted, break
            if (self.eventProcessed != NO) break;
        }
    }
}

/** Moved, Entered and Exited is not supported
 @since v2.5
 */

- (void)mouseMoved:(NSEvent *)theEvent
{
    
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    
}

- (void)mouseExited:(NSEvent *)theEvent
{
    
}

// -----------------------------------------------------------------
#pragma mark - Mac helper functions
// -----------------------------------------------------------------
// finds a responder object for an event

- (CCRunningResponder *)responderForButton:(CCMouseButton)button
{
    for (CCRunningResponder *touchEntry in _runningResponderList)
    {
        if (touchEntry.button == button) return(touchEntry);
    }
    return(nil);
}

// -----------------------------------------------------------------
// adds a responder object ( running responder ) to the responder object list

- (void)addResponder:(CCNode *)node withButton:(CCMouseButton)button
{
    CCRunningResponder *touchEntry;
    
    // create a new touch object
    touchEntry = [[CCRunningResponder alloc] init];
    touchEntry.target = node;
    touchEntry.button = button;
    [_runningResponderList addObject:touchEntry];
}

// -----------------------------------------------------------------

#endif

// -----------------------------------------------------------------

@end





































