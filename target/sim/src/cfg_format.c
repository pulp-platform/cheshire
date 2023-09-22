// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// With a fuction copies from stackoverflow
// (https://stackoverflow.com/questions/8044081/how-to-do-regex-string-replacements-in-pure-c)
//
// Thomas Benz <tbenz@iis.ee.ethz.ch>


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <regex.h>

// replacement patterns
const char *NEWLINE_MATCH = ", ([A-Z])";
const char *NEWLINE_REPLACE = "\n \1";

const char *COLON_MATCH = ":";
const char *COLON_REPLACE = ": ";


int regex_replace(char **str, const char *pattern, const char *replace) {
    // https://stackoverflow.com/questions/8044081/how-to-do-regex-string-replacements-in-pure-c
    // replaces regex in pattern with replacement observing capture groups
    // *str MUST be free-able, i.e. obtained by strdup, malloc, ...
    // back references are indicated by char codes 1-31 and none of those chars can be used in the
    // replacement string such as a tab. will not search for matches within replaced text, this
    // will begin searching for the next match after the end of prev match
    // returns:
    //   -1 if pattern cannot be compiled
    //   -2 if count of back references and capture groups don't match
    //   otherwise returns number of matches that were found and replaced
    //
    regex_t reg;
    unsigned int replacements = 0;
    // if regex can't commpile pattern, do nothing
    if(!regcomp(&reg, pattern, REG_EXTENDED)) {
        size_t nmatch = reg.re_nsub;
        regmatch_t m[nmatch + 1];
        const char *rpl, *p;
        // count back references in replace
        int br = 0;
        p = replace;
        while(1) {
            while(*++p > 31);
            if(*p) br++;
            else break;
        } // if br is not equal to nmatch, leave
        if(br != nmatch) {
            regfree(&reg);
            return -2;
        }
        // look for matches and replace
        char *new;
        char *search_start = *str;
        while(!regexec(&reg, search_start, nmatch + 1, m, REG_NOTBOL)) {
            // make enough room
            new = (char *)malloc(strlen(*str) + strlen(replace));
            if(!new) exit(EXIT_FAILURE);
            *new = '\0';
            strncat(new, *str, search_start - *str);
            p = rpl = replace;
            int c;
            strncat(new, search_start, m[0].rm_so); // test before pattern
            for(int k=0; k<nmatch; k++) {
                while(*++p > 31); // skip printable char
                c = *p;  // back reference (e.g. \1, \2, ...)
                strncat(new, rpl, p - rpl); // add head of rpl
                // concat match
                strncat(new, search_start + m[c].rm_so, m[c].rm_eo - m[c].rm_so);
                rpl = p++; // skip back reference, next match
            }
            strcat(new, p ); // trailing of rpl
            unsigned int new_start_offset = strlen(new);
            strcat(new, search_start + m[0].rm_eo); // trailing text in *str
            free(*str);
            *str = (char *)malloc(strlen(new)+1);
            strcpy(*str,new);
            search_start = *str + new_start_offset;
            free(new);
            replacements++;
        }
        regfree(&reg);
        // ajust size
        *str = (char *)realloc(*str, strlen(*str) + 1);
        return replacements;
    } else {
        return -1;
    }
}


// pretty printer
extern void format_cfg(char *cfg_str, int length) {

    // cut curly brackets away
    char *cgf_str_cut = cfg_str + 2;
    cgf_str_cut[length-3] = "\0";

    // function works on a copy of the string
    char *tmp = (char *)malloc(length + 1 - 4);
    strcpy(tmp, cgf_str_cut);

    // infer newlines and fix colons
    regex_replace(&tmp, NEWLINE_MATCH, NEWLINE_REPLACE);
    regex_replace(&tmp, COLON_MATCH, COLON_REPLACE);

    // format numbers
    regex_t    find_num_pat;
    size_t     num_matches = 256;
    regmatch_t match_array[256];
    regcomp(&find_num_pat, "[0-9]+", REG_EXTENDED);
    regexec(&find_num_pat, tmp, num_matches, match_array, 0);

    // printf("%d", match_array[0].rm_eo);

    // print to questa terminal
    printf("\nCheshire Configuration\n----------------------\n\n %s\n", tmp);
}
