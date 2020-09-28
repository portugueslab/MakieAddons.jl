const τ = 2π

"""
Polar plot on a MakieLayout LAxis
text size currently in data coordinates
"""
function polar_plot!(ax::LAxis, θ::AbstractArray{T1, 1}, r::AbstractArray{T2, 1};
        n_segments=8, textsize=0.05, kwargs...) where {T1, T2}
    
    limits = extrema(r)
    
    tickvalues = lift(ax.scene.px_area) do area
        px_width = minimum(area.widths)/2
        MakieLayout.locateticks(limits..., px_width, 100f0)
    end
    
    points_r = exp.(im*θ) .* r
    
    max_radius = lift(tickvalues) do tv
        if limits[2] > last(tv)
            maxr = limits[2]
        else
            maxr = last(tv)
        end
        return maxr
    end
    
    circ_angles = range(0, stop=2π, length=180) # TODO adapt the number depending on circle size
    points_grid = lift(tickvalues, max_radius) do tv, max_radius
        radii = max_radius > tv[end] ? [tv; max_radius] : tv
        circle_points = Array{Point2f0}(undef, length(circ_angles)*(length(radii))*2)
        i_add = 1
        for (i_circ, tickval) in enumerate(radii)
            for (an1, an2) in zip(circ_angles, [circ_angles[2:end]; 0])
                circle_points[i_add] = Point2f0(cos(an1)*tickval, sin(an1)*tickval)
                circle_points[i_add+1] = Point2f0(cos(an2)*tickval, sin(an2)*tickval)
                i_add += 2
            end
        end
        for angle in (0:n_segments-1) .* τ ./ n_segments
            push!(circle_points,
                    Point2f0(0, 0),
                    Point2f0(cos(angle)*max_radius,sin(angle)*max_radius))
        end
        
        return circle_points
    end
    
    linesegments!(ax, points_grid, color=RGB(0.8, 0.8, 0.8))
    plot!(ax, real.(points_r), imag.(points_r); kwargs...)
    
    radius_labels = lift(tickvalues) do tv
        texts = MakieLayout.linearly_spaced_tick_labels(tv)
        [
            (l,
            Point2f0(t, -textsize/2))
            for (t, l) in zip(tv, texts)
        ]
    end
    
    angle_labels = lift(max_radius) do max_radius
        return [
       (
            i == 1 ? "0" : "$(i-1)τ/$(n_segments)",
            Point2f0(cos(angle)*(max_radius+textsize*2),
                     sin(angle)*(max_radius+textsize*2))
        )
        for (i, angle) in enumerate((0:n_segments-1) .* τ ./ n_segments)
        ]
        
    end
    
    annotations!(ax, radius_labels, textsize=textsize, align=:top)
    annotations!(ax, angle_labels, textsize=textsize, align=(:center, :center))
    
    hidexdecorations!(ax)
    hideydecorations!(ax)
    ax.xgridvisible = false
    ax.ygridvisible = false
    ax.aspect = DataAspect()
    ax.topspinevisible = false
    ax.leftspinevisible = false
    ax.rightspinevisible = false
    ax.bottomspinevisible = false
end