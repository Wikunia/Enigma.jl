using Makie, Colors, AbstractPlotting

function rectangle(x, y, w, h)
    return Point2f0[[x, y], [x+w, y], [x+w, y+h], [x, y+h]]
end

function plot_plugboard(scene::Makie.Scene, plugboard)
    order = 4
    width = 7.5

    text!(scene, "Steckbrett", position=(order*width+2.5, 27.0), textsize=1, align=(:center,:center))
    poly!(scene, rectangle(order*width, 0, 5, 26), color=:gray)

    for i=1:26
        letter = Char(i+64)
        # left box
        poly!(scene, rectangle(order*width-1, i-1, 1,1), color=:darkgray)
        text!(scene, string(letter), position=(order*width-0.5, i-0.5), textsize=0.5, align=(:center,:center))

        # right box
        poly!(scene, rectangle(order*width+5, i-1, 1,1), color=:darkgray)
        text!(scene, string(letter), position=(order*width+5.5, i-0.5), textsize=0.5, align=(:center,:center))
        
        lines!(scene, [order*width+4.7, order*width+5], [i-0.5, i-0.5], color=:black)
        lines!(scene, [order*width,order*width+0.3], [i-0.5, i-0.5], color=:black)

        y_pos_from = i-0.5
        y_pos_to = plugboard[i]-0.5
        lines!(scene, [order*width+4.7, order*width+0.3], [y_pos_from, y_pos_to], color=:black)
        
    end
    return scene
end

function plot_rotor(scene::Makie.Scene, rotor::Rotor)
    order = rotor.order
    width = 7.5

    text!(scene, "Rotor $(rotor.name)", position=(order*width+2.5, 27.0), textsize=1, align=(:center,:center))
    poly!(scene, rectangle(order*width, 0, 5, 26), color=:gray)

    letter_to_idx = Dict{Char, Int}()
    for i=1:26
        letter = Char((25+i+rotor.position-1)%26 +65)
        letter_to_idx[letter] = i
    end
    for i=1:26
        letter = Char((25+i+rotor.position-1)%26 +65)
        letter_to_idx[letter] = i
        # left box
        poly!(scene, rectangle(order*width-1, i-1, 1,1), color=:darkgray)
        text!(scene, string(letter), position=(order*width-0.5, i-0.5), textsize=0.5, align=(:center,:center))

        # right box
        poly!(scene, rectangle(order*width+5, i-1, 1,1), color=:darkgray)
        text!(scene, string(letter), position=(order*width+5.5, i-0.5), textsize=0.5, align=(:center,:center))

        # left side small - 
        lines!(scene, [order*width,order*width+0.3], [i-0.5, i-0.5], color=:black)

        # left side small - 
        lines!(scene, [order*width+4.7,order*width+5], [i-0.5, i-0.5], color=:black)
    end
    # plot connections
    for i=1:26
        y_pos_from = letter_to_idx[Char(i+64)]-0.5
        y_pos_to   = letter_to_idx[Char(rotor.mapping[i]+64)]-0.5

        lines!(scene, [order*width+4.7, order*width+0.3], [y_pos_from, y_pos_to], color=:black)
    end

    return scene
end

function plot_ukw(scene::Makie.Scene, ukw::Enigma.UKW)
    order = 0
    width = 7.5

    text!(scene, "UKW $(ukw.name)", position=(order*width+2.5, 27.0), textsize=1, align=(:center,:center))
    poly!(scene, rectangle(order*width, 0, 5, 26), color=:gray)
    
    for i=1:26
        letter = Char(i+64)
        # left box
        poly!(scene, rectangle(order*width-1, i-1, 1,1), color=:darkgray)
        text!(scene, string(letter), position=(order*width-0.5, i-0.5), textsize=0.5, align=(:center,:center))

        # right box
        poly!(scene, rectangle(order*width+5, i-1, 1,1), color=:darkgray)
        text!(scene, string(letter), position=(order*width+5.5, i-0.5), textsize=0.5, align=(:center,:center))

        # left lower/upper -
        lines!(scene, [order*width,order*width+0.3], [i-0.6, i-0.6], color=:black)
        lines!(scene, [order*width,order*width+0.3], [i-0.3, i-0.3], color=:black)
        
        # right lower -
        lines!(scene, [order*width+4.7,order*width+5], [i-0.6, i-0.6], color=:black)

        # right upper -
        lines!(scene, [order*width+4.7,order*width+5], [i-0.3, i-0.3], color=:black)
        
        y_pos_from = i-0.6
        y_pos_to = ukw.mapping[i]-0.6
        # right ro left
        lines!(scene, [order*width+4.7, order*width+0.3], [y_pos_from, y_pos_to], color=:black)

        # left to right
        lines!(scene, [order*width+0.3, order*width+4.7], [y_pos_from+0.3, y_pos_from+0.3], color=RGB(0.3, 0.3, 0.3))
    end
    return scene
end

function plot_enigma(enigma::EnigmaMachine)
    scene = Scene(show_axis=false, scale_plot=false, resolution=(1920,1080)); 
    plot_plugboard(scene, enigma.plugboard)
    for rotor in enigma.rotors
        plot_rotor(scene, rotor)
    end
    plot_ukw(scene, enigma.ukw)
    return scene
end

function update_plugboard(scene, node, plugboard; right_idx=nothing, left_idx=nothing)
    order = 4
    width = 7.5

    finished = false
    if right_idx !== nothing
        left_idx = plugboard[right_idx]
    else
        right_idx = plugboard[left_idx]
        finished = true
    end
    if !finished
        min_value = 1
    else
        min_value = 40*9
    end
    max_value = min_value + 40

    for i=(right_idx, left_idx)
        letter = Char(i+64)
        # left box
        if left_idx == i
            if !finished
                color = lift(i->i >= max_value ? :yellow : :darkgray, node)
            else
                color = lift(i->i >= min_value ? :yellow : :darkgray, node)
            end
            poly!(scene, rectangle(order*width-1, i-1, 1,1), color=color)
            text!(scene, string(letter), position=(order*width-0.5, i-0.5), textsize=0.5, align=(:center,:center))
        end

        # right box
        if right_idx == i
            if !finished
                color = lift(i->i >= min_value ? :yellow : :darkgray, node)
            else
                color = lift(i->i >= max_value ? :green : :darkgray, node)
            end
            poly!(scene, rectangle(order*width+5, i-1, 1,1), color=color)
            text!(scene, string(letter), position=(order*width+5.5, i-0.5), textsize=0.5, align=(:center,:center))
        end
        
        # right -
        if right_idx == i
            if !finished 
                color = lift(i->i >= 1 ? :yellow : :black, node)
            else
                color = lift(i->i >= max_value-1 ? :yellow : :black, node)
            end
            lines!(scene, [order*width+4.7, order*width+5], [i-0.5, i-0.5], color=color)
        end

        # left -
        if left_idx == i
            if !finished 
                color = lift(i->i >= max_value-1 ? :yellow : :black, node)
            else
                color = lift(i->i >= min_value+1 ? :yellow : :black, node)
            end
            lines!(scene, [order*width, order*width+0.3], [i-0.5, i-0.5], color=color)
        end

        if !finished && right_idx == i
            y_pos_from = i-0.5
            y_pos_to = plugboard[i]-0.5
            xs = lift(i->[order*width+4.7, order*width+4.7-4.4 * min(1.0, i/(max_value-1))], node)
            ys = lift(i->[y_pos_from, y_pos_from-(y_pos_from-y_pos_to) * min(1.0, i/(max_value-1))] , node)
            lines!(scene, xs, ys, color=:yellow)
        end

        if finished && left_idx == i
            y_pos_from = i-0.5
            y_pos_to = plugboard[i]-0.5
            xs = lift(i->i >= min_value+1 ? [order*width+0.3, order*width+0.3+4.4 * min(1.0, (i-min_value)/(40-1))] : [0.0,0.0], node)
            ys = lift(i->i >= min_value+1 ? [y_pos_from, y_pos_from-(y_pos_from-y_pos_to) * min(1.0, (i-min_value)/(40-1))] :  [0.0,0.0], node)
            lines!(scene, xs, ys, color=:yellow)
        end
    end

    return scene
end

function update_rotor(scene::Makie.Scene, node, rotor; right_idx=nothing, left_idx=nothing)
    @assert right_idx !== nothing || left_idx !== nothing 

    order = rotor.order
    width = 7.5
    invert_order = [3,2,1][order]
    range = 40
    min_value = range*invert_order
    if left_idx !== nothing
        min_value = range*3+80+order*range
    end
    max_value = min_value+range

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
        if i == left_idx 
            if !backwards 
                color = lift(i->i >= max_value ? :yellow : :darkgray, node)
            else
                color = lift(i->i >= min_value ? :yellow : :darkgray, node)
            end
            poly!(scene, rectangle(order*width-1, i-1, 1,1), color=color)
            text!(scene, string(letter), position=(order*width-0.5, i-0.5), textsize=0.5, align=(:center,:center))
        end

        # right box
        if i == right_idx
            if !backwards 
                color = lift(i->i >= min_value ? :yellow : :darkgray, node)
            else
                color = lift(i->i >= max_value ? :yellow : :darkgray, node)
            end
            poly!(scene, rectangle(order*width+5, i-1, 1,1), color=color)
            text!(scene, string(letter), position=(order*width+5.5, i-0.5), textsize=0.5, align=(:center,:center))
        end

        # left side small - 
        if i == left_idx
            if !backwards
                color = lift(i->i >= max_value-1 ? :yellow : :black, node)
            else
                color = lift(i->i >= min_value+1 ? :yellow : :black, node)
            end
            lines!(scene, [order*width,order*width+0.3], [i-0.5, i-0.5], color=color)
        end

        # right side small - 
        if i == right_idx
            if !backwards
                color = lift(i->i >= min_value+1 ? :yellow : :black, node)
            else
                color = lift(i->i >= max_value-1 ? :yellow : :black, node)
            end
            lines!(scene, [order*width+4.7,order*width+5], [i-0.5, i-0.5], color=color)
        end
    end

    # plot connections
    for i=1:26
        y_pos_from = letter_to_idx[Char(i+64)]-0.5
        y_pos_to   = letter_to_idx[Char(rotor.mapping[i]+64)]-0.5

        if right_idx == letter_to_idx[Char(i+64)]
            if backwards
                y_pos_from, y_pos_to = y_pos_to, y_pos_from
                xs = lift(i->min_value <= i ? [order*width+0.3, order*width+0.3+4.4 * min(1.0, (i-min_value)/(range-1))] : [0.0,0.0], node)
            else
                xs = lift(i->min_value <= i ? [order*width+4.7, order*width+4.7-4.4 * min(1.0, (i-min_value)/(range-1))] : [0.0,0.0], node)
            end
            ys = lift(i->min_value <= i ? [y_pos_from, y_pos_from-(y_pos_from-y_pos_to) * min(1.0, (i-min_value)/(range-1))] : [0.0,0.0] , node)
            lines!(scene, xs, ys, color=:yellow)
        end
    end
    return scene
end

function update_ukw(scene::Makie.Scene, node, ukw; right_idx=nothing)
    order = 0
    width = 7.5

    range = 80
    min_value = range/2*4
    max_value = min_value+range

    for i=(right_idx, ukw.mapping[right_idx])
        letter = Char(i+64)
        # left box
        if i == ukw.mapping[right_idx]
            color = lift(i->i >= min_value+range/2 ? :yellow : :darkgray, node)
            poly!(scene, rectangle(order*width-1, i-1, 1,1), color=color)
            text!(scene, string(letter), position=(order*width-0.5, i-0.5), textsize=0.5, align=(:center,:center))
        end

        # right box in
        if i == right_idx
            color = lift(i->i >= min_value ? :yellow : :darkgray, node)
            poly!(scene, rectangle(order*width+5, i-1, 1,1), color=color)
            text!(scene, string(letter), position=(order*width+5.5, i-0.5), textsize=0.5, align=(:center,:center))
        end

         # right box out
         if i == ukw.mapping[right_idx]
            color = lift(i->i >= max_value ? :yellow : :darkgray, node)
            poly!(scene, rectangle(order*width+5, i-1, 1,1), color=color)
            text!(scene, string(letter), position=(order*width+5.5, i-0.5), textsize=0.5, align=(:center,:center))
        end

        # left lower/upper
        if i == ukw.mapping[right_idx]
            color = lift(i->i >= min_value+range/2-1 ? :yellow : :black, node)
            lines!(scene, [order*width,order*width+0.3], [i-0.6, i-0.6], color=color)
            color = lift(i->i >= min_value+range/2+1 ? :yellow : :black, node)
            lines!(scene, [order*width,order*width+0.3], [i-0.3, i-0.3], color=color)
        end
        
        # right lower -
        if i == right_idx
            color = lift(i->i >= min_value+1 ? :yellow : :black, node)
            lines!(scene, [order*width+4.7,order*width+5], [i-0.6, i-0.6], color=color)
        end

        # right upper -
        if i == ukw.mapping[right_idx]
            color = lift(i->i >= max_value-1 ? :yellow : :black, node)
            lines!(scene, [order*width+4.7,order*width+5], [i-0.3, i-0.3], color=color)
        end
        
        y_pos_from = i-0.6
        y_pos_to = ukw.mapping[i]-0.6
        # right ro left
        if i == right_idx
            xs = lift(i->min_value <= i ? [order*width+4.7, order*width+4.7-4.4 * min(1.0, (i-min_value)/(range/2-1))] : [0.0,0.0], node)
            ys = lift(i->min_value <= i ? [y_pos_from, y_pos_from-(y_pos_from-y_pos_to) * min(1.0, (i-min_value)/(range/2-1))] : [0.0,0.0] , node)
            lines!(scene, xs, ys, color=:yellow)
        end

        # left to right
        if i == ukw.mapping[right_idx]
            xs = lift(i->min_value+range/2 <= i ? [order*width+0.3, order*width+0.3+4.4 * min(1.0, (i-(min_value+range/2))/(range/2-1))] : [0.0,0.0], node)
            lines!(scene, xs, [y_pos_from+0.3, y_pos_from+0.3], color=:yellow)
        end
    end
    return scene
end

function animate_enigma(enigma, letter)
    # AbstractPlotting.use_display[] = false
    # println("hi")
    letter = uppercase(letter)
    letter_idx = Int(letter-64)
    step_rotors!(enigma)
    scene = plot_enigma(enigma)
    node = Node(0.0)
    scene = update_plugboard(scene, node, enigma.plugboard; right_idx=letter_idx)
    right_idx = enigma.plugboard[letter_idx]
    for r=3:-1:1
        scene = update_rotor(scene, node, enigma.rotors[r]; right_idx=right_idx)
        right_idx = index_connected_to(enigma.rotors[r], right_idx)
    end
    scene = update_ukw(scene, node, enigma.ukw; right_idx=right_idx)
    left_idx = enigma.ukw.mapping[right_idx]
    for r=1:3
        scene = update_rotor(scene, node, enigma.rotors[r]; left_idx=left_idx)
        left_idx = index_connected_to(enigma.rotors[r], left_idx; backward=true)
    end
    scene = update_plugboard(scene, node, enigma.plugboard; left_idx=left_idx)

    N = 450
    record(scene, "visualizations/enigma.mp4", 1:N) do i
        push!(node, i)
    end
end

export plot_enigma, animate_enigma