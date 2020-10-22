

# Peter Kovesi's approximately equiluminant 
# set of 3 colors

TERNARY_COLORS = permutedims([
    0.9 0.17 0.0
    0.0 0.5 0.0
    0.1 0.33 1.0])

function color_to_labtuple(c)
    lc = Lab(c)
    return (lc.l, lc.a, lc.b)
end

"Overlay"
function color_overlay(
    a::AbstractArray{T,2},
    b::AbstractArray{T,2};
    vec_a = (30, 50, 0),
    vec_b = (30, 0, 50),
    vec_0 = (100, 0, 0),
) where {T}
    dir_a = vec_a .- vec_0
    dir_b = vec_b .- vec_0

    lab_array = dir_a .* Ref(a) .+ dir_b .* Ref(b) .+ Ref(ones(size(a))) .* vec_0
    return RGB.(Lab.(lab_array...))
end

    
function transparent_color(col, alpha)
    return RGBA(col.r, col.g, col.b, alpha)
end