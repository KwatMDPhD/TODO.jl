module Public

const P1 = pkgdir(Public, "in")

const P2 = pkgdir(Public, "ou")

# ------------------------------------ #

using CSV: read, write as write2

using CodecZlib: GzipDecompressor, transcode

using ColorSchemes: ColorScheme

using Colors: RGB, coloralpha, hex

using DataFrames: DataFrame, insertcols!

using Dates: @dateformat_str, Date

using ImageMagick: load, save

using JSON: json, parsefile, print

using Mmap: mmap

using MultipleTesting: BenjaminiHochberg, adjust

using Printf: @sprintf

using Random: randstring

using StatsBase: mean, mean_and_std, tiedrank

using TOML: parsefile as parsefile2

using XLSX: readtable

########################################

function text_2(nu)

    @sprintf "%.2g" nu

end

function text_4(nu)

    @sprintf "%.4g" nu

end

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

function make_date(st)

    Date(st, dateformat"yyyy mm dd")

end

########################################

function is_path(pa, u1)

    u2 = 0

    while u2 < u1

        if ispath(pa)

            return true

        end

        sleep(1)

        u2 += 1

        @info "Waited for $pa ($u2 / $u1)."

    end

    false

end

function read_path(pa)

    run(`open --background $pa`; wait = false)

end

########################################

function index_extreme(an_, u1)

    u2 = length(an_)

    sortperm(an_)[if 0.5 * u2 <= u1

        1:u2

    else

        vcat(1:u1, (u2 - u1 + 1):u2)

    end]

end

########################################

function number_divergence(n1, n2)

    n1 * log2(n1 / n2)

end

function number_divergence(fu, n1, n2)

    fu(number_divergence(n1, n2), number_divergence(n2, n1))

end

function number_divergence(fu, n1, n2, n3, n4)

    fu(number_divergence(n1, n2), number_divergence(n3, n4))

end

########################################

function number_significance(fu::Function, nu_)

    um = count(fu, nu_)

    if iszero(um)

        1

    else

        um

    end / length(nu_)

end

function number_significance(fu, n1_, n2_)

    pr_ = map(nu -> number_significance(fu(nu), n2_), n1_)

    pr_, adjust(pr_, BenjaminiHochberg())

end

function number_sign(n1_)

    ty = eltype(n1_)

    n2_ = ty[]

    n3_ = ty[]

    for nu in n1_

        push!(if nu < 0

            n2_

        else

            n3_

        end, nu)

    end

    n2_, n3_

end

function number_significance(n1_, n2_)

    i1_ = findall(<(0), n1_)

    i2_ = findall(>=(0), n1_)

    n3_, n4_ = number_sign(n2_)

    n5_, n6_ = number_significance(<=, n1_[i1_], n3_)

    n7_, n8_ = number_significance(>=, n1_[i2_], n4_)

    vcat(i1_, i2_), vcat(n5_, n7_), vcat(n6_, n8_)

end

########################################

function number_minimum!(nu_, n1)

    n2 = minimum(nu_) - n1

    map!(n3 -> n3 - n2, nu_, nu_)

end

function number_z!(nu_)

    n1, n2 = mean_and_std(nu_)

    pr = inv(n2)

    map!(n3 -> (n3 - n1) * pr, nu_, nu_)

end

function number_sum!(nu_)

    n1 = inv(sum(nu_))

    map!(n2 -> n2 * n1, nu_, nu_)

end

function number_extrema!(nu_)

    n1, n2 = extrema(nu_)

    n3 = inv(n2 - n1)

    map!(n4 -> (n4 - n1) * n3, nu_, nu_)

end

function number_rank9(n1_)

    n2_ = tiedrank(n1_)

    pr = inv(length(n1_) + 1)

    map!(nu -> nu * pr, n2_, n2_)

end

########################################

function number_difference(n1_, n2_)

    mean(n2_) - mean(n1_)

end

function number_ratio(n1_, n2_)

    log2(mean(n2_) / mean(n1_))

end

function number_signal(n1_, n2_)

    n1, n2 = mean_and_std(n1_)

    n3, n4 = mean_and_std(n2_)

    (n3 - n1) / (max(0.2 * abs(n1), n2) + max(0.2 * abs(n3), n4))

end

########################################

function make_2(fu, bo_, an_)

    fu(an_[map(!, bo_)], an_[bo_])

end

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

########################################

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

function make_table(st, s1_, s2_, A)

    insertcols!(DataFrame(A, s2_), 1, st => s1_)

end

function write_table(pa, A)

    write2(pa, A; delim = '\t')

end

########################################

const DA = "#27221f"

const LI = "#ebf6f7"

const HU = "#fbb92d"

const TU = "#20d9ba"

const IN = "#4e40d8"

const VI = "#9017e6"

const SC = "#a40522"

const PE = "#f47983"

const RE = "#ff1993"

const GR = "#92ff93"

const BL = "#1992ff"

const SP = "#00936e"

const FA = "#ffd96a"

const OR = "#fc7f31"

########################################

function text_color()

    st = randstring(
        (
            '0',
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            'a',
            'b',
            'c',
            'd',
            'e',
            'f',
        ),
        6,
    )

    "#$st"

end

function text_color(co)

    st = hex(co, :rrggbbaa)

    "#$st"

end

function text_color(st, pr)

    text_color(coloralpha(parse(RGB, st), pr))

end

########################################

const C1_ = "#0000ff", "#ffffff", "#ff0000"

const C2_ = "#8a3ffc",
"#33b1ff",
"#007d79",
"#ff7eb6",
"#fa5d67",
"#fff1f1",
"#6fdc8c",
"#4589ff",
"#d12771",
"#d2a106",
"#08bdba",
"#bae6ff",
"#ba4e00",
"#d4bbff"

########################################

function make_colorscheme(st_)

    ColorScheme([parse(RGB, st) for st in st_])

end

function make_colorscale(st_)

    um = length(st_)

    if isone(um)

        st = st_[1]

        (0, st), (1, st)

    else

        Tuple(zip(range(0, 1, um), st_))

    end

end

########################################

function write_html(p1, pa_, s1, co = "#000000")

    p2 = if isempty(p1)

        s2 = randstring()

        joinpath(tempdir(), "$s2.html")

    else

        p1

    end

    s3 = join(("<script src=\"$pa\"></script>" for pa in pa_), '\n')

    write(
        p2,
        # TODO: Trim
        """
        <!doctype html>
        <html>
          <head>
            <meta charset="utf-8" />
          </head>
        $s3
          <body style="margin: 0; background: $co">
            <div id="write_html" style="min-height: 100vh"></div>
          </body>
          <script>
        $s1
          </script>
        </html>""",
    )

    read_path(p2)

end

########################################

function write_plotly(
    pa,
    di_,
    d1 = Dict{String, Any}(),
    d2 = Dict{String, Any}(),
)

    s1 = json(di_; allownan = true)

    d3 = Dict(
        "automargin" => true,
        "title" => Dict("font" => Dict("size" => 24)),
        "zeroline" => false,
        "showgrid" => false,
    )

    s2 = json(
        merge(
            Dict(
                "template" => Dict(
                    "data" => Dict(
                        "scatter" => (Dict("cliponaxis" => false),),
                        "heatmap" => (
                            Dict(
                                "colorbar" => Dict(
                                    "lenmode" => "pixels",
                                    "len" => 240,
                                    "thickness" => 16,
                                    "outlinewidth" => 0,
                                ),
                            ),
                        ),
                    ),
                    "layout" => Dict(
                        "title" => Dict("font" => Dict("size" => 32)),
                        "yaxis" => d3,
                        "xaxis" => d3,
                        "legend" => Dict("font" => Dict("size" => 16)),
                    ),
                ),
            ),
            d1,
        ),
    )

    s3 = json(d2)

    write_html(
        pa,
        ("https://cdn.plot.ly/plotly-3.3.0.min.js",),
        "Plotly.newPlot(\"write_html\", $s1, $s2, $s3)",
    )

end

function pair_title(s1, s2 = "")

    di = Dict("text" => s1)

    if !isempty(s2)

        di["subtitle"] = Dict("text" => s2)

    end

    "title" => di

end

########################################

function pair_heat(s1_, s2_, N)

    Dict(
        "type" => "heatmap",
        "y" => s1_,
        "x" => s2_,
        "z" => collect(eachrow(N)),
        "colorscale" => make_colorscale(C1_),
    )

end

function write_heat(pa, s1_, s2_, N, di = Dict{String, Any}())

    write_plotly(
        pa,
        (pair_heat(s1_, s2_, N),),
        pair_merge(
            Dict(
                "yaxis" =>
                    Dict("autorange" => "reversed", pair_title(length(s1_))),
                "xaxis" => Dict(pair_title(length(s2_))),
            ),
            di,
        ),
    )

end

########################################

function write_gif(p1, pa_, um)

    save(p1, stack(load(p2) for p2 in pa_); fps = um)

    read_path(p1)

end

end
