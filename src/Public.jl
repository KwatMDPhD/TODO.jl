module Public

const P1 = pkgdir(Public, "in")

const P2 = pkgdir(Public, "ou")

# ------------------------------------ #

using CSV: read

using CodecZlib: GzipDecompressor, transcode

using DataFrames: DataFrame

using JSON: parsefile, print

using Mmap: mmap

using TOML: parsefile as parsefile2

using XLSX: readtable

########################################
# String
########################################

function text_index(st, an, nd)

    split(st, an; limit = nd + 1)[nd]

end

function text_limit(s1, um)

    if length(s1) <= um

        return s1

    end

    s2 = s1[1:um]

    "$s2..."

end

########################################
# Path
########################################

function read_path(pa)

    run(`open --background $pa`; wait = false)

end

########################################
# Pair
########################################

function pair_merge(_, an)

    an

end

function pair_merge(d1::AbstractDict, d2::AbstractDict)

    a1_ = keys(d1)

    a2_ = keys(d2)

    d3 = Dict{
        Union{eltype(a1_), eltype(a2_)},
        Union{eltype(values(d1)), eltype(values(d2))},
    }()

    for an in union(a1_, a2_)

        d3[an] = if haskey(d1, an) && haskey(d2, an)

            pair_merge(d1[an], d2[an])

        elseif haskey(d1, an)

            d1[an]

        else

            d2[an]

        end

    end

    d3

end

function read_pair(pa)

    (
        if endswith(pa, "toml")

            parsefile2

        else

            parsefile

        end
    )(pa)

end

function write_pair(pa, di)

    open(pa, "w") do io

        print(io, di, 2)

    end

end

########################################
# Table
########################################

function make_part(A)

    st_ = names(A)

    st_[1], A[!, 1], st_[2:end], Matrix(A[!, 2:end])

end

function read_table(pa; ke_...)

    @assert isfile(pa) pa

    in_ = mmap(pa)

    read(if endswith(pa, "gz")

        transcode(GzipDecompressor, in_)

    else

        in_

    end, DataFrame; ke_...)

end

function read_sheet(pa, st; ke_...)

    DataFrame(readtable(pa, st; infer_eltypes = true, ke_...))

end

end
