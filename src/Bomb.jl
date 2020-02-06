mutable struct BackTrackObj
    open    :: Bool 
    depth   :: Int
    deduced :: Vector{Tuple{Int,Int}}
end

function bomb(secret::String, hint::String)
    enigma = EnigmaMachine()
    secret = uppercase(replace(secret, r"[^a-zA-Z]" => ""))
    hint = uppercase(replace(hint, r"[^a-zA-Z]" => ""))
    possible_positions = get_possible_positions(secret, hint)
    println("possible_positions: $possible_positions")
    changed = zeros(Bool, 26)

    enigmas = Vector{EnigmaMachine}()

    for p in possible_positions[1:1]
        backtrack_vec = Vector{BackTrackObj}()
        sizehint!(backtrack_vec, 10000)
        push!(backtrack_vec, BackTrackObj(true, 0, Vector{Tuple{Int, Int}}()))
        possibilities = Vector{Vector{Tuple{Int, Int}}}()
        @time begin 
        while true
            b_id = get_next_backtrack_id(backtrack_vec)
            if b_id !== nothing
                one_deduction_step!(enigma, possibilities, changed, backtrack_vec, b_id, secret, hint, p)
            else 
                break
            end
        end
        end
        println("#possibilities: $(length(possibilities))")
        
        for pi=1:length(possibilities)
            enigma = EnigmaMachine()
            set_rotors!(enigma, 1,2,3)
            set_rotor_positions!(enigma, 1,1,1)
            set_ukw!(enigma, 1)
            set_plugboard!(enigma, possibilities[pi])
            push!(enigmas, enigma)
        end
    end
    return enigmas
end

function get_next_backtrack_id(backtrack_vec::Vector{BackTrackObj})
    for bi in 1:length(backtrack_vec)
        b = backtrack_vec[bi]
        if b.open
            return bi
        end
    end
    return nothing
end

function one_deduction_step!(enigma::EnigmaMachine, possibilities::Vector{Vector{Tuple{Int, Int}}}, changed::Vector{Bool}, backtrack_vec::Vector{BackTrackObj}, backtrack_id, secret, hint, position)
    set_plugboard!(enigma, "")
    changed .= false
    # println("Start deduced: ", backtrack_vec[backtrack_id].deduced)
    for d in backtrack_vec[backtrack_id].deduced
        enigma.plugboard[d[1]] = d[2]
        enigma.plugboard[d[2]] = d[1]
        changed[d[1]] = true
        changed[d[2]] = true
    end
    # println("Start changed: ", changed)
    backtrack_vec[backtrack_id].open = false

    # println("==================================")
    # println("Possible position: $position")
    log = false
    log && println("deduced: ", backtrack_vec[backtrack_id].deduced)

    hint_idx = backtrack_vec[backtrack_id].depth+1
    hint_letter = hint[hint_idx]
    secret_letter = secret[position-1+hint_idx]
    secret_letter_idx = Int(secret_letter-64)
    hint_idx == 1 && println("Hint_idx = 1, Try to get $secret_letter -> $hint_letter")
    log && println("Hint_idx = $hint_idx, Try to get $secret_letter -> $hint_letter")

    for plug_guess = 1:26
        deduced = Vector{Tuple{Int, Int}}()
        steps = 1
        set_rotor_positions!(enigma, 1,1,1)
        while steps < hint_idx
            step_rotors!(enigma)
            steps += 1
        end
        # log && println([r.position for r in enigma.rotors])
        # log && println(enigma.plugboard)
        # log && println("--------------------------------------------")
        
        # log && println("Try connecting: $secret_letter <-> $(Char(plug_guess+64))")
        # check if possible 
        @assert length(deduced) == 0
        if (!changed[secret_letter_idx] && !changed[plug_guess]) || (enigma.plugboard[secret_letter_idx] == plug_guess && enigma.plugboard[plug_guess] == secret_letter_idx)

            if !changed[secret_letter_idx] && !changed[plug_guess]
                @assert enigma.plugboard[secret_letter_idx] == secret_letter_idx
                @assert enigma.plugboard[plug_guess] == plug_guess

                enigma.plugboard[secret_letter_idx] = plug_guess
                enigma.plugboard[plug_guess]        = secret_letter_idx
                changed[secret_letter_idx]          = true
                changed[plug_guess]                 = true
                push!(deduced, (secret_letter_idx, plug_guess))
            end
        else
            # log && println("NOT POSSIBLE")
            continue
        end
        # log && println("Connected: $(Char(secret_letter_idx+64)) <-> $(Char(plug_guess+64))")

        result = Enigma.encode_single(enigma, secret_letter)
        # log && println("Current result: $secret_letter -> $result")
        # deduce plugboard
        # println("Changed: ", changed)
        if !deduce_plugboard!(enigma, deduced, changed, Int(result-64), Int(hint_letter-64))
            # revert deduction:
            for d in deduced
                enigma.plugboard[d[1]] = d[1]
                enigma.plugboard[d[2]] = d[2]
                changed[d[1]] = false
                changed[d[2]] = false
            end
            # log && println("NOT POSSIBLE")
            continue
        end
        set_rotor_positions!(enigma, 1,1,1)
        for i=1:hint_idx
            result_local = Enigma.encode_single(enigma, secret[position-1+i])
            if result_local != hint[i]
                println("Latest: $result -> $hint_letter")
                println("hint_idx: $hint_idx, i: $i")
                println("result_local: $result_local != $(hint[i])")
                println("Deduced so far: ", [(Char(j[1]+64), Char(j[2]+64))  for j in vcat(backtrack_vec[backtrack_id].deduced, deduced)])
                println("Added to deduced: ", [(Char(j[1]+64), Char(j[2]+64))  for j in deduced])
                println("Changed: ", changed)
                err()
            end
        end
      
        log && println("changed: $changed")
        log && println("Connected $(result) <-> $(hint_letter)")
        # revert deduction:
        for d in deduced
            enigma.plugboard[d[1]] = d[1]
            enigma.plugboard[d[2]] = d[2]
            changed[d[1]] = false
            changed[d[2]] = false
        end
        if hint_idx != length(hint)
            push!(backtrack_vec, BackTrackObj(true, hint_idx, vcat(backtrack_vec[backtrack_id].deduced, deduced)))
        else 
            push!(possibilities, vcat(backtrack_vec[backtrack_id].deduced, deduced))
        end
    end
end

function deduce_plugboard!(enigma::EnigmaMachine, deduced::Vector{Tuple{Int, Int}}, changed::Vector{Bool}, from::Int, to::Int)
    # no plug needed as it already correctly connected
    if from == to && !changed[from] 
        changed[from]          = true
        push!(deduced, (from, from))
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
        push!(deduced, (from, to))
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

export bomb