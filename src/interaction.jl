
function transferrects(pos, rectfrom, rectto, flips=(false, false))
    fracpos = (pos .- rectfrom.origin) ./ rectfrom.widths
    fracpos = ifelse.(flips, 1 .- fracpos, fracpos)
    return fracpos .* rectto.widths .+ rectto.origin
end

function add_rectangle_selector!(im_axis, rect_node=Node([0f0, 0f0, 0f0, 0f0]); color="red")
    draw_state = Node(0)
    draw_rect = rect_node
    mouse_state = MakieLayout.addmousestate!(im_axis.scene)

    lift(mouse_state, events(im_axis.scene).mouseposition) do ms, pos
        x, y = transferrects(pos, im_axis.scene.px_area[], im_axis.limits[], (im_axis.xreversed[], im_axis.yreversed[]))
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

    lines!(
        im_axis,
        @lift([
            $draw_rect[1],
            $draw_rect[1],
            $draw_rect[3],
            $draw_rect[3],
            $draw_rect[1],
        ]),
        @lift([
            $draw_rect[2],
            $draw_rect[4],
            $draw_rect[4],
            $draw_rect[2],
            $draw_rect[2],
        ]),
        color = color,
    )
    return draw_rect
end