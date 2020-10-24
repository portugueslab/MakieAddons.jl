module MakieAddons

using AbstractPlotting
using AbstractPlotting.MakieLayout
using Colors

include("colors.jl")
include("utilities.jl")
include("polar_plot.jl")
include("extra_plots.jl")
include("interaction.jl")
include("stack_browser.jl")
include("annotation_fix.jl")

export hidealldecorations!, polar_plot!, TERNARY_COLORS, add_rectangle_selector!, textlayer!, browse_stack

end # module
