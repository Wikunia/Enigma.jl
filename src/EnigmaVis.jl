using Plots, Colors

rectangle(w, h, x, y) = Shape(x .+ [0,w,w,0], y .+ [0,0,h,h])

function update_ukw_plot(plt, ukw, right_idx; connecting=false, connected=false)
    order = 0
    width = 7.5

    connected && (connecting = true)
    for i=(right_idx, ukw.mapping[right_idx])
        letter = Char(i+64)

        if connected && i == ukw.mapping[right_idx]
            plot!(plt, rectangle(1,1, order*width-1, i-1), color=:yellow)
            plot!(plt, [order*width-1], [i-1], annotation=(order*width-0.5, i-0.5, letter))
        end
        if right_idx == i || (right_idx !== nothing && i == ukw.mapping[right_idx] && connected)
            plot!(plt, rectangle(1,1, order*width+5, i-1), color=:yellow)
            plot!(plt, [order*width+5], [i-1], annotation=(order*width+5.5, i-0.5, letter))
        end

        # left lower/upper -
        if connecting && i == ukw.mapping[right_idx]
            plot!(plt, [order*width,order*width+0.3], [i-0.6, i-0.6], color=:yellow)
            plot!(plt, [order*width,order*width+0.3], [i-0.3, i-0.3], color=:yellow)
        end

        # right lower -
        if connecting && right_idx == i
            plot!(plt, [order*width+4.7,order*width+5], [i-0.6, i-0.6], color=:yellow)
        end

        # right upper -
        if connecting && i == ukw.mapping[right_idx]
            plot!(plt, [order*width+4.7,order*width+5], [i-0.3, i-0.3], color=:yellow)
        end

        y_pos_from = i-0.6
        y_pos_to = ukw.mapping[i]-0.6
        # right ro left
        if right_idx == i && (connecting || connected)
            plot!(plt, [order*width+4.7, order*width+0.3], [y_pos_from, y_pos_to], color=:yellow)
        end

        # left to right
        if right_idx !== nothing && ukw.mapping[right_idx] == i && connected
            plot!(plt, [order*width+0.3, order*width+4.7], [y_pos_from+0.3, y_pos_from+0.3], color=:yellow)
        end
    end
    return plt
end

function plot_ukw(plt, ukw)
    order = 0
    width = 7.5

    plot!(plt, [order*width+2.5], [27], annotation=(order*width+2.5, 27, "UKW $(ukw.name)"))
    plot!(plt, rectangle(5,26, order*width, 0), color=:gray)
    
    for i=1:26
        letter = Char(i+64)
        plot!(plt, rectangle(1,1, order*width-1, i-1), color=:darkgray)
        plot!(plt, [order*width-1], [i-1], annotation=(order*width-0.5, i-0.5, letter))
        
        plot!(plt, rectangle(1,1, order*width+5, i-1), color=:darkgray)
        plot!(plt, [order*width+5], [i-1], annotation=(order*width+5.5, i-0.5, letter))

        # left lower/upper -
        plot!(plt, [order*width,order*width+0.3], [i-0.6, i-0.6], color=:black)
        plot!(plt, [order*width,order*width+0.3], [i-0.3, i-0.3], color=:black)
        
        # right lower -
        plot!(plt, [order*width+4.7,order*width+5], [i-0.6, i-0.6], color=:black)

        # right upper -
        plot!(plt, [order*width+4.7,order*width+5], [i-0.3, i-0.3], color=:black)
        
        y_pos_from = i-0.6
        y_pos_to = ukw.mapping[i]-0.6
        # right ro left
        plot!(plt, [order*width+4.7, order*width+0.3], [y_pos_from, y_pos_to], color=:black)

        # left to right
        plot!(plt, [order*width+0.3, order*width+4.7], [y_pos_from+0.3, y_pos_from+0.3], color=RGB(0.3, 0.3, 0.3))
    end
    return plt
end

function update_plugboard_plot(plt, plugboard; right_idx=nothing, left_idx=nothing, connecting=false, connected=false)
    @assert right_idx !== nothing || left_idx !== nothing 
    order = 4
    width = 7.5

    connected_to = 0
    if right_idx !== nothing
        connected_to = plugboard[right_idx]
        plot_range = (right_idx, connected_to)
    end
    finished = false
    if left_idx !== nothing
        right_idx    = plugboard[left_idx]
        connected_to = left_idx
        finished = true
        plot_range = (right_idx, connected_to)
    end

    connected && (connecting = true)
    for i in (connected_to, right_idx)
        letter = Char(i+64)
        
        # left box and letter
        if (connected || finished) && connected_to == i
            plot!(plt, rectangle(1,1, order*width-1, i-1), color=:yellow)
            plot!(plt, [order*width-1], [i-1], annotation=(order*width-0.5, i-0.5, letter))
        end
        # right box and letter 
        if right_idx == i && finished && connected
            plot!(plt, rectangle(1,1, order*width+5, i-1), color=:green)
            plot!(plt, [order*width+5], [i-1], annotation=(order*width+5.5, i-0.5, letter))
        elseif right_idx == i && !finished
            plot!(plt, rectangle(1,1, order*width+5, i-1), color=:yellow)
            plot!(plt, [order*width+5], [i-1], annotation=(order*width+5.5, i-0.5, letter))
        end

        y_pos_from = i-0.5
        y_pos_to = plugboard[i]-0.5
        if connecting && right_idx == i
            plot!(plt, [order*width+4.7, order*width+0.3], [y_pos_from, y_pos_to], color=:yellow)
            plot!(plt, [order*width+4.7,order*width+5], [i-0.5, i-0.5], color=:yellow)
        end

        if connecting && connected_to == i
            plot!(plt, [order*width,order*width+0.3], [i-0.5, i-0.5], color=:yellow)
        end
    end
    return plt 
end

function plot_plugboard(plt, plugboard)
    order = 4
    width = 7.5

    plot!(plt, [order*width+2.5], [27], annotation=(order*width+2.5, 27, "Steckbrett"))
    plot!(plt, rectangle(5,26, order*width, 0), color=:gray)

    for i=1:26
        letter = Char(i+64)
        plot!(plt, rectangle(1,1, order*width-1, i-1), color=:darkgray)
        plot!(plt, [order*width-1], [i-1], annotation=(order*width-0.5, i-0.5, letter))
 
        plot!(plt, rectangle(1,1, order*width+5, i-1), color=:darkgray)
        plot!(plt, [order*width+5], [i-1], annotation=(order*width+5.5, i-0.5, letter))
        
        y_pos_from = i-0.5
        y_pos_to = plugboard[i]-0.5
        plot!(plt, [order*width+4.7, order*width+0.3], [y_pos_from, y_pos_to], color=:black)
        plot!(plt, [order*width+4.7,order*width+5], [i-0.5, i-0.5], color=:black)
        
        plot!(plt, [order*width,order*width+0.3], [i-0.5, i-0.5], color=:black)
    end
    return plt
end

function update_rotor_plot(plt::Plots.Plot, rotor::Rotor; right_idx = nothing, left_idx = nothing, connecting=false, connected=false)
    @assert right_idx !== nothing || left_idx !== nothing 

    order = rotor.order
    width = 7.5

    connected_to = 0
    backwards = false
    if right_idx !== nothing
        left_idx = index_connected_to(rotor, right_idx)
        plot_range = (right_idx, left_idx)
    else # left_idx
        right_idx = index_connected_to(rotor, left_idx; backward=true)
        plot_range = (right_idx, left_idx)
        backwards = true
    end
    letter_to_idx = Dict{Char, Int}()
    for i=1:26
        letter = Char((25+i+rotor.position-1)%26 +65)
        letter_to_idx[letter] = i
    end

    for i = (left_idx, right_idx)
        letter = Char((25+i+rotor.position-1)%26 +65)
        letter_to_idx[letter] = i
        # left box
        if left_idx == i && (backwards || connected)
            plot!(plt, rectangle(1,1, order*width-1, i-1), color=:yellow)
            plot!(plt, [order*width-1], [i-1], annotation=(order*width-0.5, i-0.5, letter))
        end
        # right box
        if right_idx == i && (!backwards || connected)
            plot!(plt, rectangle(1,1, order*width+5, i-1), color=:yellow)
            plot!(plt, [order*width+5], [i-1], annotation=(order*width+5.5, i-0.5, letter))
        end

        # left side small - 
        if left_idx == i
            plot!(plt, [order*width,order*width+0.3], [i-0.5, i-0.5], color=:yellow)
        end

        # left side small - 
        if right_idx == i
            plot!(plt, [order*width+4.7,order*width+5], [i-0.5, i-0.5], color=:yellow)
        end
    end

    # plot connections
    for i=1:26
        y_pos_from = letter_to_idx[Char(i+64)]-0.5
        y_pos_to   = letter_to_idx[Char(rotor.mapping[i]+64)]-0.5

        if right_idx == letter_to_idx[Char(i+64)]
            plot!(plt, [order*width+4.7, order*width+0.3], [y_pos_from, y_pos_to], color=:yellow)
        end
    end
    return plt
end

function plot_rotor(plt::Plots.Plot, rotor::Rotor)
    order = rotor.order
    width = 7.5

    plot!(plt, [order*width+2.5], [27], annotation=(order*width+2.5, 27, "Rotor $(rotor.name)"))
    plot!(plt, rectangle(5,26, order*width, 0), color=:gray)
    letter_to_idx = Dict{Char, Int}()
    for i=1:26
        letter = Char((25+i+rotor.position-1)%26 +65)
        letter_to_idx[letter] = i
    end
    for i=1:26
        letter = Char((25+i+rotor.position-1)%26 +65)
        letter_to_idx[letter] = i
        # left box
        plot!(plt, rectangle(1,1, order*width-1, i-1), color=:darkgray)
        plot!(plt, [order*width-1], [i-1], annotation=(order*width-0.5, i-0.5, letter))

        # right box
        plot!(plt, rectangle(1,1, order*width+5, i-1), color=:darkgray)
        plot!(plt, [order*width+5], [i-1], annotation=(order*width+5.5, i-0.5, letter))

        # left side small - 
        plot!(plt, [order*width,order*width+0.3], [i-0.5, i-0.5], color=:black)

        # left side small - 
        plot!(plt, [order*width+4.7,order*width+5], [i-0.5, i-0.5], color=:black)
    end
    # plot connections
    for i=1:26
        y_pos_from = letter_to_idx[Char(i+64)]-0.5
        y_pos_to   = letter_to_idx[Char(rotor.mapping[i]+64)]-0.5

        plot!(plt, [order*width+4.7, order*width+0.3], [y_pos_from, y_pos_to], color=:black)
    end

    return plt
end

function get_enigma_plot(enigma::EnigmaMachine)
    plt = plot(; size=(1000,800), grid=false, xaxis=false, yaxis=false, aspectratio=:equal, legend=false)

    plot_plugboard(plt, enigma.plugboard)
    for rotor in enigma.rotors
        plot_rotor(plt, rotor)
    end
    plot_ukw(plt, enigma.ukw)
    return plt
end

function get_enigma_decode_plots!(enigma::EnigmaMachine, letter::Char; pngs=false)
    plts = Plots.Plot[]
    plt = get_enigma_plot(enigma)
    push!(plts, deepcopy(plt))
    step_rotors!(enigma)
    plt = get_enigma_plot(enigma)
    push!(plts, deepcopy(plt))

    letter_idx = Int(letter-64)
    update_plugboard_plot(plt, enigma.plugboard; right_idx=letter_idx)
    push!(plts, deepcopy(plt))
    update_plugboard_plot(plt, enigma.plugboard; right_idx=letter_idx, connecting=true)
    push!(plts, deepcopy(plt))
    update_plugboard_plot(plt, enigma.plugboard; right_idx=letter_idx, connected=true)
    push!(plts, deepcopy(plt))
    pngs && png(plt, "visualizations/plugboard_in")
    
    plugboard_out_idx = enigma.plugboard[letter_idx]
    right_idx = plugboard_out_idx
    for r=3:-1:1
        update_rotor_plot(plt, enigma.rotors[r]; right_idx=right_idx)
        push!(plts, deepcopy(plt))
        update_rotor_plot(plt, enigma.rotors[r]; right_idx=right_idx, connecting=true)
        push!(plts, deepcopy(plt))
        update_rotor_plot(plt, enigma.rotors[r]; right_idx=right_idx, connected=true)
        push!(plts, deepcopy(plt))
        right_idx = index_connected_to(enigma.rotors[r], right_idx)
        pngs && png(plt, "visualizations/rotor_$(r)_in")
    end
    update_ukw_plot(plt, enigma.ukw, right_idx)
    push!(plts, deepcopy(plt))
    update_ukw_plot(plt, enigma.ukw, right_idx, connecting=true)
    push!(plts, deepcopy(plt))
    update_ukw_plot(plt, enigma.ukw, right_idx, connected=true)
    push!(plts, deepcopy(plt))
    left_idx = enigma.ukw.mapping[right_idx]
    pngs && png(plt, "visualizations/ukw")
    for r=1:3
        update_rotor_plot(plt, enigma.rotors[r]; left_idx=left_idx)
        push!(plts, deepcopy(plt))
        update_rotor_plot(plt, enigma.rotors[r]; left_idx=left_idx, connecting=true)
        push!(plts, deepcopy(plt))
        update_rotor_plot(plt, enigma.rotors[r]; left_idx=left_idx, connected=true)
        push!(plts, deepcopy(plt))
        left_idx = index_connected_to(enigma.rotors[r], left_idx; backward=true)
        pngs && png(plt, "visualizations/rotor_$(r)_bw")
    end
    update_plugboard_plot(plt, enigma.plugboard; left_idx=left_idx)
    push!(plts, deepcopy(plt))
    update_plugboard_plot(plt, enigma.plugboard; left_idx=left_idx, connecting=true)
    push!(plts, deepcopy(plt))
    update_plugboard_plot(plt, enigma.plugboard; left_idx=left_idx, connected=true)
    push!(plts, deepcopy(plt))
    pngs && png(plt_plug, "visualizations/plugboard_out")

    return plts
end

function animate_plots(plts::Vector{Plots.Plot}, fname::String; end_extra=5)
    anim = Animation()
    for plt in plts
        plot(plt) 
        frame(anim)
    end
    for i=1:end_extra
        plot(plts[end])
        frame(anim)
    end
    gif(anim, "$fname.gif", fps=4)
end

export get_enigma_plot, get_enigma_decode_plots!, animate_plots