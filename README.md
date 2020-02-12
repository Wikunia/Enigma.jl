[![codecov](https://codecov.io/gh/Wikunia/Enigma.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Wikunia/Enigma.jl)

# Enigma

You'll be able to decode and encode messages like using the [Enigma Machine](https://en.wikipedia.org/wiki/Enigma_machine)
with this package.
Even more awesome you can try cracking the code by given hints ;)

Currently there are five different rotors:

```
        A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
I       E K M F L G D Q V Z N T O W Y H X U S P A I B R C J
II      A J D K S I R U X B L H W T M C Q G Z N P Y F V O E
III     B D F H J L C P R T X V Z N Y E I W G A K M U S Q O
IV      E S O V P Z J A Y Q U I R H X L N F T G K D C M W B
V       V Z B R G I T Y U P S D N H L X A W M J Q O F E C K
```

and three different reflectors:

```
        A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
UKW A   E J M Z A L Y X V B W F C R Q U O N T S P I K H G D
UKW B   Y R U H Q S L D P X N G O K M I E B F Z C W V J A T
UKW C   F V P J I A O Y E D R Z X W G C T K U Q S B N M H L
```

Additionally you're be able to crack Enigma codes if you have an encrypted message and some kind of hint like `Wetterbericht` is part of the first 100 characters of the message. 

## Installation
You can install this julia package using 
`] add https://github.com/Wikunia/Enigma.jl` or if you want to change code you might want to use
`] dev https://github.com/Wikunia/Enigma.jl`.

If everything goes well I will make a request to make this a julia package but that needs a little bit more work.

## Simple usage 

```
using Enigma

# initialize the Enigma machine with standard settings
enigma = EnigmaMachine()
# set the rotors to I, II, III (left to right)
set_rotors!(enigma, 1,2,3)
# the start of the rotor positions
set_rotor_positions!(enigma, 10,20,4)
# set the reflector (ukw = Umkehrwalze = reflector) to UKW B
set_ukw!(enigma, 2)
# Connecting A and C, B and E, ... on the plugboard
set_plugboard!(enigma, "AC BE GZ JK ML")

message = "Secret message"
encoded = encode!(enigma, message)
println("encoded: $encoded")
```

This will generate: 

```
encoded: KPXDG MWRWF SNN
```

and to decode that message you have to set the starting positions of the rotors again and decode the message. (Actually it's the same as encoding it.)

```
set_rotor_positions!(enigma, 10,20,4)
decoded = decode!(enigma, encoded)
println("decoded: $decoded")
```

and surprise we get:

```
decoded: SECRE TMESS AGE
```

## Cracking using the Bombe

The Enigma code was famously cracked by Alan Turing and Co. in Bletchley Park.

This package also support to crack codes. 

```
crack_message = "HGHXI AGYEY NDIFW PRMDD QSMJG DCAKP FMIZL RVQIZ WRLJM "
hint = "weatherreport"
```

You got that weird message and you think that the word `weatherreport` starts at the first 5 chars to support something like 
`A weatherreport` or `The weatherreport` and stuff like that.

First you define the `BombeMachine` by given the secret text and the `hint`.
Then you can crack the code and it will check `weatherreport` on all positions and all possible plug setting, rotors, rotor positions and the three ukws.

```
bombe = BombeMachine(crack_message, hint)
enigmas = run_cracking(bombe; log=false)
```
That might take a while. Therefore you can give more hints.

```
# you know that rotor V is not used and the left most rotor is III
set_possible_rotors!(bombe, 3,1:4,1:4)
# Maybe you also know that the rotor position of III is something between 1 and 5.
set_possible_rotor_positions!(bombe, 1:5,1:26,1:26)
# The ukw is UKW A
set_possible_ukws!(bombe, 1)
# and the hint positions
set_possible_hint_positions!(bombe, 1:5)
enigmas = run_cracking(bombe; log=false);
```

This gets cracked in a few seconds now. The result is a set of enigma machines. 

Then you can run:

```
for enigma in enigmas
    encoded = encode!(enigma, crack_message)
    println(encoded)
end
```

One of the 11 found solutions is the message. 

Unfortunately sometimes the hint is not enough to get the correct solution because some plugs can be removed from the real setting and still produce the hint. These extra plugs are hard to generate (well sometimes there are a lot)
Of course this package gives you the possibility to test all those combinations which often takes much longer and you probably be able to guess the message without it. 

You really want to set this option? Okay here you go:

```
enable_ambiguous!(bombe)
```

and then run `enigmas = run_cracking(bombe; log=false);` again.