## Tutorial

### Simple Usage

If you want to just encode and decode messages you probably don't need more than this.

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

You can run the same process for decoding as the Enigma is symmetric.

**Important: You need to set the rotor position again**

```
set_rotor_positions!(enigma, 10,20,4)
decoded = decode!(enigma, encoded)
println("decoded: $decoded")
```

and surprise we get:

```
decoded: SECRE TMESS AGE
```

The messages are always uppercase and are into represented as blocks of five letters.