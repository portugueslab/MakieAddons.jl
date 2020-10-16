
function browse_stack(stack; browse_dims = tuple(), kwargs...)
    s_ndims = ndims(stack)

    if length(browse_dims) == 0 && s_ndims > 2
        browse_dims = tuple((3:s_ndims)...)
    end

    i_br = 1
    browse_array = zeros(Int, s_ndims)
    for i_dim in 1:s_ndims
        if (i_br <= length(browse_dims)) && (i_dim == browse_dims[i_br])
            browse_array[i_dim] = i_br
            i_br += 1
        end
    end

    sc, layout = layoutscene( 1 + length(browse_dims), 1, resolution = (800, 800))

    sliders = [
        layout[1+i_l, :] = LSlider(sc, range = 1:size(stack, i_dim))
        for (i_l, i_dim) in enumerate(browse_dims)
    ]

    dim_sel = lift((sl.value for sl in sliders)...) do (sls...)
        return tuple((
            browse_array[i_dim] == 0 ? Colon() : sls[browse_array[i_dim]] for
            i_dim in 1:s_ndims
        )...)
    end

    if length(browse_dims) > 0
        current_slice = @lift(stack[($dim_sel)...])
    else
        current_slice = stack
    end

    im_axis = layout[1, 1] = LAxis(sc)

    heatmap!(im_axis, current_slice; kwargs...)
    im_axis.aspect = DataAspect()
    hidealldecorations!(im_axis)

    display(sc)
    return sc, layout, [sl.value for sl in sliders]
end