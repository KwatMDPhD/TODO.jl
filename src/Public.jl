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

using Distributions: Normal, quantile

using ImageMagick: load, save

using JSON: json, parsefile, print

using Mmap: mmap

using MultipleTesting: BenjaminiHochberg, adjust

using Printf: @sprintf

using Random: randstring

using StatsBase: mean, mean_and_std, std, tiedrank

using TOML: parsefile as parsefile2

using XLSX: readtable

########################################

function make_function!(fu, an_)

    map!(fu, an_, an_)

end

########################################

function number_minimum!(nu_, n1)

    n2 = minimum(nu_) - n1

    map!(n3 -> n3 - n2, nu_, nu_)

end

function number_mean!(nu_)

    n1, n2 = mean_and_std(nu_)

    n3 = inv(n2)

    map!(n4 -> (n4 - n1) * n3, nu_, nu_)

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

function index_12(i1_)

    i2_ = Int[]

    i3_ = Int[]

    for nd in eachindex(i1_)

        push!(ifelse(isone(i1_[nd]), i2_, i3_), nd)

    end

    i2_, i3_

end

function make_function(fu, i1_, an_)

    i2_, i3_ = index_12(i1_)

    fu(an_[i2_], an_[i3_])

end

########################################

function index_extreme(an_, u1)

    u2 = length(an_)

    sortperm(an_)[if u2 <= 2 * u1

        1:u2

    else

        vcat(1:u1, (u2 - u1 + 1):u2)

    end]

end

function number_confidence(nu_, pr = 0.95)

    quantile(Normal(), 0.5 + pr * 0.5) * std(nu_) / sqrt(length(nu_))

end

function number_significance(fu, n1_, n2_)

    u1 = length(n1_)

    u2 = length(n2_)

    if iszero(u1) || iszero(u2)

        return fill(NaN, u1), fill(NaN, u1)

    end

    pr_ = map(nu -> max(1, count(fu(nu), n2_)) / u2, n1_)

    pr_, adjust(pr_, BenjaminiHochberg())

end

# TODO: Consider comparing against both signs

function number_sign(n1_)

    ty = eltype(n1_)

    n2_ = ty[]

    n3_ = ty[]

    for nu in n1_

        push!(ifelse(nu < 0, n2_, n3_), nu)

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

function text_2(nu)

    @sprintf "%.2g" nu

end

function text_4(nu)

    @sprintf "%.4g" nu

end

function text_limit(s1, um)

    if length(s1) <= um

        return s1

    end

    s2 = s1[1:um]

    "$s2..."

end

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

        @info "Waited for $pa ($u2 / $u1)"

    end

    false

end

function read_path(pa)

    try

        run(`open --background $pa`)

    catch

        @warn "Failed to open $pa"

    end

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

function read_pair(pa)

    ifelse(endswith(pa, "toml"), parsefile2, parsefile)(pa)

end

function write_pair(pa, di)

    open(io -> print(io, di, 2), pa, "w")

end

########################################

function make_part(D)

    st_ = names(D)

    st_[1], D[!, 1], st_[2:end], Matrix(D[!, 2:end])

end

function make_table(st, s1_, s2_, A)

    insertcols!(DataFrame(A, s2_), 1, st => s1_)

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

function write_table(pa, D)

    write2(pa, D; delim = '\t')

end

########################################

const DA = "#27221f"

const LI = "#ebf6f7"

const HU = "#fbb92d"

const RE = "#ff1993"

const GR = "#92ff93"

const BL = "#1992ff"

const SP = "#00936e"

const FA = "#ffd96a"

const TU = "#20d9ba"

const VI = "#9017e6"

const IN = "#4e40d8"

const OR = "#fc7f31"

const SC = "#a40522"

const PE = "#f47983"

function text_hex()

    he = randstring(
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

    "#$he"

end

function text_hex(co)

    he = hex(co, :rrggbbaa)

    "#$he"

end

function text_hex(he, pr)

    text_hex(coloralpha(parse(RGB, he), pr))

end

########################################

const H1_ = "#0000ff", "#fcfcfc", "#ff0000"

const H2_ = "#8a3ffc",
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

function make_color1(he_)

    ColorScheme([parse(RGB, he) for he in he_])

end

function make_color2(he_)

    um = length(he_)

    if isone(um)

        he = he_[]

        (0, he), (1, he)

    else

        Tuple(zip(range(0, 1, um), he_))

    end

end

########################################

function write_html(p1, pa_, s1, he = DA)

    p2 = if isempty(p1)

        s2 = randstring()

        joinpath(tempdir(), "$s2.html")

    else

        p1

    end

    s3 = join("<script src=\"$p3\"></script>\n" for p3 in pa_)

    write(
        p2,
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
        </head>
        $s3
        <body style="margin:0; background:$he; min-height:100vh; display:flex; justify-content:center; align-items:center">
          <div id="write_html" style="height:88vh; width:88vw"></div>
        </body>
        <script>
        $s1
        </script>
        </html>""",
    )

    read_path(p2)

end

function write_gif(p1, pa_, um)

    save(
        p1,
        reduce((A1, A2) -> cat(A1, A2; dims = 3), load(p2) for p2 in pa_);
        fps = um,
    )

    read_path(p1)

end

########################################

function pair_font(nu)

    "font" => Dict("size" => nu)

end

function pair_tickfont(nu)

    "tickfont" => Dict("size" => nu)

end

function pair_title(st)

    "title" => Dict("text" => st)

end

function pair_title(s1, s2)

    "title" => Dict("text" => s1, "subtitle" => Dict("text" => s2))

end

function write_plotly(pa, di_, d1 = Dict(), d2 = Dict())

    s1 = json(di_; allownan = true)

    d3 = Dict(
        "automargin" => true,
        "title" => Dict(pair_font(24)),
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
                        "title" => Dict(pair_font(32)),
                        "yaxis" => d3,
                        "xaxis" => d3,
                        "legend" => Dict(pair_font(16)),
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

########################################

function pair_heat(di, s1_, s2_, nu__)

    merge(di, Dict("type" => "heatmap", "y" => s1_, "x" => s2_, "z" => nu__))

end

function write_heat(pa, s1_, s2_, N, di = Dict())

    write_plotly(
        pa,
        (
            pair_heat(
                Dict("colorscale" => make_color2(H1_)),
                s1_,
                s2_,
                eachrow(N),
            ),
        ),
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

end
