//
//  ProhibitedWords.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/16/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

class ProhibitedPhrases {
    private static var _ProhibitedPhrases: [String] = []
    
    internal class func defaultProhibitedPhrases() -> [String] {
        let defaultProhibitedPhrases = [
            "2g1c",
            "2 girls 1 cup",
            "acrotomophilia",
            "alabama hot pocket",
            "alaskan pipeline",
            "anal",
            "anilingus",
            "anus",
            "apeshit",
            "arsehole",
            "ass",
            "asshole",
            "assmunch",
            "auto erotic",
            "autoerotic",
            "babeland",
            "baby batter",
            "baby juice",
            "ball gag",
            "ball gravy",
            "ball kicking",
            "ball licking",
            "ball sack",
            "ball sucking",
            "bangbros",
            "bareback",
            "barely legal",
            "barenaked",
            "bastard",
            "bastardo",
            "bastinado",
            "bbw",
            "bdsm",
            "beaner",
            "beaners",
            "beaver cleaver",
            "beaver lips",
            "bestiality",
            "big black",
            "big breasts",
            "big knockers",
            "big tits",
            "bimbos",
            "birdlock",
            "bitch",
            "bitches",
            "black cock",
            "blonde action",
            "blonde on blonde action",
            "blowjob",
            "blow job",
            "blow your load",
            "blue waffle",
            "blumpkin",
            "bollocks",
            "bondage",
            "boner",
            "boob",
            "boobs",
            "booty call",
            "brown showers",
            "brunette action",
            "bukkake",
            "bulldyke",
            "bullet vibe",
            "bullshit",
            "bung hole",
            "bunghole",
            "busty",
            "butt",
            "buttcheeks",
            "butthole",
            "camel toe",
            "camgirl",
            "camslut",
            "camwhore",
            "carpet muncher",
            "carpetmuncher",
            "chocolate rosebuds",
            "circlejerk",
            "cleveland steamer",
            "clit",
            "clitoris",
            "clover clamps",
            "clusterfuck",
            "cock",
            "cocks",
            "coprolagnia",
            "coprophilia",
            "cornhole",
            "coon",
            "coons",
            "creampie",
            "cum",
            "cumming",
            "cunnilingus",
            "cunt",
            "darkie",
            "date rape",
            "daterape",
            "deep throat",
            "deepthroat",
            "dendrophilia",
            "dick",
            "dildo",
            "dingleberry",
            "dingleberries",
            "dirty pillows",
            "dirty sanchez",
            "doggie style",
            "doggiestyle",
            "doggy style",
            "doggystyle",
            "dog style",
            "dolcett",
            "domination",
            "dominatrix",
            "dommes",
            "donkey punch",
            "double dong",
            "double penetration",
            "dp action",
            "dry hump",
            "dvda",
            "eat my ass",
            "ecchi",
            "ejaculation",
            "erotic",
            "erotism",
            "escort",
            "ethical slut",
            "eunuch",
            "faggot",
            "fecal",
            "felch",
            "fellatio",
            "feltch",
            "female squirting",
            "femdom",
            "figging",
            "fingerbang",
            "fingering",
            "fisting",
            "foot fetish",
            "footjob",
            "frotting",
            "fuck",
            "fuck buttons",
            "fuckin",
            "fucking",
            "fucktards",
            "fudge packer",
            "fudgepacker",
            "futanari",
            "gang bang",
            "gay sex",
            "genitals",
            "giant cock",
            "girl on",
            "girl on top",
            "girls gone wild",
            "goatcx",
            "goatse",
            "god damn",
            "gokkun",
            "golden shower",
            "goodpoop",
            "goo girl",
            "goregasm",
            "grope",
            "group sex",
            "g-spot",
            "guro",
            "hand job",
            "handjob",
            "hard core",
            "hardcore",
            "hentai",
            "homoerotic",
            "honkey",
            "hooker",
            "hot carl",
            "hot chick",
            "how to kill",
            "how to murder",
            "huge fat",
            "humping",
            "incest",
            "intercourse",
            "jack off",
            "jail bait",
            "jailbait",
            "jelly donut",
            "jerk off",
            "jigaboo",
            "jiggaboo",
            "jiggerboo",
            "jizz",
            "juggs",
            "kike",
            "kinbaku",
            "kinkster",
            "kinky",
            "knobbing",
            "leather restraint",
            "leather straight jacket",
            "lemon party",
            "lolita",
            "lovemaking",
            "make me come",
            "male squirting",
            "masturbate",
            "menage a trois",
            "milf",
            "missionary position",
            "motherfucker",
            "mound of venus",
            "mr hands",
            "muff diver",
            "muffdiving",
            "nambla",
            "nawashi",
            "negro",
            "neonazi",
            "nigga",
            "nigger",
            "nig nog",
            "nimphomania",
            "nipple",
            "nipples",
            "nsfw images",
            "nude",
            "nudity",
            "nympho",
            "nymphomania",
            "octopussy",
            "omorashi",
            "one cup two girls",
            "one guy one jar",
            "orgasm",
            "orgy",
            "paedophile",
            "paki",
            "panties",
            "panty",
            "pedobear",
            "pedophile",
            "pegging",
            "penis",
            "phone sex",
            "piece of shit",
            "pissing",
            "piss pig",
            "pisspig",
            "playboy",
            "pleasure chest",
            "pole smoker",
            "ponyplay",
            "poof",
            "poon",
            "poontang",
            "punany",
            "poop chute",
            "poopchute",
            "porn",
            "porno",
            "pornography",
            "prince albert piercing",
            "pthc",
            "pubes",
            "pussy",
            "queaf",
            "queef",
            "quim",
            "raghead",
            "raging boner",
            "rape",
            "raping",
            "rapist",
            "rectum",
            "reverse cowgirl",
            "rimjob",
            "rimming",
            "rosy palm",
            "rosy palm and her 5 sisters",
            "rusty trombone",
            "sadism",
            "santorum",
            "scat",
            "schlong",
            "scissoring",
            "semen",
            "sex",
            "sexo",
            "sexy",
            "shaved beaver",
            "shaved pussy",
            "shemale",
            "shibari",
            "shit",
            "shitty",
            "shota",
            "shrimping",
            "skeet",
            "slanteye",
            "slut",
            "s&m",
            "smut",
            "snatch",
            "snowballing",
            "sodomize",
            "sodomy",
            "spic",
            "splooge",
            "splooge moose",
            "spooge",
            "spread legs",
            "spunk",
            "strap on",
            "strapon",
            "strappado",
            "strip club",
            "style doggy",
            "suck",
            "sucks",
            "suicide girls",
            "sultry women",
            "swastika",
            "swinger",
            "tainted love",
            "taste my",
            "tea bagging",
            "threesome",
            "throating",
            "tied up",
            "tight white",
            "tit",
            "tits",
            "titties",
            "titty",
            "tongue in a",
            "topless",
            "tosser",
            "towelhead",
            "tranny",
            "tribadism",
            "tub girl",
            "tubgirl",
            "tushy",
            "twat",
            "twink",
            "twinkie",
            "two girls one cup",
            "undressing",
            "upskirt",
            "urethra play",
            "urophilia",
            "vagina",
            "venus mound",
            "vibrator",
            "violet wand",
            "vorarephilia",
            "voyeur",
            "vulva",
            "wank",
            "wetback",
            "wet dream",
            "white power",
            "wrapping men",
            "wrinkled starfish",
            "xx",
            "xxx",
            "yaoi",
            "yellow showers",
            "yiffy",
            "zoophilia"
        ]
        
        return defaultProhibitedPhrases
    }
    
    class func setProhibitedPhrases(prohibitedPhrases: [String]) -> Void {
        _ProhibitedPhrases = prohibitedPhrases
    }
    
    class func prohibitedPhrasesInString(string: String) -> [String] {
        var lowercaseString = string.lowercaseString
        
        let newLineString = "\n"
        
        while lowercaseString.containsString(newLineString) {
            lowercaseString = lowercaseString.stringByReplacingOccurrencesOfString(
                newLineString
            ,   withString: " "
            )
        }
        
        let doubleWhitespaceString = "  "
        
        while lowercaseString.containsString(doubleWhitespaceString) {
            lowercaseString = lowercaseString.stringByReplacingOccurrencesOfString(
                doubleWhitespaceString
            ,   withString: " "
            )
        }
        
        if lowercaseString.characters.count > 0 {
            let firstCharacterIndex = lowercaseString.startIndex
            let firstCharacter = lowercaseString[firstCharacterIndex]
            
            if firstCharacter == " " {
                if lowercaseString.characters.count > 1 {
                    let newStartIndex = lowercaseString.startIndex.advancedBy(1)
                    let newEndIndex = lowercaseString.endIndex.predecessor()
                    
                    lowercaseString = lowercaseString[newStartIndex...newEndIndex]
                } else {
                    lowercaseString = ""
                }
            }
        }
        
        if lowercaseString.characters.count > 0 {
            let lastCharacterIndex = lowercaseString.endIndex.predecessor()
            let lastCharacter = lowercaseString[lastCharacterIndex]
            
            if lastCharacter == " " {
                if lowercaseString.characters.count > 1 {
                    let newStartIndex = lowercaseString.startIndex
                    let newEndIndex = lowercaseString.endIndex.predecessor().predecessor()
                    
                    lowercaseString = lowercaseString[newStartIndex...newEndIndex]
                } else {
                    lowercaseString = ""
                }
            }
        }
        
        var prohibitedPhrasesInString: [String] = []
        
        let multipleWordsProhibitedPhrases = _ProhibitedPhrases.filter {
            (prohibitedPhrase: String) -> Bool in
            return prohibitedPhrase.containsString(" ")
        }
        
        for prohibitedPhrase in multipleWordsProhibitedPhrases {
            if let _ = lowercaseString.rangeOfString(prohibitedPhrase) {
                prohibitedPhrasesInString.append(prohibitedPhrase)
            }
        }
        
        let singleWordProhibitedPhrases = _ProhibitedPhrases.filter {
            (prohibitedPhrase: String) -> Bool in
            return !prohibitedPhrase.containsString(" ")
        }
        
        let stringWords = lowercaseString.componentsSeparatedByString(" ")
        
        for stringWord in stringWords {
            for prohibitedPhrase in singleWordProhibitedPhrases {
                if stringWord == prohibitedPhrase {
                    prohibitedPhrasesInString.append(prohibitedPhrase)
                }
            }
        }
        
        var uniqueProhibitedPhrasesInString: [String] = []
        
        for prohibitedPhrase in prohibitedPhrasesInString {
            if !uniqueProhibitedPhrasesInString.contains(prohibitedPhrase) {
                uniqueProhibitedPhrasesInString.append(prohibitedPhrase)
            }
        }
        
        return uniqueProhibitedPhrasesInString
    }
}
