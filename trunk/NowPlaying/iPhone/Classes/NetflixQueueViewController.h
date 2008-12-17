//
//  NetflixQueueViewController.h
//  NowPlaying
//
//  Created by Cyrus Najmabadi on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NetflixModifyQueueDelegate.h"
#import "TappableImageViewDelegate.h"

@interface NetflixQueueViewController : UITableViewController<TappableImageViewDelegate, NetflixModifyQueueDelegate> {
@private
    AbstractNavigationController* navigationController;
    NSString* feedKey;
    Feed* feed;
    Queue* queue;
    
    UIBarButtonItem* backButton;
    BOOL upArrowTapped;
    
    NSMutableArray* mutableMovies;
    NSMutableArray* mutableSaved;
    IdentitySet* deletedMovies;
    IdentitySet* reorderedMovies;

    BOOL readonlyMode;
}

- (id) initWithNavigationController:(AbstractNavigationController*) navigationController
                            feedKey:(NSString*) feedKey;

@end
