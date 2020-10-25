
function transferrects(pos, rectfrom, rectto, flips=(false, false))
    fracpos = (pos .- rectfrom.origin) ./ rectfrom.widths
    fracpos = ifelse.(flips, 1 .- fracpos, fracpos)
    return fracpos .* rectto.widths .+ rectto.origin
end

function add_rectangle_selector!(im_axis, rect_node=Node([0f0, 0f0, 0f0, 0f0]); flip_xy=false, color="red")
    draw_state = Node(0)
    draw_rect = rect_node
    mouse_state = MakieLayout.addmousestate!(im_axis.scene)

    lift(mouse_state, events(im_axis.scene).mouseposition) do ms, pos
        x, y = transferrects(pos, im_axis.scene.px_area[], im_axis.limits[], (im_axis.xreversed[], im_axis.yreversed[]))
        if flip_xy
            y, x = x, y
        end
        if ms.typ == MakieLayout.MouseLeftDown() ||
           ms.typ == MakieLayout.MouseLeftDrag()
            if draw_state[] == 0
                draw_state[] = 1
                draw_rect[][1:2] = [x, y]
                draw_rect[] = draw_rect[]
            else
                draw_rect[][3:4] = [x, y]
                draw_rect[] = draw_rect[]
            end
        elseif ms.typ == MakieLayout.MouseLeftUp()
            draw_state[] = 0
        end
        return nothing
    end

    x_coords = @lift([
        $draw_rect[1],
        $draw_rect[1],
        $draw_rect[3],
        $draw_rect[3],
        $draw_rect[1],
    ])
    y_coords =  @lift([
        $draw_rect[2],
        $draw_rect[4],
        $draw_rect[4],
        $draw_rect[2],
        $draw_rect[2],
    ])

    if flip_xy
        x_coords, y_coords = y_coords, x_coords
    end
    lines!(
        im_axis,
        x_coords, 
        y_coords,
        color = color,
    )
    return draw_rect
end

function ValueSlider(scene, grid_layout, grid_position; kwargs...)
    gl = GridLayout(1, 2)
    slider = gl[1, 1] = LSlider(scene; kwargs...)

    value_text = gl[1, 2] = LText(scene, text = lift(s -> "$(s)", slider.value))
    grid_layout[grid_position...] = gl
    return slider
end

"""
Make a set of sliders for function keyword arguments.
The syntax for arguments is :name=((min_max), [default], [:log])
"""
function slider_set(scene, parent_layout, location; kwargs...)
    n_args = length(kwargs)
    layout = GridLayout(n_args, 3)
    dict_vals = []
    is_log = falses(length(kwargs))
    for (i, (argname, argvals)) in enumerate(kwargs)
        arg_range = argvals[1]
        is_log = false
        if length(argvals) < 2
            arg_def = arg_range[length(arg_range)÷2]
        else
            arg_def = argvals[2]
            if length(argvals) == 3 && argvals[3] == :log
                is_log = true
            end
        end

        layout[i, 1] = LText(scene, text = String(argname), halign = :right)
        sl = layout[i, 2] = LSlider(scene, range = arg_range, startvalue = arg_def)

        if is_log
            node_val = lift(x -> 10^x, sl.value)
        else
            node_val = sl.value
        end

        push!(dict_vals, lift(Pair, AbstractPlotting.Node(argname), node_val))
        layout[i, 3] = LText(scene, text = lift(s -> "$s", node_val), halign = :left)
    end
    parent_layout[location...] = layout

    lift_dict = lift(dict_vals...) do (dvals...)
        return Dict(dvals...)
    end
    return lift_dict
end


function heatmap_mousehover(ax, dimensions)
    return lift(events(ax.scene).mouseposition) do pos

        pos = transferrects(pos, ax.scene.px_area[], ax.limits[])
        return if AbstractPlotting.is_mouseinside(ax.scene)
            return tuple(max.(min.(ceil.(Int, pos), dimensions), 1)...)
        else
            return 1, 1
        end
    end

end

function heatmap_mouseclick(ax, dimensions)
    old_position = AbstractPlotting.Node((1, 1))
    on(events(ax.scene).mousebuttons) do btns
        return if AbstractPlotting.Mouse.left ∈ btns
            pos_m = events(ax.scene).mouseposition[]

            pos = transferrects(pos_m, ax.scene.px_area[], ax.limits[])
            if AbstractPlotting.is_mouseinside(ax.scene)
                old_position[] = tuple(max.(min.(ceil.(Int, pos), dimensions), 1)...)
            end
        end
    end

    return old_position
end