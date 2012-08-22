//
//  NLURLConnectionManager.h
//  Noctis
//
//  Created by Nick Lauer on 12-07-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol URLConnectionManagerDelegate <NSObject>
- (void)receiveFinishedData:(NSData *)data fromConnection:(NSURLConnection *)connection;
@end

@interface NLURLConnectionManager : NSObject <NSURLConnectionDataDelegate>

@property (weak, nonatomic) id <URLConnectionManagerDelegate> connectionManagerDelegate;
@property (strong, nonatomic) NSMutableData *data;

- (id)initWithDelegate:(id)delegate;

@end
