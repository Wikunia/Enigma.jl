## EnigmaMachine

```@docs
EnigmaMachine()
EnigmaMachine(r1::Int,r2::Int,r3::Int,ukw::Int)
set_rotors!(enigma::EnigmaMachine, r1, r2, r3)
set_ukw!(enigma::EnigmaMachine, ukw)
set_rotor_positions!(enigma::EnigmaMachine, p1::Int, p2::Int, p3::Int)
set_plugboard!(enigma::EnigmaMachine, setting::Vector{Tuple{Int,Int}})
set_plugboard!(enigma::EnigmaMachine, setting::String)
encode!(enigma::EnigmaMachine, s::String; input_validation=true, output_style=:enigma)
decode!(enigma::EnigmaMachine, s::String; input_validation=true, output_style=:enigma)
enigma_styled_text(text::String)
```

## Bombe
```@docs
BombeMachine(secret::String, hint::String)
enable_ambiguous!(bombe::BombeMachine)
disable_ambiguous!(bombe::BombeMachine)
set_possible_rotors!(bombe::BombeMachine, rotor_1, rotor_2, rotor_3)
set_possible_rotor_positions!(bombe::BombeMachine, rp1, rp2, rp3)
set_possible_ukws!(bombe::BombeMachine, ukws)
set_possible_hint_positions!(bombe::BombeMachine, hint_positions)
set_hint!(bombe::BombeMachine, hint::String)
set_secret!(bombe::BombeMachine, secret::String)
run_cracking(bombe::BombeMachine; log=true)
```