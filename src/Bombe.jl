mutable struct BackTrackObj
    id          :: Int
    parent_id   :: Int
    deduced     :: Vector{Tuple{Int,Int}}
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
    # takes much longer if true => makes sure that the correct message is found even though a plug is not necessary for the hint
    check_ambiguous   :: Bool 
end

"""
    BombeMachine(secret::String, hint::String)

Return a Bombe with a given secret and a hint.
"""
function BombeMachine(secret::String, hint::String)
    secret = uppercase(replace(secret, r"[^a-zA-Z]" => ""))
    hint   = uppercase(replace(hint, r"[^a-zA-Z]" => ""))
    return BombeMachine(collect(1:5), collect(1:5), collect(1:5), collect(1:26), collect(1:26), collect(1:26),
                        collect(1:3), secret, hint, 1:length(secret)-length(hint)+1, false)
end

"""
    enable_ambiguous!(bombe::BombeMachine)

Be sure that the actual message gets found. This takes often much longer and uses lots of RAM :/\n
I would say most of the time it is not necessary. 
"""
function enable_ambiguous!(bombe::BombeMachine)
    bombe.check_ambiguous = true
end

"""
    disable_ambiguous!(bombe::BombeMachine)

If you enabled ambiguous by mistake and want to disable it again ;)
"""
function disable_ambiguous!(bombe::BombeMachine)
    bombe.check_ambiguous = false
end

"""
    set_possible_rotors!(bombe::BombeMachine, rotor_1, rotor_2, rotor_3)    

Set the rotors that should be checked. Each rotor can be either an integer or a vector of integers (or range). \n
i.e `set_possible_rotors!(bombe::BombeMachine, 1, 2:3, [4,5])`
"""
function set_possible_rotors!(bombe::BombeMachine, rotor_1, rotor_2, rotor_3)
    bombe.rotor_1 = isa(rotor_1, Int) ? [rotor_1] : rotor_1
    bombe.rotor_2 = isa(rotor_2, Int) ? [rotor_2] : rotor_2
    bombe.rotor_3 = isa(rotor_3, Int) ? [rotor_3] : rotor_3
end

"""
    set_possible_rotor_positions!(bombe::BombeMachine, rp1, rp2, rp3)

Set the rotor positions that should be checked. Each rotor position can be either an integer or a vector of integers (or range). \n
i.e `set_possible_rotor_positions!(bombe::BombeMachine, 1, 1:26, [20,22,25])``
"""
function set_possible_rotor_positions!(bombe::BombeMachine, rp1, rp2, rp3)
    bombe.rotor_1_pos = isa(rp1, Int) ? [rp1] : rp1
    bombe.rotor_2_pos = isa(rp2, Int) ? [rp2] : rp2
    bombe.rotor_3_pos = isa(rp3, Int) ? [rp3] : rp3
end

"""
    set_possible_ukws!(bombe::BombeMachine, ukws)

Set the possible reflectors. `ukws` can be a single one or a vector.
"""
function set_possible_ukws!(bombe::BombeMachine, ukws)
    bombe.ukw = isa(ukws, Int) ? [ukws] : ukws
end

"""
    set_possible_hint_positions!(bombe::BombeMachine, hint_positions)

Set the positions in the secret the hint might appeared.\n
i.e if you're sure it's the first word you can use `set_possible_hint_positions!(bombe::BombeMachine, 1)` or \n
if you know that it is at least in the beginning you can use something like `set_possible_hint_positions!(bombe::BombeMachine, 1:20)`.
"""
function set_possible_hint_positions!(bombe::BombeMachine, hint_positions)
    bombe.hint_positions = isa(hint_positions, Int) ? [hint_positions] : hint_positions 
end

"""
    set_hint!(bombe::BombeMachine, hint::String)

This changes the hint used for cracking.
"""
function set_hint!(bombe::BombeMachine, hint::String)
    bombe.hint = uppercase(replace(hint, r"[^a-zA-Z]" => ""))
    bombe.hint_positions = 1:(length(bombe.secret)-length(bombe.hint))
end

"""
    set_secret!(bombe::BombeMachine, secret::String)

This changes the secret used for cracking.
"""
function set_secret!(bombe::BombeMachine, secret::String)
    bombe.secret = uppercase(replace(secret, r"[^a-zA-Z]" => ""))
    bombe.hint_positions = 1:(length(bombe.secret)-length(bombe.hint))
end

"""
    run_cracking(bombe::BombeMachine; log=true)

Start the cracking process.\n
Does not give you all possibilities if you haven't run `enable_ambiguous!` but this is normally not reasonable.\n
Return possible enigma settings to understand the secret message.
"""
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
    push!(backtrack_vec, BackTrackObj(0, 0, Tuple[]))
    counter_mem = zeros(Int, 26)   
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

                    backtrack_vec[1] = BackTrackObj(0, 0, Tuple[])
                    back_len = 1
                    possibilities = Vector{Vector{Tuple{Int,Int}}}()
                    b_id = 0
                    while true
                        b_id = get_next_backtrack_id(backtrack_vec, b_id+1, back_len)
                        if b_id !== nothing
                            back_len = one_deduction_step!(bombe, enigma, r1p, r2p, r3p, possibilities, deduced, changed, backtrack_vec, back_len, b_id, secret, hint, p, counter_mem)
                        else 
                            break
                        end
                    end
                    if log && length(possibilities) > 0
                        println("Tried up to: ukw: $ukw, Rotors: $r1, $r2, $r3 set to $r1p, $r2p, $r3p => New: $(length(possibilities))")
                    end
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

"""
    pick_frequent_unchecked_letter(a::String, b::String, changed::Vector{Bool}, counter::Vector{Int})

Get most frequent letter which occurs in a or b and return the letter index 1-26 as well as the positions it occurred.
Make sure that we don't use a letter which was already used => only if `!changed[letter_idx]`
Counter must be an integer array with length(26). It will be overwritten!!
Return letter_idx, positions it occurs and corresponding letters on the other string. If no letter exists return letter_idx = 0
"""
function pick_frequent_unchecked_letter(a::String, b::String, changed::Vector{Bool}, counter)
    @assert length(a) == length(b)
    counter .= 0
    counter[changed] .= -length(a)
    for i=1:length(a)
        counter[Int(a[i]-64)] += 1
        counter[Int(b[i]-64)] += 1
    end
    max, letter_idx = findmax(counter)
    if max <= 0
        return 0, Int[], Int[]
    end
    letter = Char(letter_idx+64)
    check_positions = Int[]
    matching_letters = Int[]
    for i=1:length(a)
        if a[i] == letter
            push!(check_positions, i)
            push!(matching_letters, Int(b[i]-64))
        elseif b[i] == letter # elseif => don't push same position twice
            push!(check_positions, i)
            push!(matching_letters, Int(a[i]-64))
        end
    end
    return letter_idx, check_positions, matching_letters
end

function set_plugboard_to_deduced!(enigma, changed, deduced)
    set_plugboard!(enigma, "")
    changed .= false
    for d in deduced
        enigma.plugboard[d[1]] = d[2]
        enigma.plugboard[d[2]] = d[1]
        changed[d[1]] = true
        changed[d[2]] = true
    end
end

function update_check_positions!(check_positions, check_letters, matching_letters, hint, secret, a, b, c, d)
    @assert length(hint) == length(secret)
    check_pos_comp_counter = 1
    for i=1:length(hint)
        if i in check_positions
            continue
        end
        hint_idx = Int(hint[i]-64)
        secret_idx = Int(secret[i]-64)
        if hint_idx == a || secret_idx == a || hint_idx == b || secret_idx == b || hint_idx == c || secret_idx == c || hint_idx == d || secret_idx == d
            push!(check_positions, i)
            push!(check_letters, hint_idx)
            push!(matching_letters, secret_idx)
        end
    end
end

"""
    get_deduced_by_plugboard_and_changed(plugboard::Vector{Int}, changed::Vector{Bool})

Return a list of plugboard changes given the plugboard and a boolean `changed` vector. Latter is important to set connections like A <-> A
"""
function get_deduced_by_plugboard_and_changed(plugboard::Vector{Int}, changed::Vector{Bool})
    changed_copy = changed[:]
    deduced = Vector{Tuple{Int, Int}}()
    for i=1:length(changed)
        if changed_copy[i]
            from = i
            to = plugboard[i]
            # don't get to the same plug twice
            changed_copy[to] = false
            push!(deduced, (from, to))
        end
    end 
    return deduced
end

mutable struct CombinationObj
    deduced_head :: Vector{Tuple{Int,Int}}
    changed      :: Vector{Bool}       
end

function add_all_undeducable_combinations!(possibilities, combinations, changed)
    combination_vec = [CombinationObj(combinations[1], changed)]
    current_id = 1
    while current_id <= length(combination_vec)
        for i = 1:length(changed), j=i+1:length(changed)
            if !combination_vec[current_id].changed[i] && !combination_vec[current_id].changed[j]
                deduced = vcat(combination_vec[current_id].deduced_head, (i, j))
                new_changed = combination_vec[current_id].changed[:]
                new_changed[i] = true
                new_changed[j] = true
                push!(combination_vec, CombinationObj(deduced, new_changed))
                push!(possibilities, deduced)
            end
        end
        current_id += 1
    end
    return
end

function one_deduction_step!(bombe::BombeMachine, enigma::EnigmaMachine, r1p, r2p, r3p, possibilities::Vector{Vector{Tuple{Int,Int}}}, deduced, changed::Vector{Bool}, backtrack_vec::Vector{BackTrackObj}, back_len, backtrack_id, secret, hint, position, counter_mem)
    set_plugboard_to_deduced!(enigma, changed, backtrack_vec[backtrack_id].deduced)

    # pick letter index to check (one which is used most often in the possible range)
    # either in the secret message or in the hint 
    plug_start_idx, start_check_positions, start_matching_letters = pick_frequent_unchecked_letter(hint, secret[position:position+length(hint)-1], changed, counter_mem)
    if plug_start_idx == 0
        deduced_plugs = get_deduced_by_plugboard_and_changed(enigma.plugboard, changed)
        if bombe.check_ambiguous
            undeducable_combinations = [deduced_plugs]
            add_all_undeducable_combinations!(possibilities, undeducable_combinations, changed)
        else
            push!(possibilities, deduced_plugs)
        end
        return back_len
    end
    # println("Plug start with: $(Char(plug_start_idx+64)) on $start_check_positions")
    # println("The matching_letters are $([Char(c+64) for c in start_matching_letters])")
    # iterate over all plugboard settings
    for plug_guess = 1:26
        # set plugboard to this setting if not set
        changed[plug_guess] && continue
        check_positions = start_check_positions[:]
        check_letters = fill(plug_start_idx, length(check_positions))
        matching_letters = start_matching_letters[:]

        @assert changed[plug_start_idx] == false
        enigma.plugboard[plug_start_idx] = plug_guess
        enigma.plugboard[plug_guess] = plug_start_idx
        changed[plug_start_idx] = true
        changed[plug_guess]     = true

        check_pos_idx = 1
        is_possible = true
        while check_pos_idx <= length(check_positions)
            set_rotor_positions!(enigma, r1p,r2p,r3p)
            
            check_pos = check_positions[check_pos_idx]
            if check_pos_idx >= 3
                log = true
            else
                log = false
            end
            check_letter = check_letters[check_pos_idx]
           
            matching_letter = matching_letters[check_pos_idx]
            @assert changed[check_letter] || changed[matching_letter]
            # we have to validate that the input to the plugboard is well defined
            # if this is not the case we would overwrite it later => swap check_letter and matching_letter if necessary 
            if !changed[check_letter]
                check_letter, matching_letter = matching_letter, check_letter
            end
    
            check_pos_idx += 1
            # advance rotors to that position
            start = 1
            while start < position-1+check_pos
                step_rotors!(enigma)
                start += 1
            end
            # println("Rotor positions: ", [r.position for r in enigma.rotors])
            # run through machine 
            result_idx = Enigma.encode_single_idx_to_idx(enigma, check_letter)
            
            # make deduction and check new plug guess if wrong
            if !deduce_plugboard!(enigma, changed, result_idx, matching_letter)
                # can't be possible => reset plugboard
                set_plugboard_to_deduced!(enigma, changed, backtrack_vec[backtrack_id].deduced)
                is_possible = false
                break
            end

            # add new checks to check_positions, check_letters, matching_letters if not checked yet
            update_check_positions!(check_positions, check_letters, matching_letters, hint, secret[position:position+length(hint)-1], plug_guess, check_letter, result_idx, matching_letter)
        end
        if is_possible
            new_deduced = get_deduced_by_plugboard_and_changed(enigma.plugboard, changed)
            back_len += 1
            if back_len <= length(backtrack_vec)
                backtrack_vec[back_len].id        = back_len
                backtrack_vec[back_len].parent_id = backtrack_id
                backtrack_vec[back_len].deduced   = new_deduced
            else
                push!(backtrack_vec, BackTrackObj(back_len, backtrack_id, new_deduced))
            end
        end
        # reset plugboard to starting position
        set_plugboard_to_deduced!(enigma, changed, backtrack_vec[backtrack_id].deduced)
    end
    return back_len
end

function deduce_plugboard!(enigma::EnigmaMachine, changed::Vector{Bool}, from::Int, to::Int)
    # no plug needed as it already correctly connected
    if from == to && !changed[from] 
        changed[from]          = true
        return true
    elseif from == to
        return true
    end
    if !changed[from] && !changed[to] 
        enigma.plugboard[from] = to
        enigma.plugboard[to]   = from
        changed[from]          = true
        changed[to]            = true
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
export enable_ambiguous!, disable_ambiguous!