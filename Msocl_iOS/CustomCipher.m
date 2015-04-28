//
//  CustomCipher.m
//  KidsLink
//
//  Created by Dale McIntyre on 9/12/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "CustomCipher.h"

#define DEVISOR 26
#define LOWER_CASE_OFFSET 97
#define UPPER_CASE_OFFSET 65

@implementation CustomCipher

+(NSString *) encrypt:(NSString *)stringToEncrypt
{
	int size = (int)[stringToEncrypt length];
	unichar message[size];
	for (int i = 0; i < [stringToEncrypt length]; i++){
		char character = [stringToEncrypt characterAtIndex:i];
        message[i] = [self encryptChar : character];
	}
	NSString *codedMessage = [[NSString alloc] initWithCharacters:message length:size];
    return codedMessage;
}

+(unichar) encryptChar:(unichar) character {
    
    int cipherKey = 4; //hardcoding key
    
    unichar shiftedChar = character + cipherKey;
    
    //If character is lowercase a..z
    if ((character > 96)&&(character<123)){
        return ((shiftedChar-LOWER_CASE_OFFSET)%DEVISOR)+LOWER_CASE_OFFSET;
    }
    //Else if character is captital A..Z
    else if ((character > 64)&&(character<91)){
        return ((shiftedChar-UPPER_CASE_OFFSET)%DEVISOR)+UPPER_CASE_OFFSET;
    }
    //Else do not encrypt character
    else {
        return character;
    }
}

@end
