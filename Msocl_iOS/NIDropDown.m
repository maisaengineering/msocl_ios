//
//  NIDropDown.m
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import "NIDropDown.h"
#import "QuartzCore/QuartzCore.h"

@interface NIDropDown ()
@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) UIButton *btnSender;
@property(nonatomic, retain) NSArray *list;
@property(nonatomic, retain) NSArray *imageList;
@end

@implementation NIDropDown
@synthesize table;
@synthesize btnSender;
@synthesize list;
@synthesize imageList;
@synthesize delegate;
@synthesize animationDirection;
@synthesize isCountry;

- (id)showDropDown:(UIButton *)b :(CGFloat *)height :(NSArray *)arr :(NSArray *)imgArr :(NSString *)direction :(BOOL)isCount {
    isCountry = isCount;
    btnSender = b;
    animationDirection = direction;
    self.table = (UITableView *)[super init];
    if (self) {
        // Initialization code
        CGRect btn = b.frame;
        self.list = [NSArray arrayWithArray:arr];
        self.imageList = [NSArray arrayWithArray:imgArr];
        if ([direction isEqualToString:@"up"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, -5);
        }else if ([direction isEqualToString:@"down"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, 5);
        }
        
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 8;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        if(isCountry)
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, btn.size.width, 0)];
        else
            table = [[UITableView alloc] initWithFrame:CGRectMake(30, 0, 70, 0)];
        table.delegate = self;
        table.dataSource = self;
        table.layer.cornerRadius = 5;
        table.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:1];
        table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        table.separatorColor = [UIColor grayColor];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        CGRect bSuperviewFrame = [b.superview  frame];
        

        if ([direction isEqualToString:@"up"]) {
            
            float y = btn.origin.y+bSuperviewFrame.origin.y-5;
            float height1 = y -30;
            self.frame = CGRectMake(btn.origin.x, y-height1, btn.size.width, height1);
            table.frame = CGRectMake(0, 0, btn.size.width,height1);
            
            if(!isCountry)
            {
                self.frame = CGRectMake(30, y-height1, 70, height1);
                table.frame = CGRectMake(0, 0, 70,height1);

            }

        } else if([direction isEqualToString:@"down"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, *height);
        }
        [UIView commitAnimations];
        [[[UIApplication sharedApplication] keyWindow] addSubview:self];
        [self addSubview:table];
    }
    return self;
}

-(void)hideDropDown:(UIButton *)b {
    CGRect btn = b.frame;
    CGRect bSuperviewFrame = [b.superview  frame];
    float y = btn.origin.y+bSuperviewFrame.origin.y;

    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    if ([animationDirection isEqualToString:@"up"]) {
        self.frame = CGRectMake(btn.origin.x, y, btn.size.width, 0);
    }else if ([animationDirection isEqualToString:@"down"]) {
        self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
    }
    if(isCountry)
    table.frame = CGRectMake(0, 0, btn.size.width, 0);
    else
    table.frame = CGRectMake(30, 0, 70, 0);
    [UIView commitAnimations];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"SanFranciscoText-Light" size:13];
        cell.textLabel.textColor = [UIColor colorWithRed:13/255.0 green:130/255.0 blue:232/255.0 alpha:1.0];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }

    NSDictionary *dict = [list objectAtIndex:indexPath.row];
    if(isCountry)
    cell.textLabel.text =[NSString stringWithFormat:@"%@ (%@)",[dict objectForKey:@"name"],[dict objectForKey:@"code"]];
    else
        cell.textLabel.text =[dict objectForKey:@"dial_code"];

    
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self hideDropDown:btnSender];
    [self.delegate selectedIndex:(int) indexPath.row];
}

- (void) myDelegate {
    [self.delegate niDropDownDelegateMethod:self];
}

-(void)dealloc {
//    [super dealloc];
//    [table release];
//    [self release];
}

@end
