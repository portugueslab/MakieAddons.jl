module MakieAddons

using AbstractPlotting
using AbstractPlotting.MakieLayout
using Colors

include("constants.jl")
include("utilities.jl")
include("polar_plot.jl")

export hidealldecorations!, polar_plot!, TERNARY_COLORS

end # module
