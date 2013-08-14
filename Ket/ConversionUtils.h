// Returns the kanji character that represents a weekday for a given integer
//
// 1 for Sunday, 2 for Monday and so on.
NSString *WeekdayKanjiFromInteger(NSInteger integer);

// Returns "Cxxx" where xxx is a given Comiket number, left-padded with "0"
//
// Comiket ID is the canonical representation of Comiket number. Prefer it to
// Comiket name for file name etc.
NSString *ComiketIDFromComiketNo(NSUInteger comiketNo);

// Returns "Cxx" where xx is a given Comiket number, two- or three-digit
//
// Comiket name is a conventional representation of Comiket number. Prefer it to
// Comiket ID for UI use.
NSString *ComiketNameFromComiketNo(NSUInteger comiketNo);

// Returns a Comiket number by parsing a given Comiket name or Comiket ID
//
// This function scans for a decimal integer representation skipping alphabets
// and ideographs.
NSUInteger ComiketNoFromString(NSString *comiketNameOrID);