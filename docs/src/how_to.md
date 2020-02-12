## How To

I assume you understood the simple usage case and have some further questions.

### How to use different rotors i.e. IV, II and I ?
Currently you need to use integers for this. The rotors are set from left to right.

```
set_rotors!(enigma, 4,2,1)
```

### How to set a different rotor position?
This needs to be done with integers as well. (Will fix this)
Again from left to right.

```
set_rotor_positions!(enigma, 10,20,4)
```

### How can I set the plugboard?

There are two different ways to set the plugs in the plugboard. Either using the letters.

```
set_plugboard!(enigma, "AC BE GZ JK ML")
```

Where two letters always form one plug. This is the more human readable way. Another option is to use tuples
of integers for this.

```
set_plugboard!(enigma, [(1,2),(3,5)])
```

### How can I crack the Enigma code?

Currently this always needs a hint. That means you need to guess one word of the secret message.
The longer the word the better and if you have additional information or guesses you can set them as well.

Okay let's start:

We assume you got that secret message you want to crack and think the word "weatherreport" is part of it.
```
crack_message = "HGHXI AGYEY NDIFW PRMDD QSMJG DCAKP FMIZL RVQIZ WRLJM "
hint = "weatherreport"
```

The straight forward way is this:
```
bombe = BombeMachine(crack_message, hint)
enigmas = run_cracking(bombe; log=false)
```

Unfortunately that takes a while (about 30 minutes) therefore you can give more hints.

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

To get the possible message you then need to run:

```
for enigma in enigmas
    encoded = encode!(enigma, crack_message)
    println(encoded)
end
```

You should be aware here that `encode` changes the enigma setting (rotor position).
Maybe you want to make a copy of the enigma first.

### Why is the actual message not among those cracked?

This is not a why question...

Anyway I'll answer it for you:

Unfortunately sometimes the hint is not enough to get the correct solution because some plugs can be removed from the real setting and still produce the hint. These extra plugs are hard to generate (well sometimes there are a lot)
Of course this package gives you the possibility to test all those combinations which often takes much longer and you probably be able to guess the message without it. 

You really want to set this option? Okay here you go:

```
enable_ambiguous!(bombe)
```

and then run `enigmas = run_cracking(bombe; log=false);` again.

### More questions?
Please file an [issue](https://github.com/Wikunia/Enigma.jl/issues).