//
//  NXMOpenCommand.m
//  nuxeo-web-mobile
//
//  Created by Arnaud Kervern on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NXMOpenCommand.h"
#import "NSData+Additions.h"

#pragma mark -

@implementation NXMOpenCommand

#pragma mark -
#pragma mark CordovaCommands methods

-(void)openURL:(CDVInvokedUrlCommand*)command {
    NSString* url = [command.arguments objectAtIndex:0 withDefault:@"about:blank"];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [self.webView loadRequest:request];
    [request release];
}

-(void)openServer:(CDVInvokedUrlCommand*)command {
    NSString* url = [command.arguments objectAtIndex:0 withDefault:@"about:blank"];
    NSString* login = [command.arguments objectAtIndex:1 withDefault:nil];
    NSString* password = [command.arguments objectAtIndex:2 withDefault:nil];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    if (login != nil && password != nil) {
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", login, password];
        NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"basic %@", [authData base64Encoding]];
        [request setValue:authValue forHTTPHeaderField:@"authorization"];
        
        //NSString *loginUrl = [NSString stringWithFormat:@"%@%@", request.URL.absoluteString, @"/site/mobile/auth/login"];
        NSString *loginUrl = [NSString stringWithFormat:@"%@%@", request.URL.absoluteString, @"/site/mobile"];
        [request setURL:[NSURL URLWithString:loginUrl]];
    }
    [self.webView loadRequest:request];
    [request release];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

-(void)askUser:(CDVInvokedUrlCommand*)command {
    UIActionSheet* sheet = [[[UIActionSheet alloc] initWithTitle:@"What file do you want to upload?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
    [sheet addButtonWithTitle:@"from library"];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [sheet addButtonWithTitle:@"from camera"];
    }
    
    NSString* fileName = [command.arguments objectAtIndex:0 withDefault:nil];
    if (fileName != nil) {
        [sheet addButtonWithTitle:fileName];
    }
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    [sheet showInView:self.webView];
}

-(void)presentingDocument:(CDVInvokedUrlCommand*)command {
    NSString *anUrl = [command.arguments objectAtIndex:0 withDefault:nil];
    NSLog(@"passingURL: %@", anUrl);
    NSURL *url = [NSURL fileURLWithPath:anUrl];
    
    UIDocumentInteractionController *interactionController = [[UIDocumentInteractionController interactionControllerWithURL: url] retain];
    interactionController.delegate = self;
    if (![interactionController presentOptionsMenuFromRect:CGRectZero inView:self.webView animated:YES]) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"alert('No installed application associated with this kind of document.');"];
    }
}

#pragma mark -
#pragma mark Internal methods

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    NSLog(@"UIDocumentInteractionController correctly released");
    [controller release];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    NSLog(@"UIDocumentInteractionController correctly released");
    [controller release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //NSLog(@"Button pressed: %d", buttonIndex);
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    NSString* btnLabel = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([btnLabel isEqualToString:@"from library"]) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"NXCordova.openLibrary();"];
    }
    else if ([btnLabel isEqualToString:@"from camera"]) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"NXCordova.takePicture();"];
    }
    else if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"NXCordova.uploadFile();"];
    }
}

@end
