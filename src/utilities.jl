function hidealldecorations!(ax::LAxis)
    hidedecorations!(ax)
    hidespines!(ax)
end

function close_poly(x)
    return [x; x[1]]
end