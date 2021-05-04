var documenterSearchIndex = {"docs":
[{"location":"p5js.html#Visualization-and-Animation-using-p5js-1","page":"P5js visualization","title":"Visualization and Animation using p5js","text":"","category":"section"},{"location":"p5js.html#","page":"P5js visualization","title":"P5js visualization","text":"I used p5js in my videos explaining the Enigma and the Bombe. If you want to play around with it as well please follow these instructions.","category":"page"},{"location":"p5js.html#","page":"P5js visualization","title":"P5js visualization","text":"The html and js files are all in the p5js folder.  I have two main html files namely index.html for the Enigma Video and bombe.html for visualizing how to crack the Enigma.","category":"page"},{"location":"p5js.html#Enigma-1","page":"P5js visualization","title":"Enigma","text":"","category":"section"},{"location":"p5js.html#","page":"P5js visualization","title":"P5js visualization","text":"The main javascript file for the Enigma is sketch.js. You should probably be able to use this out of the box if you watched the video. Enigma: Endless possibilities is not enough","category":"page"},{"location":"p5js.html#","page":"P5js visualization","title":"P5js visualization","text":"Click right off the slider area for making a rotor step.\nThe slider decides the number of frames for each encoding step so left most setting is the fastest. \nYou can click on a letter (on the right side of the plugboard) to make an input","category":"page"},{"location":"p5js.html#","page":"P5js visualization","title":"P5js visualization","text":"The settings itself are part of sketch.js where you can set the settings of the Enigma. ","category":"page"},{"location":"p5js.html#Bombe-1","page":"P5js visualization","title":"Bombe","text":"","category":"section"},{"location":"p5js.html#","page":"P5js visualization","title":"P5js visualization","text":"The main javascript file for the Bombe is sketch_bombe.js. In the video you can't see all the keys I press to change the visualization:","category":"page"},{"location":"p5js.html#","page":"P5js visualization","title":"P5js visualization","text":"s move the guess to the right\na move the guess to the left\nr switch off the yellow lights (to start a new input)\n If you click on a letter on the plugboard (right hand side)\nit stops before it enters the plugboard in the reverse direction such that you can change the plugboard setting right before\nWith  you continue the encoding\nn move the orange indicator to the left (make a backward rotor step)\nm move the orange indicator to the right (make a rotor step)\np enter a plugboard setting. First press p and then two letters you want to connect\nz reset the whole Bombe","category":"page"},{"location":"explanation.html#Explanation-1","page":"Explanation","title":"Explanation","text":"","category":"section"},{"location":"explanation.html#","page":"Explanation","title":"Explanation","text":"You probably want to read my blog post about it: OpenSourc.ES Enigma and Bombe. Anyway this page gives you a brief overview:","category":"page"},{"location":"explanation.html#","page":"Explanation","title":"Explanation","text":"The Enigma is a mechanical machine used in WW II by the Germans\nIt is a symmetric cipher\nIt uses rotors and a plugboard\nthe rotors change the \"key\" each time a letter is typed\nthe plugboard swaps two letters\nThere are an enormous number of possibilities but it can be cracked\nThe main flaw is that a letter can't be encoded by itself","category":"page"},{"location":"explanation.html#","page":"Explanation","title":"Explanation","text":"This package allows you to encode/decode and crack messages.","category":"page"},{"location":"reference.html#EnigmaMachine-1","page":"Reference","title":"EnigmaMachine","text":"","category":"section"},{"location":"reference.html#","page":"Reference","title":"Reference","text":"EnigmaMachine()\nEnigmaMachine(r1::Int,r2::Int,r3::Int,ukw::Int)\nset_rotors!(enigma::EnigmaMachine, r1, r2, r3)\nset_ukw!(enigma::EnigmaMachine, ukw)\nset_rotor_positions!(enigma::EnigmaMachine, p1::Int, p2::Int, p3::Int)\nset_plugboard!(enigma::EnigmaMachine, setting::Vector{Tuple{Int,Int}})\nset_plugboard!(enigma::EnigmaMachine, setting::String)\nencode!(enigma::EnigmaMachine, s::String; input_validation=true, output_style=:enigma)\ndecode!(enigma::EnigmaMachine, s::String; input_validation=true, output_style=:enigma)\nenigma_styled_text(text::String)","category":"page"},{"location":"reference.html#Enigma.EnigmaMachine-Tuple{}","page":"Reference","title":"Enigma.EnigmaMachine","text":"EnigmaMachine()\n\nReturn a EnigmaMachine in the starting position: Rotors I,II,III, UKW A and rotor positions 1,1,1 (A,A,A)\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.EnigmaMachine-NTuple{4,Int64}","page":"Reference","title":"Enigma.EnigmaMachine","text":"EnigmaMachine(r1::Int, r2::Int, r3::Int, ukw::Int; p1=1, p2=1, p3=1)\n\nCreates an EnigmaMachine with the following setting:\n\nRotor ids from left to right: r1, r2, r3\n\nr1=1 would be setting the left most rotor to the rotor I\n\nThe reflector ( = ukw = Umkehrwalze) is 1,2,3 as well and correspond to the ukws A,B and C\n\nAdditionally the rotor positions can be set using p1,p2 and p3 for the three rotors\n\nReturn the created EnigmaMachine\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.set_rotors!-Tuple{EnigmaMachine,Any,Any,Any}","page":"Reference","title":"Enigma.set_rotors!","text":"set_rotors!(enigma::EnigmaMachine, r1, r2, r3)\n\nSet the rotors of enigma to r1, r2 and r3 from left to right.\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.set_ukw!-Tuple{EnigmaMachine,Any}","page":"Reference","title":"Enigma.set_ukw!","text":"set_ukw!(enigma::EnigmaMachine, ukw)\n\nSet the reflector (=Umkehrwalze = UKW) of the enigma. Currently ukw can be 1,2,3 for UKW A, UKW and UKW C\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.set_rotor_positions!-Tuple{EnigmaMachine,Int64,Int64,Int64}","page":"Reference","title":"Enigma.set_rotor_positions!","text":"set_rotor_positions!(enigma::EnigmaMachine, p1::Int, p2::Int, p3::Int)\n\nSet the rotor positions from left to right.\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.set_plugboard!-Tuple{EnigmaMachine,Array{Tuple{Int64,Int64},1}}","page":"Reference","title":"Enigma.set_plugboard!","text":"set_plugboard!(enigma::EnigmaMachine, setting::Vector{Tuple{Int,Int}})\n\nChange the plugboard of the enigma and set it to the new setting.\n\n[(1,2), (3,4)] would mean that there are two plugs one connecting A and B and one connecting C and D.\n\nSee also set_plugboard(enigma::EnigmaMachine, setting::String)\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.set_plugboard!-Tuple{EnigmaMachine,String}","page":"Reference","title":"Enigma.set_plugboard!","text":"set_plugboard!(enigma::EnigmaMachine, setting::String)\n\nChange the plugboard of the enigma and set it to the new setting.\n\nAB BC would mean that there are two plugs one connecting A and B and one connecting C and D.\n\nSee also set_plugboard(enigma::EnigmaMachine, setting::Vector{Tuple{Int,Int}})\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.encode!-Tuple{EnigmaMachine,String}","page":"Reference","title":"Enigma.encode!","text":"encode!(enigma::EnigmaMachine, s::String; input_validation=true, output_style=:enigma)\n\nIf all chars in the string are uppercase letters (so no spaces) then input_validation can be set to false for a bit speed up.\n\nThe default output consists of blocks of five letters. If you don't want the spaces you can set output_style=false.\n\nReturn the string encoded with the enigma. \n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.decode!-Tuple{EnigmaMachine,String}","page":"Reference","title":"Enigma.decode!","text":"decode!(enigma::EnigmaMachine, s::String; input_validation=true, output_style=:enigma)\n\nDoes the same as encode ;)\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.enigma_styled_text-Tuple{String}","page":"Reference","title":"Enigma.enigma_styled_text","text":"enigma_styled_text(text::String)\n\nReturn creates an enigma styled text which means it replaces all chars which are not letters and makes them uppercase. It also makes blocks of five letters for better or worse readability :D\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Bombe-1","page":"Reference","title":"Bombe","text":"","category":"section"},{"location":"reference.html#","page":"Reference","title":"Reference","text":"BombeMachine(secret::String, hint::String)\nenable_ambiguous!(bombe::BombeMachine)\ndisable_ambiguous!(bombe::BombeMachine)\nset_possible_rotors!(bombe::BombeMachine, rotor_1, rotor_2, rotor_3)\nset_possible_rotor_positions!(bombe::BombeMachine, rp1, rp2, rp3)\nset_possible_ukws!(bombe::BombeMachine, ukws)\nset_possible_hint_positions!(bombe::BombeMachine, hint_positions)\nset_hint!(bombe::BombeMachine, hint::String)\nset_secret!(bombe::BombeMachine, secret::String)\nrun_cracking(bombe::BombeMachine; log=true)","category":"page"},{"location":"reference.html#Enigma.BombeMachine-Tuple{String,String}","page":"Reference","title":"Enigma.BombeMachine","text":"BombeMachine(secret::String, hint::String)\n\nReturn a Bombe with a given secret and a hint.\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.enable_ambiguous!-Tuple{BombeMachine}","page":"Reference","title":"Enigma.enable_ambiguous!","text":"enable_ambiguous!(bombe::BombeMachine)\n\nBe sure that the actual message gets found. This takes often much longer and uses lots of RAM :/\n\nI would say most of the time it is not necessary. \n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.disable_ambiguous!-Tuple{BombeMachine}","page":"Reference","title":"Enigma.disable_ambiguous!","text":"disable_ambiguous!(bombe::BombeMachine)\n\nIf you enabled ambiguous by mistake and want to disable it again ;)\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.set_possible_rotors!-Tuple{BombeMachine,Any,Any,Any}","page":"Reference","title":"Enigma.set_possible_rotors!","text":"set_possible_rotors!(bombe::BombeMachine, rotor_1, rotor_2, rotor_3)\n\nSet the rotors that should be checked. Each rotor can be either an integer or a vector of integers (or range). \n\ni.e set_possible_rotors!(bombe::BombeMachine, 1, 2:3, [4,5])\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.set_possible_rotor_positions!-Tuple{BombeMachine,Any,Any,Any}","page":"Reference","title":"Enigma.set_possible_rotor_positions!","text":"set_possible_rotor_positions!(bombe::BombeMachine, rp1, rp2, rp3)\n\nSet the rotor positions that should be checked. Each rotor position can be either an integer or a vector of integers (or range). \n\ni.e set_possible_rotor_positions!(bombe::BombeMachine, 1, 1:26, [20,22,25])`\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.set_possible_ukws!-Tuple{BombeMachine,Any}","page":"Reference","title":"Enigma.set_possible_ukws!","text":"set_possible_ukws!(bombe::BombeMachine, ukws)\n\nSet the possible reflectors. ukws can be a single one or a vector.\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.set_possible_hint_positions!-Tuple{BombeMachine,Any}","page":"Reference","title":"Enigma.set_possible_hint_positions!","text":"set_possible_hint_positions!(bombe::BombeMachine, hint_positions)\n\nSet the positions in the secret the hint might appeared.\n\ni.e if you're sure it's the first word you can use set_possible_hint_positions!(bombe::BombeMachine, 1) or \n\nif you know that it is at least in the beginning you can use something like set_possible_hint_positions!(bombe::BombeMachine, 1:20).\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.set_hint!-Tuple{BombeMachine,String}","page":"Reference","title":"Enigma.set_hint!","text":"set_hint!(bombe::BombeMachine, hint::String)\n\nThis changes the hint used for cracking.\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.set_secret!-Tuple{BombeMachine,String}","page":"Reference","title":"Enigma.set_secret!","text":"set_secret!(bombe::BombeMachine, secret::String)\n\nThis changes the secret used for cracking.\n\n\n\n\n\n","category":"method"},{"location":"reference.html#Enigma.run_cracking-Tuple{BombeMachine}","page":"Reference","title":"Enigma.run_cracking","text":"run_cracking(bombe::BombeMachine; log=true)\n\nStart the cracking process.\n\nDoes not give you all possibilities if you haven't run enable_ambiguous! but this is normally not reasonable.\n\nReturn possible enigma settings to understand the secret message.\n\n\n\n\n\n","category":"method"},{"location":"index.html#Enigma.jl-1","page":"Home","title":"Enigma.jl","text":"","category":"section"},{"location":"index.html#","page":"Home","title":"Home","text":"With this package you're able to encode/decode Enigma messages. It currently supports","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"five different rotors of which three are used\nthree different reflectors\na plugboard","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"Not supported","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"Difference between ring setting and rotor position. Currently it's only rotor position","category":"page"},{"location":"index.html#Installation-1","page":"Home","title":"Installation","text":"","category":"section"},{"location":"index.html#","page":"Home","title":"Home","text":"It's currently not an official Julia package but I intend to make it one. Therefore you currently need to install it via the url.","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"] add https://github.com/Wikunia/Enigma.jl","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"Or if you want to hack a bit probably develop it","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"] dev https://github.com/Wikunia/Enigma.jl","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"Info: ] is used in the Julia REPL to get into package mode.","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"This documentation is done in several parts.","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"If you want to get a quick overview and just have a look at examples check out the tutorial.\nYou just have some How to questions? -> How to guide\nYou want to understand how it works deep down? Maybe improve it ;) -\nExplanation\nCheck out my blog post about it Enigma and Bombe\nHave a look at my video Enigma: Endless possibilities is not enough\nGimme the code documentation directly! The reference section got you covered.\nYou've seen the visualization I used in one of my videos?\nHow to use the visualization","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"If you have some questions please feel free to ask me by making an issue.","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"You might be interested in the process of how I coded this: Checkout the full process on my blog opensourc.es","category":"page"},{"location":"how_to.html#How-To-1","page":"How-To","title":"How To","text":"","category":"section"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"I assume you understood the simple usage case and have some further questions.","category":"page"},{"location":"how_to.html#How-to-use-different-rotors-i.e.-IV,-II-and-I-?-1","page":"How-To","title":"How to use different rotors i.e. IV, II and I ?","text":"","category":"section"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"Currently you need to use integers for this. The rotors are set from left to right.","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"set_rotors!(enigma, 4,2,1)","category":"page"},{"location":"how_to.html#How-to-set-a-different-rotor-position?-1","page":"How-To","title":"How to set a different rotor position?","text":"","category":"section"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"This needs to be done with integers as well. (Will fix this) Again from left to right.","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"set_rotor_positions!(enigma, 10,20,4)","category":"page"},{"location":"how_to.html#How-can-I-set-the-plugboard?-1","page":"How-To","title":"How can I set the plugboard?","text":"","category":"section"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"There are two different ways to set the plugs in the plugboard. Either using the letters.","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"set_plugboard!(enigma, \"AC BE GZ JK ML\")","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"Where two letters always form one plug. This is the more human readable way. Another option is to use tuples of integers for this.","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"set_plugboard!(enigma, [(1,2),(3,5)])","category":"page"},{"location":"how_to.html#How-can-I-crack-the-Enigma-code?-1","page":"How-To","title":"How can I crack the Enigma code?","text":"","category":"section"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"Currently this always needs a hint. That means you need to guess one word of the secret message. The longer the word the better and if you have additional information or guesses you can set them as well.","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"Okay let's start:","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"We assume you got that secret message you want to crack and think the word \"weatherreport\" is part of it.","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"crack_message = \"HGHXI AGYEY NDIFW PRMDD QSMJG DCAKP FMIZL RVQIZ WRLJM \"\nhint = \"weatherreport\"","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"The straight forward way is this:","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"bombe = BombeMachine(crack_message, hint)\nenigmas = run_cracking(bombe; log=false)","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"Unfortunately that takes a while (about 30 minutes) therefore you can give more hints.","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"# you know that rotor V is not used and the left most rotor is III\nset_possible_rotors!(bombe, 3,1:4,1:4)\n# Maybe you also know that the rotor position of III is something between 1 and 5.\nset_possible_rotor_positions!(bombe, 1:5,1:26,1:26)\n# The ukw is UKW A\nset_possible_ukws!(bombe, 1)\n# and the hint positions\nset_possible_hint_positions!(bombe, 1:5)\nenigmas = run_cracking(bombe; log=false);","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"To get the possible message you then need to run:","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"for enigma in enigmas\n    encoded = encode!(enigma, crack_message)\n    println(encoded)\nend","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"You should be aware here that encode changes the enigma setting (rotor position). Maybe you want to make a copy of the enigma first.","category":"page"},{"location":"how_to.html#Why-is-the-actual-message-not-among-those-cracked?-1","page":"How-To","title":"Why is the actual message not among those cracked?","text":"","category":"section"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"This is not a why question...","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"Anyway I'll answer it for you:","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"Unfortunately sometimes the hint is not enough to get the correct solution because some plugs can be removed from the real setting and still produce the hint. These extra plugs are hard to generate (well sometimes there are a lot) Of course this package gives you the possibility to test all those combinations which often takes much longer and you probably be able to guess the message without it. ","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"You really want to set this option? Okay here you go:","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"enable_ambiguous!(bombe)","category":"page"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"and then run enigmas = run_cracking(bombe; log=false); again.","category":"page"},{"location":"how_to.html#More-questions?-1","page":"How-To","title":"More questions?","text":"","category":"section"},{"location":"how_to.html#","page":"How-To","title":"How-To","text":"Please file an issue.","category":"page"},{"location":"tutorial.html#Tutorial-1","page":"Tutorial","title":"Tutorial","text":"","category":"section"},{"location":"tutorial.html#Simple-Usage-1","page":"Tutorial","title":"Simple Usage","text":"","category":"section"},{"location":"tutorial.html#","page":"Tutorial","title":"Tutorial","text":"If you want to just encode and decode messages you probably don't need more than this.","category":"page"},{"location":"tutorial.html#","page":"Tutorial","title":"Tutorial","text":"using Enigma\n\n# initialize the Enigma machine with standard settings\nenigma = EnigmaMachine()\n# set the rotors to I, II, III (left to right)\nset_rotors!(enigma, 1,2,3)\n# the start of the rotor positions\nset_rotor_positions!(enigma, 10,20,4)\n# set the reflector (ukw = Umkehrwalze = reflector) to UKW B\nset_ukw!(enigma, 2)\n# Connecting A and C, B and E, ... on the plugboard\nset_plugboard!(enigma, \"AC BE GZ JK ML\")\n\nmessage = \"Secret message\"\nencoded = encode!(enigma, message)\nprintln(\"encoded: $encoded\")","category":"page"},{"location":"tutorial.html#","page":"Tutorial","title":"Tutorial","text":"This will generate: ","category":"page"},{"location":"tutorial.html#","page":"Tutorial","title":"Tutorial","text":"encoded: KPXDG MWRWF SNN","category":"page"},{"location":"tutorial.html#","page":"Tutorial","title":"Tutorial","text":"You can run the same process for decoding as the Enigma is symmetric.","category":"page"},{"location":"tutorial.html#","page":"Tutorial","title":"Tutorial","text":"Important: You need to set the rotor position again","category":"page"},{"location":"tutorial.html#","page":"Tutorial","title":"Tutorial","text":"set_rotor_positions!(enigma, 10,20,4)\ndecoded = decode!(enigma, encoded)\nprintln(\"decoded: $decoded\")","category":"page"},{"location":"tutorial.html#","page":"Tutorial","title":"Tutorial","text":"and surprise we get:","category":"page"},{"location":"tutorial.html#","page":"Tutorial","title":"Tutorial","text":"decoded: SECRE TMESS AGE","category":"page"},{"location":"tutorial.html#","page":"Tutorial","title":"Tutorial","text":"The messages are always uppercase and are into represented as blocks of five letters.","category":"page"}]
}