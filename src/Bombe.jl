mutable struct BackTrackObj
    id          :: Int
    parent_id   :: Int
    depth       :: Int
    deduced_1   :: Tuple{Int,Int}
    deduced_2   :: Tuple{Int,Int}
end

mutable struct BombeMachine
    rotor_1          :: Vector{Int}
    rotor_2          :: Vector{Int}
    rotor_3          :: Vector{Int}
    rotor_1_pos      :: Vector{Int}
    rotor_2_pos      :: Vector{Int}
    rotor_3_pos      :: Vector{Int}
    ukw              :: Vector{Int}
    secret           :: String
    hint             :: String
    hint_positions   :: Vector{Int}
end

function BombeMachine(secret::String, hint::String)
    secret = uppercase(replace(secret, r"[^a-zA-Z]" => ""))
    hint   = uppercase(replace(hint, r"[^a-zA-Z]" => ""))
    return BombeMachine(collect(1:5), collect(1:5), collect(1:5), collect(1:26), collect(1:26), collect(1:26),
                        collect(1:3), secret, hint, 1:(length(secret)-length(hint)))
end

function set_possible_rotors!(bombe::BombeMachine, rotor_1, rotor_2, rotor_3)
    bombe.rotor_1 = isa(rotor_1, Int) ? [rotor_1] : rotor_1
    bombe.rotor_2 = isa(rotor_2, Int) ? [rotor_2] : rotor_2
    bombe.rotor_3 = isa(rotor_3, Int) ? [rotor_3] : rotor_3
end

function set_possible_rotor_positions!(bombe::BombeMachine, rp1, rp2, rp3)
    bombe.rotor_1_pos = isa(rp1, Int) ? [rp1] : rp1
    bombe.rotor_2_pos = isa(rp2, Int) ? [rp2] : rp2
    bombe.rotor_3_pos = isa(rp3, Int) ? [rp3] : rp3
end

function set_possible_ukws!(bombe::BombeMachine, ukws)
    bombe.ukw = isa(ukws, Int) ? [ukws] : ukws
end

function set_possible_hint_positions!(bombe::BombeMachine, hint_positions)
    bombe.hint_positions = isa(hint_positions, Int) ? [hint_positions] : hint_positions 
end

function set_hint!(bombe::BombeMachine, hint)
    bombe.hint = uppercase(replace(hint, r"[^a-zA-Z]" => ""))
    bombe.hint_positions = 1:(length(bombe.secret)-length(bombe.hint))
end

function set_secret!(bombe::BombeMachine, secret)
    bombe.secret = uppercase(replace(secret, r"[^a-zA-Z]" => ""))
    bombe.hint_positions = 1:(length(bombe.secret)-length(bombe.hint))
end

function run_cracking(bombe::BombeMachine; log=true)
    secret = bombe.secret
    hint = bombe.hint
    log && println("len secret: ", length(secret))
    log && println("Hint_positions: ",bombe.hint_positions)
    enigma = EnigmaMachine()
    secret = uppercase(replace(secret, r"[^a-zA-Z]" => ""))
    hint = uppercase(replace(hint, r"[^a-zA-Z]" => ""))
    possible_positions = get_possible_positions(bombe)
    log && println("possible_positions: $possible_positions")
    changed = zeros(Bool, 26)

    enigmas = Vector{EnigmaMachine}()
    deduced = Vector{Tuple{Int, Int}}(undef, 2)
    backtrack_vec = Vector{BackTrackObj}()
    sizehint!(backtrack_vec, 100000)
    push!(backtrack_vec, BackTrackObj(0, 0, 0, (0,0), (0,0)))
    already_deduced = Vector{Tuple{Int,Int}}(undef, 26)
    for p in possible_positions
        log && println("Try $hint at position $p")
        for ukw in bombe.ukw
            set_ukw!(enigma, ukw)
            for r1 in bombe.rotor_1, r2 in bombe.rotor_2, r3 in bombe.rotor_3
                if r1 == r2 || r1 == r3 || r2 == r3 
                    continue
                end
                set_rotors!(enigma, r1, r2, r3)
                for r1p in bombe.rotor_1_pos, r2p in bombe.rotor_2_pos, r3p = bombe.rotor_3_pos
                    set_rotor_positions!(enigma, r1p, r2p, r3p)

                    backtrack_vec[1] = BackTrackObj(0, 0, 0, (0,0), (0,0))
                    back_len = 1
                    possibilities = Vector{Vector{Tuple{Int,Int}}}()
                    b_id = 0
                    while true
                        b_id = get_next_backtrack_id(backtrack_vec, b_id+1, back_len)
                        if b_id !== nothing
                            back_len = one_deduction_step!(enigma, r1p, r2p, r3p, possibilities, already_deduced, deduced, changed, backtrack_vec, back_len, b_id, secret, hint, p)
                        else 
                            break
                        end
                    end
                    log && println("Tried: ukw: $ukw, Rotors: $r1, $r2, $r3 set to $r1p, $r2p, $r3p => New: $(length(possibilities))")
                    for pi=1:length(possibilities)
                        possible_enigma = EnigmaMachine()
                        set_rotors!(possible_enigma, r1, r2, r3)
                        set_rotor_positions!(possible_enigma, r1p, r2p, r3p)
                        set_ukw!(possible_enigma, ukw)
                        set_plugboard!(possible_enigma, possibilities[pi])
                        push!(enigmas, possible_enigma)
                    end
                end
            end   
        end     
    end
    return enigmas
end

function get_next_backtrack_id(backtrack_vec::Vector{BackTrackObj}, start, back_len)
    if start <= back_len
        return start
    end
    return nothing
end

function revert_deduced!(enigma, deduced, changed)
    for d in deduced
        d == (0,0) && continue
        enigma.plugboard[d[1]] = d[1]
        enigma.plugboard[d[2]] = d[2]
        changed[d[1]] = false
        changed[d[2]] = false
    end
end

function update_already_deduced!(already_deduced, backtrack_vec, backtrack_id)
    bid = backtrack_id
    c = 0
    while bid != 0
        if backtrack_vec[bid].deduced_1 != (0,0)
            c += 1
            already_deduced[c] = backtrack_vec[bid].deduced_1
        end
        if backtrack_vec[bid].deduced_2 != (0,0)
            c += 1
            already_deduced[c] = backtrack_vec[bid].deduced_2
        end
        bid = backtrack_vec[bid].parent_id
    end
    for i=c+1:26
        already_deduced[i] = (0,0)
    end
end

function one_deduction_step!(enigma::EnigmaMachine, r1p, r2p, r3p, possibilities::Vector{Vector{Tuple{Int,Int}}}, already_deduced, deduced, changed::Vector{Bool}, backtrack_vec::Vector{BackTrackObj}, back_len, backtrack_id, secret, hint, position)
    set_plugboard!(enigma, "")
    changed .= false
    update_already_deduced!(already_deduced, backtrack_vec, backtrack_id)
    for d in already_deduced
        d == (0,0) && break
        enigma.plugboard[d[1]] = d[2]
        enigma.plugboard[d[2]] = d[1]
        changed[d[1]] = true
        changed[d[2]] = true
    end

    hint_idx = backtrack_vec[backtrack_id].depth+1
    hint_letter = hint[hint_idx]
    secret_letter = secret[position-1+hint_idx]
    secret_letter_idx = Int(secret_letter-64)
    for plug_guess = 1:26
        deduced[1] = (0,0)
        deduced[2] = (0,0)
               
        steps = 1
        set_rotor_positions!(enigma, r1p,r2p,r3p)
        while steps < position-1+hint_idx
            step_rotors!(enigma)
            steps += 1
        end
        # println([r.position for r in enigma.rotors])

        # check if possible 
        if (!changed[secret_letter_idx] && !changed[plug_guess]) || (enigma.plugboard[secret_letter_idx] == plug_guess && enigma.plugboard[plug_guess] == secret_letter_idx)

            if !changed[secret_letter_idx] && !changed[plug_guess]
                enigma.plugboard[secret_letter_idx] = plug_guess
                enigma.plugboard[plug_guess]        = secret_letter_idx
                changed[secret_letter_idx]          = true
                changed[plug_guess]                 = true
                deduced[1] = (secret_letter_idx, plug_guess)
            end
        else
            continue
        end

        result_idx = Enigma.encode_single_idx_to_idx(enigma, secret_letter_idx)
        hint_letter_idx = Int(hint_letter-64)
        if !deduce_plugboard!(enigma, deduced, changed, result_idx, hint_letter_idx)
            revert_deduced!(enigma, deduced, changed)
            continue
        end
      
        revert_deduced!(enigma, deduced, changed)
        if hint_idx != length(hint)
            back_len += 1
            if back_len <= length(backtrack_vec)
                backtrack_vec[back_len].id        = back_len
                backtrack_vec[back_len].parent_id = backtrack_id
                backtrack_vec[back_len].depth     = hint_idx
                backtrack_vec[back_len].deduced_1 = deduced[1]
                backtrack_vec[back_len].deduced_2 = deduced[2]
            else
                push!(backtrack_vec, BackTrackObj(back_len, backtrack_id, hint_idx, deduced[1], deduced[2]))
            end
        else 
            plugboard = Vector{Tuple{Int,Int}}()
            for d in already_deduced
                d == (0,0) && continue
                push!(plugboard, d)
            end
            if deduced[1] != (0,0)
                push!(plugboard, deduced[1])
            end
            if deduced[2] != (0,0)
                push!(plugboard, deduced[2])
            end
            push!(possibilities, plugboard)
        end
    end
    return back_len
end

function deduce_plugboard!(enigma::EnigmaMachine, deduced::Vector{Tuple{Int, Int}}, changed::Vector{Bool}, from::Int, to::Int)
    # no plug needed as it already correctly connected
    if from == to && !changed[from] 
        changed[from]          = true
        if deduced[1] == (0,0)
            deduced[1] = (from, from)
        else
            deduced[2] = (from, from)
        end
        return true
    elseif from == to
        return true
    end
    if !changed[from] && !changed[to] 
        enigma.plugboard[from] = to
        enigma.plugboard[to]   = from
        changed[from]          = true
        changed[to]            = true
        if deduced[1] == (0,0)
            deduced[1] = (from, to)
        else
            deduced[2] = (from, to)
        end
        return true
    end
    return false
end

function get_possible_positions(bombe::BombeMachine)
    possible_positions = []
    hint = bombe.hint
    secret = bombe.secret
    for p in bombe.hint_positions
        possible = true
        for i=0:length(hint)-1
            if secret[p+i] == hint[i+1]
                possible = false
                break
            end
        end
        if possible
            push!(possible_positions, p)
        end
    end
    return possible_positions
end

export run_cracking, BombeMachine, set_possible_rotors!, set_possible_rotor_positions!, set_possible_ukws!, set_possible_hint_positions!, set_hint!, set_secret!