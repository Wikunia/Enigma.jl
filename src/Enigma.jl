module Enigma

mutable struct Rotor
    order           :: Int # indicates whether it's the 1st, 2nd, 3rd rotor
    mapping         :: Vector{Int}
    mapping_bw      :: Vector{Int}
    position        :: Int
    rotation_point  :: Int
end

mutable struct EnigmaMachine
    plugboard       :: Vector{Int}
    rotors          :: Tuple{Rotor,Rotor,Rotor}
    ukw             :: Vector{Int}
end

function EnigmaMachine()
    return EnigmaMachine(1,2,3,1)
end

const possible_ukw = [
    05 10 13 26 01 12 25 24 22 02 23 06 03 18 17 21 15 14 20 19 16 09 11 08 07 04;
    25 18 21 08 17 19 12 04 16 24 14 07 15 11 13 09 05 02 06 26 03 23 22 10 01 20;
    06 22 16 10 09 01 15 25 05 04 18 26 24 23 07 03 20 11 21 17 19 02 14 13 08 12
]

const possible_rotors = [
    05 11 13 06 12 07 04 17 22 26 14 20 15 23 25 08 24 21 19 16 01 09 02 18 03 10;
    01 10 04 11 19 09 18 21 24 02 12 08 23 20 13 03 17 07 26 14 16 25 06 22 15 05;
    02 04 06 08 10 12 03 16 18 20 24 22 26 14 25 05 09 23 07 01 11 13 21 19 17 15;
    05 19 15 22 16 26 10 01 25 17 21 09 18 08 24 12 14 06 20 07 11 04 03 13 23 02;
    22 26 02 18 07 09 20 25 21 16 19 04 14 08 12 24 01 23 13 10 17 15 06 05 03 11
]
const rotation_points = [17 05 22 10 26]

function get_backward_mapping(order::Vector{Int})
    backward_mp = zeros(Int, 26)
    for i in 1:26
        backward_mp[order[i]] = i
    end
    return backward_mp
end

function Rotor(order::Int, mapping::Vector{Int}, position::Int, rotation_point::Int)
    return Rotor(order, mapping, get_backward_mapping(mapping), position, rotation_point)
end

function EnigmaMachine(r1::Int, r2::Int, r3::Int, ukw::Int; p1=1, p2=1, p3=1)
    rotor_1 = Rotor(1, possible_rotors[r1,:], p1, rotation_points[r1])
    rotor_2 = Rotor(2, possible_rotors[r2,:], p2, rotation_points[r2])
    rotor_3 = Rotor(3, possible_rotors[r3,:], p3, rotation_points[r3])

    return EnigmaMachine(collect(1:26), (rotor_1,rotor_2,rotor_3), possible_ukw[ukw,:])
end

function set_rotors!(enigma::EnigmaMachine, r1, r2, r3)
    ukw = enigma.ukw
    enigma = EnigmaMachine(r1, r2, r3, 1)
    enigma.ukw = ukw
end

function set_ukw!(enigma::EnigmaMachine, ukw)
    enigma = EnigmaMachine(enigma.plugboard, enigma.rotors, possible_ukw[ukw,:])
end

function set_rotor_positions!(enigma::EnigmaMachine, p1, p2, p3)
    rotor_1 = enigma.rotors[1]
    rotor_2 = enigma.rotors[2]
    rotor_3 = enigma.rotors[3]
    rotor_1.position = p1
    rotor_2.position = p2
    rotor_3.position = p3
    enigma = EnigmaMachine(enigma.plugboard, (rotor_1,rotor_2,rotor_3), enigma.ukw)
end

function set_plugboard!(enigma::EnigmaMachine, setting::String)
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
    end
end

function index_connected_to(rotor, index; backward=false)
    if !backward
        result = rotor.mapping[(index + 26 - rotor.position) % 26 + 1]+rotor.position-1
        result = (result-1+26) % 26 + 1
        backwards = index_connected_to(rotor, result; backward=true)
        @assert backwards == index
        return result
    else
        result = rotor.mapping_bw[(index + 26 - rotor.position) % 26 + 1]+rotor.position-1
        result = (result-1+26) % 26 + 1
        return result
    end
end

function encode_single(enigma::EnigmaMachine, c::Char)
    number = Int(uppercase(c))-64
    number = enigma.plugboard[number]
    step_rotors!(enigma)
    for i=3:-1:1
        r = enigma.rotors[i]
        number = index_connected_to(r, number)
    end
    number = enigma.ukw[number]
    for r in enigma.rotors
        number = index_connected_to(r, number; backward=true)
    end
    number = enigma.plugboard[number]
    return Char(number+64)
end

function encode(enigma::EnigmaMachine, s::String)
    s = replace(s, r"[^a-zA-Z]" => "")
    result = ""
    for c in s
        result *= encode_single(enigma, c)
    end
    return result
end

function decode(enigma::EnigmaMachine, s::String)
    return encode(enigma, s)
end

export EnigmaMachine, encode, decode, set_rotors!, set_rotor_positions!, set_ukw!, set_plugboard!
end 