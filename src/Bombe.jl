mutable struct BackTrackObj
    depth   :: Int
    deduced :: Vector{Tuple{Int,Int}}
end

function bombe(secret::String, hint::String)
    enigma = EnigmaMachine()
    secret = uppercase(replace(secret, r"[^a-zA-Z]" => ""))
    hint = uppercase(replace(hint, r"[^a-zA-Z]" => ""))
    possible_positions = get_possible_positions(secret, hint)
    println("possible_positions: $possible_positions")
    changed = zeros(Bool, 26)

    enigmas = Vector{EnigmaMachine}()
    feasible_plugs = ones(Bool, (26,26))
    deduced = Vector{Tuple{Int, Int}}(undef, 2)
    backtrack_vec = Vector{BackTrackObj}()
    sizehint!(backtrack_vec, 20000)
    push!(backtrack_vec, BackTrackObj(0, Vector{Tuple{Int, Int}}()))
    for p in possible_positions[1:1]
        for r1=1:1, r2=2:2, r3=3:3
            if r1 == r2 || r1 == r3 || r2 == r3 
                continue
            end
            set_rotors!(enigma, r1, r2, r3)
            for r1p = 1:1, r2p = 1:1, r3p = 1:10
                
                set_rotor_positions!(enigma, r1p, r2p, r3p)
                
                backtrack_vec[1] = BackTrackObj(0, Vector{Tuple{Int, Int}}())
                back_len = 1
                possibilities = Vector{Vector{Tuple{Int, Int}}}()
                b_id = 0
                @time while true
                    b_id = get_next_backtrack_id(backtrack_vec, b_id+1, back_len)
                    if b_id !== nothing
                        back_len = one_deduction_step!(enigma, r1p, r2p, r3p, possibilities, feasible_plugs, deduced, changed, backtrack_vec, back_len, b_id, secret, hint, p)
                    else 
                        break
                    end
                end
                println("Try: $r1, $r2, $r3 set to $r1p, $r2p, $r3p => New: $(length(possibilities))")
                for pi=1:length(possibilities)
                    possible_enigma = EnigmaMachine()
                    set_rotor_positions!(possible_enigma, r1p, r2p, r3p)
                    set_ukw!(possible_enigma, 1)
                    set_plugboard!(possible_enigma, possibilities[pi])
                    push!(enigmas, possible_enigma)
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

function one_deduction_step!(enigma::EnigmaMachine, r1p, r2p, r3p, possibilities::Vector{Vector{Tuple{Int, Int}}}, feasible_plugs, deduced, changed::Vector{Bool}, backtrack_vec::Vector{BackTrackObj}, back_len, backtrack_id, secret, hint, position)
    set_plugboard!(enigma, "")
    changed .= false
    for d in backtrack_vec[backtrack_id].deduced
        enigma.plugboard[d[1]] = d[2]
        enigma.plugboard[d[2]] = d[1]
        changed[d[1]] = true
        changed[d[2]] = true
    end

    hint_idx = backtrack_vec[backtrack_id].depth+1
    hint_letter = hint[hint_idx]
    secret_letter = secret[position-1+hint_idx]
    secret_letter_idx = Int(secret_letter-64)
    feasible_plugs .= true
    for plug_guess = 1:26
        !feasible_plugs[secret_letter_idx, plug_guess] && continue
        deduced[1] = (0,0)
        deduced[2] = (0,0)
               
        steps = 1
        set_rotor_positions!(enigma, r1p,r2p,r3p)
        while steps < hint_idx
            step_rotors!(enigma)
            steps += 1
        end

        # check if possible 
        if (!changed[secret_letter_idx] && !changed[plug_guess]) || (enigma.plugboard[secret_letter_idx] == plug_guess && enigma.plugboard[plug_guess] == secret_letter_idx)

            if !changed[secret_letter_idx] && !changed[plug_guess]
                @assert enigma.plugboard[secret_letter_idx] == secret_letter_idx
                @assert enigma.plugboard[plug_guess] == plug_guess

                enigma.plugboard[secret_letter_idx] = plug_guess
                enigma.plugboard[plug_guess]        = secret_letter_idx
                changed[secret_letter_idx]          = true
                changed[plug_guess]                 = true
                deduced[1] = (secret_letter_idx, plug_guess)
            end
        else
            feasible_plugs[secret_letter_idx, plug_guess] = false
            continue
        end

        result_idx = Enigma.encode_single_idx_to_idx(enigma, secret_letter_idx)
        hint_letter_idx = Int(hint_letter-64)
        if !feasible_plugs[result_idx, hint_letter_idx] 
            revert_deduced!(enigma, deduced, changed)
            continue
        end
        if !deduce_plugboard!(enigma, deduced, changed, result_idx, hint_letter_idx)
            revert_deduced!(enigma, deduced, changed)
            feasible_plugs[result_idx, hint_letter_idx] = false
            continue
        end
      
        revert_deduced!(enigma, deduced, changed)
        if hint_idx != length(hint)
            back_len += 1
            if deduced[1] == (0,0)
                if back_len <= length(backtrack_vec)
                    backtrack_vec[back_len] = BackTrackObj(hint_idx, backtrack_vec[backtrack_id].deduced)
                else
                    push!(backtrack_vec, BackTrackObj(hint_idx, backtrack_vec[backtrack_id].deduced))
                end
            elseif deduced[2] == (0,0)
                if back_len <= length(backtrack_vec)
                    backtrack_vec[back_len] = BackTrackObj(hint_idx, vcat(backtrack_vec[backtrack_id].deduced, deduced[1]))
                else
                    push!(backtrack_vec, BackTrackObj(hint_idx, vcat(backtrack_vec[backtrack_id].deduced, deduced[1])))
                end
            else
                if back_len <= length(backtrack_vec)
                    backtrack_vec[back_len] = BackTrackObj(hint_idx, vcat(backtrack_vec[backtrack_id].deduced, deduced))
                else
                    push!(backtrack_vec, BackTrackObj(hint_idx, vcat(backtrack_vec[backtrack_id].deduced, deduced)))
                end
            end
        else 
            if deduced[1] == (0,0)
                push!(possibilities, backtrack_vec[backtrack_id].deduced)
            elseif deduced[2] == (0,0)
                push!(possibilities, vcat(backtrack_vec[backtrack_id].deduced, deduced[1]))
            else
                push!(possibilities, vcat(backtrack_vec[backtrack_id].deduced, deduced))
            end
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
        @assert enigma.plugboard[from] == from
        @assert enigma.plugboard[to] == to

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

function get_possible_positions(s::String, hint::String)
    possible_positions = []
    for p=1:length(s)-length(hint)
        possible = true
        for i=0:length(hint)-1
            if s[p+i] == hint[i+1]
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

export bombe