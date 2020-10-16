module MakieAddons

using AbstractPlotting
using AbstractPlotting.MakieLayout
using Colors

include("constants.jl")
include("utilities.jl")
include("polar_plot.jl")
include("interaction.jl")
include("stack_browser.jl")
include("annotation_fix.jl")

export hidealldecorations!, polar_plot!, TERNARY_COLORS, add_rectangle_selector!, textlayer!

end # module
