//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

// unicode

let uni1 = "\u{1F496}"

var cafe = "café"  //café
var cafe2 = "cafe\u{0301}"  //café
cafe.characters.count  //4
cafe2.characters.count  //4

"\\uD83D\\uDEAC香烟火机\\uD83D\\uDD25".unicodeScalars


