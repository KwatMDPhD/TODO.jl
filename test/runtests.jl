using Public

# ------------------------------------ #

for nd in 1:1

    @info "🎬 $nd"

    run(`julia --project $nd.jl`)

end
