# Julius Krumbiegel's annotation fix (for e.g. flipped axes)

function textlayer!(ax::LAxis)
    pxa = lift(AbstractPlotting.zero_origin, ax.scene.px_area)
    Scene(ax.scene, pxa, raw = true, camera = campixel!)
end

function AbstractPlotting.annotations!(textlayer::Scene, ax::LAxis, texts, positions; kwargs...)
    positions = positions isa Observable ? positions : Observable(positions)
    screenpositions = lift(positions, ax.scene.camera.projectionview, ax.scene.camera.pixel_space) do positions, pv, pspace
        p4s = to_ndim.(Vec4f0, to_ndim.(Vec3f0, positions, 0.0), 1.0)
        p1m1s = [pv *  p for p in p4s]
        projected = [inv(pspace) * p1m1 for p1m1 in p1m1s]
        pdisplay = [Point2(p[1:2]...) for p in projected]
    end

    annotations!(textlayer, texts, screenpositions; kwargs...)
end
