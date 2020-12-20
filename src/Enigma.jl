module Enigma

mutable struct Rotor
    name            :: String
    order           :: Int # indicates whether it's the 1st, 2nd, 3rd rotor
    mapping         :: Vector{Int}
    mapping_bw      :: Vector{Int}
    position        :: Int
    rotation_point  :: Int
end

mutable struct UKW
    name            :: String
    mapping         :: Vector{Int}
end

mutable struct EnigmaMachine
    plugboard       :: Vector{Int}
    rotors          :: Tuple{Rotor,Rotor,Rotor}
    ukw             :: UKW
end

function Base.show(io::IO, EMs::Vector{EnigmaMachine})
    Base.show(io, MIME"text/plain"(), EMs)
end

function Base.show(io::IO, EM::EnigmaMachine)
    Base.show(io, MIME"text/plain"(), EM)
    println("")
end

function Base.show(io::IO, mime::MIME"text/plain", EMs::Vector{EnigmaMachine})
    println(io, "$(length(EMs)) Enigma machine(s): ")
    for EM in EMs
        print(io, "- ")
        show(io, mime, EM)
        println("")
    end
end

function Base.show(io::IO, ::MIME"text/plain", EM::EnigmaMachine)
    rotors = "$(EM.rotors[1].name), $(EM.rotors[2].name), $(EM.rotors[3].name)"
    positions = "$(EM.rotors[1].position) $(EM.rotors[2].position) $(EM.rotors[3].position)"
    ukw = "$(EM.ukw.name)"
    plugboard_str = ""
    az = collect('A':'Z')
    for i in 1:26
        if EM.plugboard[i] > i
            plugboard_str *= "$(az[i])$(az[EM.plugboard[i]]) "
        end
    end
    print(io, "$rotors | $positions | UKW: $ukw | $plugboard_str")
end

include("Bombe.jl")
include("EnigmaVis.jl")

"""
    EnigmaMachine()

Return a EnigmaMachine in the starting position: Rotors I,II,III, UKW A and rotor positions 1,1,1 (A,A,A)
"""
function EnigmaMachine()
    return EnigmaMachine(1,2,3,1)
end

const possible_ukw = [
    Dict(:name => "A", :mapping => [05, 10, 13, 26, 01, 12, 25, 24, 22, 02, 23, 06, 03, 18, 17, 21, 15, 14, 20, 19, 16, 09, 11, 08, 07, 04]),
    Dict(:name => "B", :mapping => [25, 18, 21, 08, 17, 19, 12, 04, 16, 24, 14, 07, 15, 11, 13, 09, 05, 02, 06, 26, 03, 23, 22, 10, 01, 20]),
    Dict(:name => "C", :mapping => [06, 22, 16, 10, 09, 01, 15, 25, 05, 04, 18, 26, 24, 23, 07, 03, 20, 11, 21, 17, 19, 02, 14, 13, 08, 12])
]

const possible_rotors = [
    Dict(:name => "I",
         :mapping => [05, 11, 13, 06, 12, 07, 04, 17, 22, 26, 14, 20, 15, 23, 25, 08, 24, 21, 19, 16, 01, 09, 02, 18, 03, 10],
         :rotation_point => 18),
    Dict(:name => "II",
         :mapping => [01, 10, 04, 11, 19, 09, 18, 21, 24, 02, 12, 08, 23, 20, 13, 03, 17, 07, 26, 14, 16, 25, 06, 22, 15, 05],
         :rotation_point => 6),
    Dict(:name => "III",
         :mapping => [02, 04, 06, 08, 10, 12, 03, 16, 18, 20, 24, 22, 26, 14, 25, 05, 09, 23, 07, 01, 11, 13, 21, 19, 17, 15],
         :rotation_point => 23),
    Dict(:name => "IV",
         :mapping => [05, 19, 15, 22, 16, 26, 10, 01, 25, 17, 21, 09, 18, 08, 24, 12, 14, 06, 20, 07, 11, 04, 03, 13, 23, 02],
         :rotation_point => 11),
    Dict(:name => "V",
         :mapping => [22, 26, 02, 18, 07, 09, 20, 25, 21, 16, 19, 04, 14, 08, 12, 24, 01, 23, 13, 10, 17, 15, 06, 05, 03, 11],
         :rotation_point => 1)
]

function get_backward_mapping(order::Vector{Int})
    backward_mp = zeros(Int, 26)
    for i in 1:26
        backward_mp[order[i]] = i
    end
    return backward_mp
end

function Rotor(name::String, order::Int, mapping::Vector{Int}, position::Int, rotation_point::Int)
    return Rotor(name, order, mapping, get_backward_mapping(mapping), position, rotation_point)
end

"""
    EnigmaMachine(r1::Int, r2::Int, r3::Int, ukw::Int; p1=1, p2=1, p3=1)

Creates an EnigmaMachine with the following setting:\n
Rotor ids from left to right: r1, r2, r3\n
r1=1 would be setting the left most rotor to the rotor I\n
The reflector ( = ukw = Umkehrwalze) is 1,2,3 as well and correspond to the ukws A,B and C\n
Additionally the rotor positions can be set using p1,p2 and p3 for the three rotors\n
Return the created EnigmaMachine
"""
function EnigmaMachine(r1::Int, r2::Int, r3::Int, ukw::Int; p1=1, p2=1, p3=1)
    rotor_1 = Rotor(possible_rotors[r1][:name], 1, possible_rotors[r1][:mapping], p1, possible_rotors[r1][:rotation_point])
    rotor_2 = Rotor(possible_rotors[r2][:name], 2, possible_rotors[r2][:mapping], p2, possible_rotors[r2][:rotation_point])
    rotor_3 = Rotor(possible_rotors[r3][:name], 3, possible_rotors[r3][:mapping], p3, possible_rotors[r3][:rotation_point])

    return EnigmaMachine(collect(1:26), (rotor_1,rotor_2,rotor_3), UKW(possible_ukw[ukw][:name], possible_ukw[ukw][:mapping]))
end

"""
    set_rotors!(enigma::EnigmaMachine, r1, r2, r3)

Set the rotors of enigma to r1, r2 and r3 from left to right.
"""
function set_rotors!(enigma::EnigmaMachine, r1, r2, r3)
    rotor_1 = Rotor(possible_rotors[r1][:name], 1, possible_rotors[r1][:mapping], enigma.rotors[1].position, possible_rotors[r1][:rotation_point])
    rotor_2 = Rotor(possible_rotors[r2][:name], 2, possible_rotors[r2][:mapping], enigma.rotors[2].position, possible_rotors[r2][:rotation_point])
    rotor_3 = Rotor(possible_rotors[r3][:name], 3, possible_rotors[r3][:mapping], enigma.rotors[3].position, possible_rotors[r3][:rotation_point])

    enigma.rotors = (rotor_1, rotor_2, rotor_3)
end

"""
    set_ukw!(enigma::EnigmaMachine, ukw)

Set the reflector (=Umkehrwalze = UKW) of the enigma. Currently ukw can be 1,2,3 for UKW A, UKW and UKW C
"""
function set_ukw!(enigma::EnigmaMachine, ukw)
    enigma.ukw = UKW(possible_ukw[ukw][:name], possible_ukw[ukw][:mapping])
end

"""
    set_rotor_positions!(enigma::EnigmaMachine, p1::Int, p2::Int, p3::Int)

Set the rotor positions from left to right.
"""
function set_rotor_positions!(enigma::EnigmaMachine, p1::Int, p2::Int, p3::Int)
    enigma.rotors[1].position = p1
    enigma.rotors[2].position = p2
    enigma.rotors[3].position = p3
end

"""
    set_plugboard!(enigma::EnigmaMachine, setting::Vector{Tuple{Int,Int}})

Change the plugboard of the enigma and set it to the new setting.\n
`[(1,2), (3,4)]` would mean that there are two plugs one connecting A and B and one connecting C and D.\n
See also `set_plugboard(enigma::EnigmaMachine, setting::String)`
"""
function set_plugboard!(enigma::EnigmaMachine, setting::Vector{Tuple{Int,Int}})
    for i=1:26
        enigma.plugboard[i] = i
    end
    for plug in setting
        enigma.plugboard[plug[1]] = plug[2]
        enigma.plugboard[plug[2]] = plug[1]
    end
end

"""
    set_plugboard!(enigma::EnigmaMachine, setting::String)

Change the plugboard of the enigma and set it to the new setting.\n
`AB BC` would mean that there are two plugs one connecting A and B and one connecting C and D.\n
See also `set_plugboard(enigma::EnigmaMachine, setting::Vector{Tuple{Int,Int}})`
"""
function set_plugboard!(enigma::EnigmaMachine, setting::String)
    for i=1:26
        enigma.plugboard[i] = i
    end
    setting == "" && return
    parts = split(setting, " ")
    for part in parts
        from_letter, to_letter = part[1], part[2]
        from = Int(uppercase(from_letter))-64
        to = Int(uppercase(to_letter))-64
        if enigma.plugboard[from] != from
            error("$from_letter already connected to: ", Char(enigma.plugboard[from]+64))
        end
        if enigma.plugboard[to] != to
            error("$to_letter already connected to: ", Char(enigma.plugboard[to]+64))
        end
        enigma.plugboard[from] = to
        enigma.plugboard[to] = from
    end
end

function step_rotors!(enigma::EnigmaMachine)
    # right most rotor
    enigma.rotors[3].position += 1
    enigma.rotors[3].position == 27 && (enigma.rotors[3].position = 1)
    if enigma.rotors[3].position == enigma.rotors[3].rotation_point
        enigma.rotors[2].position += 1
        enigma.rotors[2].position == 27 && (enigma.rotors[2].position = 1)
        if enigma.rotors[2].position == enigma.rotors[2].rotation_point
            enigma.rotors[1].position += 1
            enigma.rotors[1].position == 27 && (enigma.rotors[1].position = 1)
        end
    elseif enigma.rotors[2].position+1 == enigma.rotors[2].rotation_point
        enigma.rotors[2].position += 1
        enigma.rotors[2].position == 27 && (enigma.rotors[2].position = 1)
        enigma.rotors[1].position += 1
        enigma.rotors[1].position == 27 && (enigma.rotors[1].position = 1)
    end
end

function index_connected_to(rotor, index; backward=false)
    # index and rotor position are 1 index based
    # turning the rotor back to get the actual index
    index = (index-1+rotor.position-1) % 26+1
    if !backward
        through_rotor = rotor.mapping[index]
    else
        through_rotor = rotor.mapping_bw[index]
    end
    # turning the rotor again to translate the index into the next rotor
    result = through_rotor-rotor.position+1
    result = (result-1 + 26) % 26 + 1
    return result
end

function encode_single_idx_to_idx(enigma::EnigmaMachine, number::Int)
    number = enigma.plugboard[number]
    step_rotors!(enigma)
    for i=3:-1:1
        r = enigma.rotors[i]
        number = index_connected_to(r, number)
    end
    number = enigma.ukw.mapping[number]
    for r in enigma.rotors
        number = index_connected_to(r, number; backward=true)
    end
    number = enigma.plugboard[number]
    return number
end

function encode_single(enigma::EnigmaMachine, c::Char)
    number = Int(c)-64
    number = encode_single_idx_to_idx(enigma, number)
    return Char(number+64)
end

"""
    encode!(enigma::EnigmaMachine, s::String; input_validation=true, output_style=:enigma)

If all chars in the string are uppercase letters (so no spaces) then `input_validation` can be set to false for a bit speed up.\n
The default output consists of blocks of five letters. If you don't want the spaces you can set `output_style=false`.\n
Return the string encoded with the enigma.
"""
function encode!(enigma::EnigmaMachine, s::String; input_validation=true, output_style=:enigma)
    if input_validation
        s = replace(s, r"[^a-zA-Z]" => "")
        s = uppercase(s)
    end
    result = ""
    for c in s
        result *= encode_single(enigma, c)
    end
    output_style == :enigma && return enigma_styled_text(result)
    output_style == :plain && return result
end

"""
    decode!(enigma::EnigmaMachine, s::String; input_validation=true, output_style=:enigma)

Does the same as encode ;)
"""
function decode!(enigma::EnigmaMachine, s::String; input_validation=true, output_style=:enigma)
    return encode!(enigma, s; input_validation=input_validation, output_style=output_style)
end

"""
    enigma_styled_text(text::String)

Return creates an enigma styled text which means it replaces all chars which are not letters
and makes them uppercase. It also makes blocks of five letters for better or worse readability :D
"""
function enigma_styled_text(text::String)
    return string(strip(replace(uppercase(replace(text, r"[^a-zA-Z]"=>"")), r"(.{5})" => s"\1 ")))
end

export EnigmaMachine, encode!, decode!, set_rotors!, set_rotor_positions!, set_ukw!, set_plugboard!, enigma_styled_text
end
