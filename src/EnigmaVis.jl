using Plots, Colors

rectangle(w, h, x, y) = Shape(x .+ [0,w,w,0], y .+ [0,0,h,h])

function plot_ukw(plt, ukw; right_idx=nothing, connecting=false, connected=false)
    order = 0
    width = 7.5

    redraw = right_idx === nothing ? true : false
    if redraw
        plot!(plt, [order*width+2.5], [27], annotation=(order*width+2.5, 27, "UKW $(ukw.name)"))
        plot!(plt, rectangle(5,26, order*width, 0), color=:gray)
    end
    connected && (connecting = true)
    for i=1:26
        if !redraw && i != ukw.mapping[right_idx] && i != right_idx
            continue
        end
        letter = Char(i+64)
        if connected && i == ukw.mapping[right_idx]
            plot!(plt, rectangle(1,1, order*width-1, i-1), color=:yellow)
        else
            plot!(plt, rectangle(1,1, order*width-1, i-1), color=:darkgray)
        end
        if right_idx == i || (right_idx !== nothing && i == ukw.mapping[right_idx] && connected)
            plot!(plt, rectangle(1,1, order*width+5, i-1), color=:yellow)
        else
            plot!(plt, rectangle(1,1, order*width+5, i-1), color=:darkgray)
        end
        plot!(plt, [order*width-1], [i-1], annotation=(order*width-0.5, i-0.5, letter))
        plot!(plt, [order*width+5], [i-1], annotation=(order*width+5.5, i-0.5, letter))

        # left lower/upper -
        if connecting && i == ukw.mapping[right_idx]
            plot!(plt, [order*width,order*width+0.3], [i-0.6, i-0.6], color=:yellow)
            plot!(plt, [order*width,order*width+0.3], [i-0.3, i-0.3], color=:yellow)
        else
            plot!(plt, [order*width,order*width+0.3], [i-0.6, i-0.6], color=:black)
            plot!(plt, [order*width,order*width+0.3], [i-0.3, i-0.3], color=:black)
        end
        
        # right lower -
        if connecting && right_idx == i
            plot!(plt, [order*width+4.7,order*width+5], [i-0.6, i-0.6], color=:yellow)
        else
            plot!(plt, [order*width+4.7,order*width+5], [i-0.6, i-0.6], color=:black)
        end
        # right upper -
        if connecting && i == ukw.mapping[right_idx]
            plot!(plt, [order*width+4.7,order*width+5], [i-0.3, i-0.3], color=:yellow)
        else
            plot!(plt, [order*width+4.7,order*width+5], [i-0.3, i-0.3], color=:black)
        end
        
        y_pos_from = i-0.6
        y_pos_to = ukw.mapping[i]-0.6
        # right ro left
        if right_idx == i && (connecting || connected)
            plot!(plt, [order*width+4.7, order*width+0.3], [y_pos_from, y_pos_to], color=:yellow)
        else
            plot!(plt, [order*width+4.7, order*width+0.3], [y_pos_from, y_pos_to], color=:black)
        end

        # left to right
        if right_idx !== nothing && ukw.mapping[right_idx] == i && connected
            plot!(plt, [order*width+0.3, order*width+4.7], [y_pos_from+0.3, y_pos_from+0.3], color=:yellow)
        else
            plot!(plt, [order*width+0.3, order*width+4.7], [y_pos_from+0.3, y_pos_from+0.3], color=RGB(0.3, 0.3, 0.3))
        end
    end
    return plt
end

function plot_plugboard(plt, plugboard; right_idx=nothing, left_idx=nothing, connecting=false, connected=false)
    order = 4
    width = 7.5

    connected_to = 0
    plot_range = 1:26
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
    redraw = false
    if right_idx === nothing
        redraw = true
        plot!(plt, [order*width+2.5], [27], annotation=(order*width+2.5, 27, "Steckbrett"))
        plot!(plt, rectangle(5,26, order*width, 0), color=:gray)
    end
   
    for i=plot_range
        letter = Char(i+64)
        if (connected || finished) && connected_to == i
            plot!(plt, rectangle(1,1, order*width-1, i-1), color=:yellow)
            !redraw && plot!(plt, [order*width-1], [i-1], annotation=(order*width-0.5, i-0.5, letter))
        elseif redraw
            plot!(plt, rectangle(1,1, order*width-1, i-1), color=:darkgray)
        end
        if right_idx == i && finished && connected
            plot!(plt, rectangle(1,1, order*width+5, i-1), color=:green)
            !redraw && plot!(plt, [order*width+5], [i-1], annotation=(order*width+5.5, i-0.5, letter))
        elseif right_idx == i
            plot!(plt, rectangle(1,1, order*width+5, i-1), color=:yellow)
            !redraw && plot!(plt, [order*width+5], [i-1], annotation=(order*width+5.5, i-0.5, letter))
        elseif redraw
            plot!(plt, rectangle(1,1, order*width+5, i-1), color=:darkgray)
        end
        if redraw
            plot!(plt, [order*width-1], [i-1], annotation=(order*width-0.5, i-0.5, letter))
            plot!(plt, [order*width+5], [i-1], annotation=(order*width+5.5, i-0.5, letter))
        end
        
        y_pos_from = i-0.5
        y_pos_to = plugboard[i]-0.5
        if (!connecting && !connected) || right_idx != i
            plot!(plt, [order*width+4.7, order*width+0.3], [y_pos_from, y_pos_to], color=:black)
            plot!(plt, [order*width+4.7,order*width+5], [i-0.5, i-0.5], color=:black)
        else
            plot!(plt, [order*width+4.7, order*width+0.3], [y_pos_from, y_pos_to], color=:yellow)
            plot!(plt, [order*width+4.7,order*width+5], [i-0.5, i-0.5], color=:yellow)
        end
        
        if (!connecting && !connected) || connected_to != i
            plot!(plt, [order*width,order*width+0.3], [i-0.5, i-0.5], color=:black)
        else
            plot!(plt, [order*width,order*width+0.3], [i-0.5, i-0.5], color=:yellow)
        end       
    end
    return plt
end

function plot_rotor(plt::Plots.Plot, rotor::Rotor; right_idx = nothing, left_idx = nothing, connecting=false, connected=false, backwards=false)
    order = rotor.order
    width = 7.5
    plot_range = 1:26

    connected_to = 0
    if right_idx !== nothing
        left_idx = index_connected_to(rotor, right_idx)
        plot_range = (right_idx, left_idx)
    elseif left_idx !== nothing
        right_idx = index_connected_to(rotor, left_idx; backward=true)
        plot_range = (right_idx, left_idx)
    end

    redraw = right_idx === nothing ? true : false
    if redraw
        plot!(plt, [order*width+2.5], [27], annotation=(order*width+2.5, 27, "Rotor $(rotor.name)"))
        plot!(plt, rectangle(5,26, order*width, 0), color=:gray)
    end
    letter_to_idx = Dict{Char, Int}()
    for i=1:26
        letter = Char((25+i+rotor.position-1)%26 +65)
        letter_to_idx[letter] = i
    end
    println(rotor.name, " -> ", rotor.position)
    for i in plot_range
        letter = Char((25+i+rotor.position-1)%26 +65)
        letter_to_idx[letter] = i
        # left box
        if left_idx == i && (backwards || connected)
            plot!(plt, rectangle(1,1, order*width-1, i-1), color=:yellow)
            !redraw && plot!(plt, [order*width-1], [i-1], annotation=(order*width-0.5, i-0.5, letter))
        elseif redraw
            plot!(plt, rectangle(1,1, order*width-1, i-1), color=:darkgray)
        end
        # right box
        if right_idx == i && (!backwards || connected)
            plot!(plt, rectangle(1,1, order*width+5, i-1), color=:yellow)
            !redraw && plot!(plt, [order*width+5], [i-1], annotation=(order*width+5.5, i-0.5, letter))
        elseif redraw
            plot!(plt, rectangle(1,1, order*width+5, i-1), color=:darkgray)
        end
        if redraw
            plot!(plt, [order*width-1], [i-1], annotation=(order*width-0.5, i-0.5, letter))
            plot!(plt, [order*width+5], [i-1], annotation=(order*width+5.5, i-0.5, letter))
        end
        # left side small - 
        if left_idx == i
            plot!(plt, [order*width,order*width+0.3], [i-0.5, i-0.5], color=:yellow)
        elseif redraw
            plot!(plt, [order*width,order*width+0.3], [i-0.5, i-0.5], color=:black)
        end

        # left side small - 
        if right_idx == i
            plot!(plt, [order*width+4.7,order*width+5], [i-0.5, i-0.5], color=:yellow)
        elseif redraw
            plot!(plt, [order*width+4.7,order*width+5], [i-0.5, i-0.5], color=:black)
        end
    end
    # plot connections
    for i=1:26
        y_pos_from = letter_to_idx[Char(i+64)]-0.5
        y_pos_to   = letter_to_idx[Char(rotor.mapping[i]+64)]-0.5
        if right_idx == letter_to_idx[Char(i+64)]
            plot!(plt, [order*width+4.7, order*width+0.3], [y_pos_from, y_pos_to], color=:yellow)
        elseif redraw
            plot!(plt, [order*width+4.7, order*width+0.3], [y_pos_from, y_pos_to], color=:black)
        end
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
    plot_plugboard(plt, enigma.plugboard; right_idx=letter_idx)
    push!(plts, deepcopy(plt))
    plot_plugboard(plt, enigma.plugboard; right_idx=letter_idx, connecting=true)
    push!(plts, deepcopy(plt))
    plot_plugboard(plt, enigma.plugboard; right_idx=letter_idx, connected=true)
    push!(plts, deepcopy(plt))
    pngs && png(plt, "visualizations/plugboard_in")
    
    plugboard_out_idx = enigma.plugboard[letter_idx]
    right_idx = plugboard_out_idx
    println("Position after plugboard: ", right_idx)
    for r=3:-1:1
        plot_rotor(plt, enigma.rotors[r]; right_idx=right_idx)
        push!(plts, deepcopy(plt))
        plot_rotor(plt, enigma.rotors[r]; right_idx=right_idx, connecting=true)
        push!(plts, deepcopy(plt))
        plot_rotor(plt, enigma.rotors[r]; right_idx=right_idx, connected=true)
        push!(plts, deepcopy(plt))
        right_idx = index_connected_to(enigma.rotors[r], right_idx)
        println("Position after rotor $r: ", right_idx)
        pngs && png(plt, "visualizations/rotor_$(r)_in")
    end
    plot_ukw(plt, enigma.ukw; right_idx=right_idx)
    push!(plts, deepcopy(plt))
    plot_ukw(plt, enigma.ukw; right_idx=right_idx, connecting=true)
    push!(plts, deepcopy(plt))
    plot_ukw(plt, enigma.ukw; right_idx=right_idx, connected=true)
    push!(plts, deepcopy(plt))
    left_idx = enigma.ukw.mapping[right_idx]
    pngs && png(plt, "visualizations/ukw")
    for r=1:3
        plot_rotor(plt, enigma.rotors[r]; left_idx=left_idx)
        push!(plts, deepcopy(plt))
        plot_rotor(plt, enigma.rotors[r]; left_idx=left_idx, connecting=true, backwards=true)
        push!(plts, deepcopy(plt))
        plot_rotor(plt, enigma.rotors[r]; left_idx=left_idx, connected=true, backwards=true)
        push!(plts, deepcopy(plt))
        left_idx = index_connected_to(enigma.rotors[r], left_idx; backward=true)
        pngs && png(plt, "visualizations/rotor_$(r)_bw")
    end
    plot_plugboard(plt, enigma.plugboard; left_idx=left_idx)
    push!(plts, deepcopy(plt))
    plot_plugboard(plt, enigma.plugboard; left_idx=left_idx, connecting=true)
    push!(plts, deepcopy(plt))
    plot_plugboard(plt, enigma.plugboard; left_idx=left_idx, connected=true)
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