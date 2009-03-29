// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "PostersViewController.h"

#import "AbstractNavigationController.h"
#import "AppDelegate.h"
#import "ColorCache.h"
#import "LargePosterCache.h"
#import "Model.h"
#import "NotificationCenter.h"
#import "TappableScrollView.h"
#import "TappableScrollViewDelegate.h"
#import "ThreadingUtilities.h"

@interface PostersViewController()
@property (retain) Movie* movie;
@property (retain) NSMutableDictionary* pageNumberToView;
@property (retain) TappableScrollView* scrollView;
@property (retain) UILabel* savingLabel;
#ifndef IPHONE_OS_VERSION_3
@property (retain) UIToolbar* toolbar;
#endif
@end


@implementation PostersViewController

const double TRANSLUCENCY_LEVEL = 0.9;
const int ACTIVITY_INDICATOR_TAG = -1;
const int LABEL_TAG = -2;
const int IMAGE_TAG = -3;
const double LOAD_DELAY = 1;

@synthesize pageNumberToView;
@synthesize movie;
@synthesize scrollView;
@synthesize savingLabel;
#ifndef IPHONE_OS_VERSION_3
@synthesize toolbar;
#endif

- (void) dealloc {
    self.pageNumberToView = nil;
    self.movie = nil;
    self.scrollView = nil;
    self.savingLabel = nil;
#ifndef IPHONE_OS_VERSION_3
    self.toolbar = nil;
#endif
    
    [super dealloc];
}


- (id) initWithNavigationController:(AbstractNavigationController*) navigationController_
                              movie:(Movie*) movie_
                        posterCount:(NSInteger) posterCount_ {
    if (self = [super initWithNavigationController:navigationController_]) {
        self.movie = movie_;
        posterCount = posterCount_;
        
#ifdef IPHONE_OS_VERSION_3
        self.wantsFullScreenLayout = YES;
#endif
        
        self.pageNumberToView = [NSMutableDictionary dictionary];
    }
    
    return self;
}


- (Model*) model {
    return [Model model];
}


- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    
    [self.abstractNavigationController setNavigationBarHidden:YES animated:YES];
    
#ifdef IPHONE_OS_VERSION_3
    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
    [self.abstractNavigationController setToolbarHidden:NO animated:YES];
    self.abstractNavigationController.toolbar.barStyle = UIBarStyleBlack;
    self.abstractNavigationController.toolbar.translucent = YES;
#else
    [[UIApplication sharedApplication] setStatusBarStyle:UIBarStyleBlackTranslucent animated:YES];
#endif
}


- (void) viewWillDisappear:(BOOL) animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
    [self.abstractNavigationController setNavigationBarHidden:NO animated:YES];
    
#ifdef IPHONE_OS_VERSION_3
    [self.abstractNavigationController setToolbarHidden:YES animated:YES];
#else
    [[UIApplication sharedApplication] setStatusBarStyle:UIBarStyleDefault animated:YES];
#endif
}


- (UILabel*) createDownloadingLabel:(NSString*) text; {
    UILabel* downloadingLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    downloadingLabel.tag = LABEL_TAG;
    downloadingLabel.backgroundColor = [UIColor clearColor];
    downloadingLabel.opaque = NO;
    downloadingLabel.text = text;
    downloadingLabel.font = [UIFont boldSystemFontOfSize:24];
    downloadingLabel.textColor = [UIColor whiteColor];
    [downloadingLabel sizeToFit];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    CGRect labelFrame = downloadingLabel.frame;
    labelFrame.origin.x = (int)((frame.size.width - labelFrame.size.width) / 2.0);
    labelFrame.origin.y = (int)((frame.size.height - labelFrame.size.height) / 2.0);
    downloadingLabel.frame = labelFrame;
    
    return downloadingLabel;
}


- (UIActivityIndicatorView*) createActivityIndicator:(UILabel*) label {
    UIActivityIndicatorView* activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    activityIndicator.tag = ACTIVITY_INDICATOR_TAG;
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator sizeToFit];
    
    CGRect labelFrame = label.frame;
    CGRect activityFrame = activityIndicator.frame;
    
    activityFrame.origin.x = (int)(labelFrame.origin.x - activityFrame.size.width) - 5;
    activityFrame.origin.y = (int)(labelFrame.origin.y + (labelFrame.size.height / 2) - (activityFrame.size.height / 2));
    activityIndicator.frame = activityFrame;
    
    [activityIndicator startAnimating];
    
    return activityIndicator;
}


- (void) createDownloadViews:(UIView*) pageView page:(NSInteger) page {
    NSString* text;
    if ([self.model.largePosterCache posterExistsForMovie:movie index:page]) {
        text = NSLocalizedString(@"Loading poster", nil);
    } else {
        text = NSLocalizedString(@"Downloading poster", nil);
    }
    UILabel* downloadingLabel = [self createDownloadingLabel:text];
    UIActivityIndicatorView* activityIndicator = [self createActivityIndicator:downloadingLabel];
    
    CGRect frame = activityIndicator.frame;
    double width = frame.size.width;
    frame.origin.x = (int)(frame.origin.x + width / 2);
    activityIndicator.frame = frame;
    
    frame = downloadingLabel.frame;
    frame.origin.x = (int)(frame.origin.x + width / 2);
    downloadingLabel.frame = frame;
    
    [pageView addSubview:activityIndicator];
    [pageView addSubview:downloadingLabel];
}


- (UIImageView*) createImageView:(UIImage*) image {
    UIImageView* imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
    imageView.tag = IMAGE_TAG;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    if (image.size.width > image.size.height) {
        int offset = (int)((frame.size.height - frame.size.width) / 2.0);
        CGRect imageFrame = CGRectMake(-offset, offset + 5, frame.size.height, frame.size.width - 10);
        
        imageView.frame = imageFrame;
        imageView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    } else {
        CGRect imageFrame = CGRectMake(5, 0, frame.size.width - 10, frame.size.height);
        imageView.frame = imageFrame;
        imageView.clipsToBounds = YES;
    }
    
    return imageView;
}


- (TappableScrollView*) createScrollView {
    CGRect frame = [UIScreen mainScreen].bounds;
    
    self.scrollView = [[[TappableScrollView alloc] initWithFrame:frame] autorelease];
    scrollView.delegate = self;
    scrollView.tapDelegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.directionalLockEnabled = YES;
    scrollView.autoresizingMask = 0;
    scrollView.backgroundColor = [UIColor blackColor];
    
    frame.size.width *= posterCount;
    scrollView.contentSize = frame.size;
    
    return scrollView;
}


- (void) disableActivityIndicator:(UIView*) pageView {
    id view = [pageView viewWithTag:ACTIVITY_INDICATOR_TAG];
    [view stopAnimating];
    [view removeFromSuperview];
    
    view = [pageView viewWithTag:LABEL_TAG];
    [view removeFromSuperview];
}


- (void) addImage:(UIImage*) image toView:(UIView*) pageView {
    [self disableActivityIndicator:pageView];
    
    UIImageView* imageView = [self createImageView:image];
    [pageView addSubview:imageView];
    imageView.alpha = 0;
    
    [UIView beginAnimations:nil context:NULL];
    {
        imageView.alpha = 1;
    }
    [UIView commitAnimations];
}


- (void) addImageToView:(NSArray*) arguments {
    NSNumber* index = [arguments objectAtIndex:0];
    if (index.intValue < (currentPage - 1) ||
        index.intValue > (currentPage + 1)) {
        return;
    }
    
    if (scrollView.dragging || scrollView.decelerating) {
        // should this be 'afterDelay:0'?  That way we do it on the next run
        // loop cycle (which should happen after dragging/decelerating is done).
        // 1/30/09. Right now, i'm going with 'no'.  I'm not totally certain if this
        // won't call back into us immediately, and i don't want to peg the CPU
        // while dragging.  Waiting a sec is safer.
        [self performSelector:@selector(addImageToView:) withObject:arguments afterDelay:1];
        return;
    }
    
    [self addImage:[arguments objectAtIndex:1] toView:[arguments objectAtIndex:2]];
}


- (void) loadPage:(NSInteger) page
            delay:(double) delay {
    if (page < 0 || page >= posterCount) {
        return;
    }
    
    NSNumber* pageNumber = [NSNumber numberWithInt:page];
    if ([pageNumberToView objectForKey:pageNumber] != nil) {
        return;
    }
    
    CGRect frame = [UIScreen mainScreen].bounds;
    frame.origin.x = page * frame.size.width;
    
    UIView* pageView = [[[UIView alloc] initWithFrame:frame] autorelease];
    pageView.backgroundColor = [UIColor blackColor];
    pageView.tag = page;
    pageView.clipsToBounds = YES;
    
    UIImage* image = nil;
    if (delay == 0) {
        image = [self.model.largePosterCache posterForMovie:movie index:page];
    }
    
    if (image != nil) {
        [self addImage:image toView:pageView];
    } else {
        [self createDownloadViews:pageView page:page];
        NSArray* indexAndPageView = [NSArray arrayWithObjects:[NSNumber numberWithInt:page], pageView, nil];
        [self performSelector:@selector(loadPoster:)
                   withObject:indexAndPageView
                   afterDelay:delay];
    }
    
    [scrollView addSubview:pageView];
    [pageNumberToView setObject:pageView forKey:pageNumber];
}


- (void) loadPoster:(NSArray*) indexAndPageView {
    if (shutdown) {
        return;
    }
    
    NSNumber* index = [indexAndPageView objectAtIndex:0];
    
    if (index.intValue < (currentPage - 1) ||
        index.intValue > (currentPage + 1)) {
        return;
    }
    
    if (scrollView.dragging || scrollView.decelerating) {
        [self performSelector:@selector(loadPoster:) withObject:indexAndPageView afterDelay:1];
        return;
    }
    
    UIImage* image = [self.model.largePosterCache posterForMovie:movie index:index.intValue];
    if (image == nil) {
        [self performSelector:@selector(loadPoster:)
                   withObject:indexAndPageView
                   afterDelay:LOAD_DELAY];
    } else {
        UIView* pageView = [indexAndPageView objectAtIndex:1];
        NSArray* arguments = [NSArray arrayWithObjects:index, image, pageView, nil];
        [self addImageToView:arguments];
    }
}


#ifndef IPHONE_OS_VERSION_3
- (void) setToolbarItems:(NSArray*) items animated:(BOOL) animated {
    [toolbar setItems:items animated:YES];
}
#endif


- (void) setupSavingToolbar {
    self.savingLabel = [[[UILabel alloc] init] autorelease];
    savingLabel.font = [UIFont boldSystemFontOfSize:20];
    savingLabel.textColor = [UIColor whiteColor];
    savingLabel.backgroundColor = [UIColor clearColor];
    savingLabel.opaque = NO;
    savingLabel.shadowColor = [UIColor darkGrayColor];
    savingLabel.text = NSLocalizedString(@"Saving", nil);
    [savingLabel sizeToFit];
    
    NSMutableArray* items = [NSMutableArray array];
    
    [items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
    [items addObject:[[[UIBarButtonItem alloc] initWithCustomView:savingLabel] autorelease]];
    
    UIActivityIndicatorView* savingActivityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    [savingActivityIndicator startAnimating];
    
    [items addObject:[[[UIBarButtonItem alloc] initWithCustomView:savingActivityIndicator] autorelease]];
    [items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
    
    [self setToolbarItems:items animated:YES];
}


- (void) updateSavingToolbar:(NSString*) text {
    savingLabel.text = text;
    [savingLabel sizeToFit];
}


- (void) setupNormalToolbar {
    NSString* title =
    [NSString stringWithFormat:
     NSLocalizedString(@"%d of %d", nil), (currentPage + 1), posterCount];
    
    UILabel* label = [[[UILabel alloc] init] autorelease];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.shadowColor = [UIColor darkGrayColor];
    [label sizeToFit];
    
    NSMutableArray* items = [NSMutableArray array];
    
    [items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onActionTapped:)] autorelease]];
    
    [items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
    [items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
    
    UIBarButtonItem* leftArrow = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LeftArrow.png"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(onLeftTapped:)] autorelease];
    [items addObject:leftArrow];
    
    [items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
    
    UIBarItem* titleItem = [[[UIBarButtonItem alloc] initWithCustomView:label] autorelease];
    [items addObject:titleItem];
    
    [items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
    
    UIBarButtonItem* rightArrow = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"RightArrow.png"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(onRightTapped:)] autorelease];
    [items addObject:rightArrow];
    
    
    [items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
    
    UIBarButtonItem* doneItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneTapped:)] autorelease];
    [items addObject:doneItem];
    
    [self setToolbarItems:items animated:YES];
    
    if (currentPage <= 0) {
        leftArrow.enabled = NO;
    }
    
    if (currentPage >= (posterCount - 1)) {
        rightArrow.enabled = NO;
    }
}


- (void) setupToolbar {
    if (saving) {
        return;
    }
    [self setupNormalToolbar];
}


- (void) clearAndLoadPages {
    for (NSNumber* pageNumber in pageNumberToView.allKeys) {
        if (pageNumber.intValue < (currentPage - 1) || pageNumber.intValue > (currentPage + 1)) {
            UIView* pageView = [pageNumberToView objectForKey:pageNumber];
            [self disableActivityIndicator:pageView];
            
            [pageView removeFromSuperview];
            [pageNumberToView removeObjectForKey:pageNumber];
        }
    }
    
    [self loadPage:currentPage - 1 delay:LOAD_DELAY];
    [self loadPage:currentPage     delay:LOAD_DELAY];
    [self loadPage:currentPage + 1 delay:LOAD_DELAY];
}


- (void) setPage:(NSInteger) page {
    if (page != currentPage) {
        currentPage = page;
        
        [self setupToolbar];
        [self clearAndLoadPages];
    }
}


- (void) hideToolBar {
    if (saving) {
        return;
    }
    
#ifdef IPHONE_OS_VERSION_3
    [self.abstractNavigationController setToolbarHidden:YES animated:YES];
#else
    [UIView beginAnimations:nil context:NULL];
    {
        toolbar.alpha = 0;
    }
    [UIView commitAnimations];
#endif
}


- (void) showToolBar {
#ifdef IPHONE_OS_VERSION_3
    [self.abstractNavigationController setToolbarHidden:NO animated:YES];
#else
    [UIView beginAnimations:nil context:NULL];
    {
        toolbar.alpha = 1;
    }
    [UIView commitAnimations];
#endif
}


- (void) onRightTapped:(id) sender {
    CGRect rect = [UIScreen mainScreen].bounds;
    rect.origin.x = (currentPage + 1) * rect.size.width;
    [scrollView scrollRectToVisible:rect animated:YES];
    [self setPage:currentPage + 1];
    [self showToolBar];
}


- (void) onLeftTapped:(id) sender {
    CGRect rect = [UIScreen mainScreen].bounds;
    rect.origin.x = (currentPage - 1) * rect.size.width;
    [scrollView scrollRectToVisible:rect animated:YES];
    [self setPage:currentPage - 1];
    [self showToolBar];
}


- (void) onActionTapped:(id) sender {
    UIActionSheet* actionSheet;
    if (posterCount > 1 && [self.model.largePosterCache allPostersDownloadedForMovie:movie]) {
        actionSheet =
        [[[UIActionSheet alloc] initWithTitle:nil
                                     delegate:self
                            cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                       destructiveButtonTitle:nil
                            otherButtonTitles:NSLocalizedString(@"Save to Photo Library", nil),
          NSLocalizedString(@"Save All to Photo Library", nil), nil] autorelease];
    } else {
        actionSheet =
        [[[UIActionSheet alloc] initWithTitle:nil
                                     delegate:self
                            cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                       destructiveButtonTitle:nil
                            otherButtonTitles:NSLocalizedString(@"Save to Photo Library", nil), nil] autorelease];
    }
    
    [actionSheet showInView:[AppDelegate window]];
}


- (void) reportSingleSave:(NSNumber*) number {
    NSString* text = [NSString stringWithFormat:NSLocalizedString(@"Saving %d of %d", nil), number.integerValue + 1, posterCount];
    [self updateSavingToolbar:text];
}


- (void) saveImage:(NSInteger) index
         nextIndex:(NSInteger) nextIndex {
    UIImage* image = [self.model.largePosterCache posterForMovie:movie index:index];
    if (image == nil) {
        [self performSelectorOnMainThread:@selector(onSavingComplete) withObject:nil waitUntilDone:NO];
    } else {
        if (nextIndex != -1) {
            [self performSelectorOnMainThread:@selector(reportSingleSave:) withObject:[NSNumber numberWithInteger:index] waitUntilDone:NO];
        }
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (void*)nextIndex);
    }
}


- (void)                 image:(UIImage*) image
      didFinishSavingWithError:(NSError*) error
                   contextInfo:(void*) contextInfo {
    NSInteger nextIndex = (NSInteger)contextInfo;
    [ThreadingUtilities backgroundSelector:@selector(saveMultipleImages:)
                                  onTarget:self
                                withObject:[NSNumber numberWithInteger:nextIndex]
                                      gate:nil
                                   visible:YES];
}


- (void) onSavingComplete {
    saving = NO;
    [self setupToolbar];
}


- (void) saveMultipleImages:(NSNumber*) startNumber {
    NSInteger startIndex = startNumber.integerValue;
    [self saveImage:startIndex nextIndex:startIndex + 1];
}


- (void) saveSingleImage:(NSNumber*) number {
    [self saveImage:number.integerValue nextIndex:-1];
}


- (void) actionSheet:(UIActionSheet*) actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (saving) {
        return;
    }
    saving = YES;
    
    [self setupSavingToolbar];
    
    if (buttonIndex == 0) {
        [ThreadingUtilities backgroundSelector:@selector(saveSingleImage:)
                                      onTarget:self
                                    withObject:[NSNumber numberWithInteger:currentPage]
                                          gate:nil
                                       visible:YES];
    } else {
        [ThreadingUtilities backgroundSelector:@selector(saveMultipleImages:)
                                      onTarget:self
                                    withObject:[NSNumber numberWithInteger:0]
                                          gate:nil
                                       visible:YES];
    }
}


- (void) createToolbar {
#ifndef IPHONE_OS_VERSION_3
    CGRect webframe = self.view.frame;
    webframe.origin.x = 0;
    webframe.origin.y = 0;
    
    CGRect toolbarFrame;
    CGRectDivide(webframe, &toolbarFrame, &webframe, 42, CGRectMaxYEdge);
    
    self.toolbar = [[[UIToolbar alloc] initWithFrame:toolbarFrame] autorelease];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    toolbar.barStyle = UIBarStyleBlackTranslucent;
#endif
}


- (void) loadView {
    [super loadView];
    
    [self createScrollView];
    [self createToolbar];
    
    [self setupToolbar];
    [self showToolBar];
    
    // load the first two pages.  Try to load the first one immediately.
    [self loadPage:0 delay:0];
    [self loadPage:1 delay:LOAD_DELAY];
    
    [self.view addSubview:scrollView];
    
#ifndef IPHONE_OS_VERSION_3
    [self.view addSubview:toolbar];
    [self.view bringSubviewToFront:toolbar];
#endif
}


- (void) dismiss {
    shutdown = YES;
    [self.abstractNavigationController hidePostersView];
}


- (void) onDoneTapped:(id) argument {
    [self dismiss];
}


- (void) scrollView:(TappableScrollView*) scrollView
          wasTapped:(NSInteger) tapCount
            atPoint:(CGPoint) point {
    if (saving) {
        return;
    }
    
    if (posterCount == 1) {
        // just dismiss us
        [self dismiss];
    } else {
#ifdef IPHONE_OS_VERSION_3
        if (self.abstractNavigationController.toolbarHidden) {
#else
            if (toolbar.alpha == 0) {
#endif
                [self showToolBar];
            } else {
                [self hideToolBar];
            }
        }
    }
    
    
    - (void) scrollViewWillBeginDragging:(UIScrollView*) scrollView {
        [self hideToolBar];
    }
    
    
    - (void) scrollViewDidEndDecelerating:(UIScrollView*) view {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger page = (NSInteger)((scrollView.contentOffset.x + pageWidth / 2) / pageWidth);
        
        [self setPage:page];
    }
    
    
    - (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation {
        return NO;
    }
    
@end