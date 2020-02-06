[![codecov](https://codecov.io/gh/Wikunia/Enigma.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Wikunia/Enigma.jl)

# Enigma

You'll be able to decode and encode messages like using the [Enigma Machine](https://en.wikipedia.org/wiki/Enigma_machine)
using this package.

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

Additionally you'll be able to crack Enigma codes if you have an encrypted message and some kind of hint like `Wetterbericht` is part of the first 100 characters of the message. 

Ongoing project ;) 

Simple usage:

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
encoded = encode(enigma, message)
println("encoded: $encoded")
```

This will generate: 

```
encoded: BVADAERAFRHET
```

and to decode that message you have to set the starting positions of the rotors again and decode the message. (Actually it's the same as encoding it.)

```
set_rotor_positions!(enigma, 10,20,4)
decoded = decode(enigma, encoded)
println("decoded: $decoded")
```

and surprise we get:

```
decoded: SECRETMESSAGE
```