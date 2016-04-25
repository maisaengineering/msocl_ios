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
    
    unichar shiftedChar = character - cipherKey;
    
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
+(NSString *) decrypt:(NSString *)stringToDecrypt
{
    int size = (int)[stringToDecrypt length];
    unichar message[size];
    for (int i = 0; i < [stringToDecrypt length]; i++){
        char character = [stringToDecrypt characterAtIndex:i];
        message[i] = [self decryptChar : character];
    }
    NSString *codedMessage = [[NSString alloc] initWithCharacters:message length:size];
    return codedMessage;

}
+(unichar) decryptChar:(unichar) character {
    
    
    
    //If character is lowercase a..z
    if ((character > 96)&&(character<123)){
        if(character <= 100)
        {
            character = character+ 22;
        }
        else
        {
            character = character - 4;
        }
        return character;
    }
    //Else if character is captital A..Z
    else if ((character > 64)&&(character<91)){
        if(character <= 68)
        {
            character = character+ 22;
        }
        else
        {
             character = character - 4;
        }

        return character;
    }
    //Else do not encrypt character
    else {
        return character;
    }
}

@end
