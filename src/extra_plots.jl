function mn_sd_plot!(ax, xs, mat)
    mn_sec = @lift(mean($mat, dims = 2)[:, 1])
    sd_sec = @lift(std($mat, dims = 2)[:, 1])
    plot!(ax, xs, mn_sec)
    return plot!(
        ax,
        Band,
        xs,
        @lift($mn_sec .- $sd_sec),
        @lift($mn_sec .+ $sd_sec),
        color = RGBA(0, 0, 0, 0.2f0),
    )
end