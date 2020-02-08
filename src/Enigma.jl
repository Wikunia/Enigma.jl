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

include("Bombe.jl")
include("EnigmaVis.jl")

function EnigmaMachine()
    return EnigmaMachine(1,2,3,1)
end

const possible_ukw = [
    "A" => [05, 10, 13, 26, 01, 12, 25, 24, 22, 02, 23, 06, 03, 18, 17, 21, 15, 14, 20, 19, 16, 09, 11, 08, 07, 04],
    "B" => [25, 18, 21, 08, 17, 19, 12, 04, 16, 24, 14, 07, 15, 11, 13, 09, 05, 02, 06, 26, 03, 23, 22, 10, 01, 20],
    "C" => [06, 22, 16, 10, 09, 01, 15, 25, 05, 04, 18, 26, 24, 23, 07, 03, 20, 11, 21, 17, 19, 02, 14, 13, 08, 12],
]

const possible_rotors = [
    "I"   => [05, 11, 13, 06, 12, 07, 04, 17, 22, 26, 14, 20, 15, 23, 25, 08, 24, 21, 19, 16, 01, 09, 02, 18, 03, 10],
    "II"  => [01, 10, 04, 11, 19, 09, 18, 21, 24, 02, 12, 08, 23, 20, 13, 03, 17, 07, 26, 14, 16, 25, 06, 22, 15, 05],
    "III" => [02, 04, 06, 08, 10, 12, 03, 16, 18, 20, 24, 22, 26, 14, 25, 05, 09, 23, 07, 01, 11, 13, 21, 19, 17, 15],
    "IV"  => [05, 19, 15, 22, 16, 26, 10, 01, 25, 17, 21, 09, 18, 08, 24, 12, 14, 06, 20, 07, 11, 04, 03, 13, 23, 02],
    "V"   => [22, 26, 02, 18, 07, 09, 20, 25, 21, 16, 19, 04, 14, 08, 12, 24, 01, 23, 13, 10, 17, 15, 06, 05, 03, 11]
]
const rotation_points = [18 06 23 11 01]

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

function EnigmaMachine(r1::Int, r2::Int, r3::Int, ukw::Int; p1=1, p2=1, p3=1)
    rotor_1 = Rotor(possible_rotors[r1].first, 1, possible_rotors[r1].second, p1, rotation_points[r1])
    rotor_2 = Rotor(possible_rotors[r2].first, 2, possible_rotors[r2].second, p2, rotation_points[r2])
    rotor_3 = Rotor(possible_rotors[r3].first, 3, possible_rotors[r3].second, p3, rotation_points[r3])

    return EnigmaMachine(collect(1:26), (rotor_1,rotor_2,rotor_3), UKW(possible_ukw[ukw].first, possible_ukw[ukw].second))
end

function set_rotors!(enigma::EnigmaMachine, r1, r2, r3)
    rotor_1 = Rotor(possible_rotors[r1].first, 1, possible_rotors[r1].second, enigma.rotors[1].position, rotation_points[r1])
    rotor_2 = Rotor(possible_rotors[r2].first, 2, possible_rotors[r2].second, enigma.rotors[2].position, rotation_points[r2])
    rotor_3 = Rotor(possible_rotors[r3].first, 3, possible_rotors[r3].second, enigma.rotors[3].position, rotation_points[r3])

    enigma.rotors = (rotor_1, rotor_2, rotor_3)
end

function set_ukw!(enigma::EnigmaMachine, ukw)
    enigma.ukw = UKW(possible_ukw[ukw].first, possible_ukw[ukw].second)
end

function set_rotor_positions!(enigma::EnigmaMachine, p1, p2, p3)
    enigma.rotors[1].position = p1
    enigma.rotors[2].position = p2
    enigma.rotors[3].position = p3
end

function set_plugboard!(enigma::EnigmaMachine, setting::Vector{Tuple{Int,Int}})
    for i=1:26
        enigma.plugboard[i] = i
    end
    for plug in setting
        enigma.plugboard[plug[1]] = plug[2]
        enigma.plugboard[plug[2]] = plug[1]
    end
end

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
    enigma.rotors[3].position %= 26
    if enigma.rotors[3].position == enigma.rotors[3].rotation_point
        enigma.rotors[2].position += 1
        enigma.rotors[2].position %= 26
        if enigma.rotors[2].position == enigma.rotors[2].rotation_point
            enigma.rotors[1].position += 1
            enigma.rotors[1].position %= 26
        end
    elseif enigma.rotors[2].position+1 == enigma.rotors[2].rotation_point
        enigma.rotors[2].position += 1
        enigma.rotors[2].position %= 26
        enigma.rotors[1].position += 1
        enigma.rotors[1].position %= 26
    end
end

function index_connected_to(rotor, index; backward=false)
    if !backward
        index = (index+25+rotor.position-1) % 26+1
        through_rotor = rotor.mapping[index]
        result = through_rotor-rotor.position+1
        result = (result-1 + 26) % 26 + 1
        return result
    else
        index = (index+25+rotor.position-1) % 26 + 1
        through_rotor = rotor.mapping_bw[index]
        result = through_rotor-rotor.position+1
        result = (result-1 + 26) % 26 + 1
        return result
    end
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

function encode(enigma::EnigmaMachine, s::String; input_validation=true, output_style=:enigma)
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

function decode(enigma::EnigmaMachine, s::String; input_validation=true, output_style=:enigma)
    return encode(enigma, s; input_validation=input_validation, output_style=output_style)
end

function enigma_styled_text(text::String)
    return string(strip(replace(uppercase(replace(text, r"[^a-zA-Z]"=>"")), r"(.{5})" => s"\1 ")))
end

export EnigmaMachine, encode, decode, set_rotors!, set_rotor_positions!, set_ukw!, set_plugboard!, enigma_styled_text
end 
